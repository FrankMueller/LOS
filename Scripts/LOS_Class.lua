
--Build a customized metatable to customize the access to the attributes and methods of a class
_LOSClassMetatable = {

	--Specify a customized function for get access of class members
    __index = function(t, k)

		--If the constructor was called then redirect the call to our instance initialization function
	    if (k == "create") then
			return rawget(t, "_LOSInitializeInstance");
		else
			--Find the member of the class
			local member = _LOSFindClassMember(t, k)

			--Throw an error if the member was not found
			assert(member ~= nil, "The class '" .. rawget(t, "_name") .. "' has no member with the name '" .. tostring(k) .. "'")

			--Throw an error if the member is a function (calls of function on a class are invalid)
			assert(type(member) ~= "function", "The call of a method is not allowed on a class")

			--Return the member
			return member
		end
    end,

    --Specify a customized function for set access of class members
    __newindex = function(t, k, v)

		--Check if the member name is valid
		_LOSValidateName(k, "method")

		--Throw an error if the specified value to set is not a method (attributes can only be defined on class declaration)
		assert(type(v) == "function", "Dynamic adding of class attributes is not supported!")

		--If the constructor was called then store the specified value in the class table to be able to call it on initialization
		if (k == "create") then
			--Store the custom constructor in a hidden field to be able to call it on initialization
			rawset(t, "_LOSCustomConstructor", v)
		else
			--Find the member of the class
			local member = _LOSFindClassMember(t, k)

			--Throw an error if there is already a method or attribute defined with the same name
			assert(member == nil, "The class '" .. rawget(t, "_name") .. "' already contains a member with the name '" .. tostring(k) .. "'")

			--Add the method to the method table
			rawset(rawget(t, "_methods"), k, v)
		end
    end,

	--Specify a customized string conversion
	__tostring = function(self)
		--Get the class and attribute tables
		local class = self

		--Add the type to the string
		local str = "Class:\n\t" .. rawget(class, "_name") .. "\n"

		--Add the attributes to the string
		str = "\r\n" .. str .. "Attributes:\n"
		for attributeName,attributeType in pairs(rawget(class, "_attributes")) do
			str = str .. "\t" .. attributeType .. ": " .. attributeName .. "\n"
		end

		--Add the methods to the string
		str = "\r\n" .. str .. "Methods:\n"
		for methodName,method in pairs(rawget(class, "_methods")) do
			str = str .. "\t" .. methodName .. "\n"
		end

		return str
	end
}

--Declares a class
function Class(params)

	--Extract the attributes of the class
    local classname = params[1]

	--Check if the class name is valid
	_LOSValidateName(classname, "class")

	--Throw an error if there is an field defined in the global table with the same name
	assert(_G[classname] == nil, "There is already a field defined with the name '" .. classname .. "'")

	--Create the new class
    local class = {}

	--Add the constructor method to the class
	class._LOSInitializeInstance = _LOSInitializeInstance

	--Add a name attribute to the class
	class._name = classname

	--Add a table to store the methods of the class
	class._methods = {}

	--Add a table to store the attributes of the class
	class._attributes = {}

	--Add the attributes
	for attributeName,attributeType in pairs(params) do

		--Check if the class name is valid
		_LOSValidateName(attributeName, "attribute")

		--ToDo: Check validity of the attribute type and name
		if (attributeName ~= 1) then
			--Make sure that the attribute type is a class
			assert(getmetatable(attributeType) == _LOSClassMetatable, "Invalid type specified for attribute '" .. attributeName .. "'")

			--Add the attribute to the attribute table
			class._attributes[attributeName] = attributeType._name
		end

	end

	--Add a customized metatable for the class
	setmetatable(class, _LOSClassMetatable)

	--Add the class to the global table
    _G[classname] = class

end

--Initializes a new instance of the specified class
function _LOSInitializeInstance(class, ...)

	--Initialize a new table -> our object
	object = {}

	--Add the '_class' attribute to be able to identify the class of the object
	object._class = class

	--Add a table to store the values of the attributes in
	object._attributes = {}

	--Initialize all attributes of the object to their default values
	for attributeName,attributeType in pairs(class._attributes) do
		if (attributeType == String._name) then
			object._attributes[attributeName] = ""
		elseif (attributeType == Number._name) then
			object._attributes[attributeName] = 0
		elseif (attributeType == Boolean._name) then
			object._attributes[attributeName] = false
		else
			object._attributes[attributeName] = nil
		end
	end

	--Add the customized metatable for the object
	setmetatable(object, _LOSObjectMetatable)

	--Call the custom constructor if there is one available
	local customConstructor = rawget(class, "_LOSCustomConstructor")
	if (customConstructor) then
		customConstructor(object, ...)
	end

	return object
end

--Finds the member of the specified class with the specified name
function _LOSFindClassMember(class, memberName)

	--First look if the requested member is an attribute of the class
	local attributeTable = rawget(class, "_attributes")
	local member = attributeTable[memberName]

	--If no attribute with the specified name was found, then look if there is a method available
	if (member == nil) then
		local methodTable = rawget(class, "_methods")
		member = methodTable[memberName]
	end

	return member
end

function _LOSValidateName(name, item)
	--Make sure the name string is not empty
	assert(name ~= nil and name ~= "", "Invalid identifier '" .. name .. "'. The identifier of the " .. item .. " is not allowed to be empty")

	--Make sure the name does not contain blanks
	assert(not string.match(name, " "), "Invalid identifier '" .. name .. "'. The identifier of the " .. item .. " is not allowed to contain white spaces")
end
