---------------------------------------------
-- Contains class related fields and functions
-- of LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

--Build a customized metatable to customize the access to the attributes and methods of a class
_LOSClassMetatable = {

	--Specify a customized function for get access of class members
    __index = function(table, key)

		--If the constructor was called then redirect the call to our instance initialization function; otherwise get the member
	    if (key == "create") then
			return rawget(table, "_LOSInitializeInstance");
		else
			--Find the member of the class
			local member = _LOSFindClassMember(table, key, true)

			--Throw an error if the member was found (it is not allowed to access class members)
			assert(member == nil, "Access of class members is not supported.");

			--Return the member
			return member
		end
    end,

    --Specify a customized function for set access of class members
    __newindex = function(table, key, value)

		--Check if the member name is valid
		_LOSValidateName(key, "method")

		--Throw an error if the specified value to set is not a method (attributes can only be defined on class declaration)
		assert(type(value) == "function", "Dynamic adding of class attributes is not supported!")

		--If the constructor was called then store the specified value in the class table to be able to call it after initialization; otherwise add the member
		if (key == "create") then
			--Throw an error if there is already a constructor defined
			assert(rawget(table, "_LOSCustomConstructor") == nil, "The class '" .. rawget(table, "_name") .. "' already contains a constructor.")

			--Store the custom constructor in a hidden field to be able to call it after initialization
			rawset(table, "_LOSCustomConstructor", value)
		else
			--Find the member of the class
			local member = _LOSFindClassMember(table, key, false)

			--Throw an error if there is already a method or attribute defined with the same name
			assert(member == nil, "The class '" .. rawget(table, "_name") .. "' already contains a member with the name '" .. tostring(key) .. "'")

			--Add the method to the method table
			rawset(rawget(table, "_methods"), key, value)
		end
    end,

	--Specify a customized string conversion
	__tostring = function(self)

		--Get the class and attribute tables
		local class = self

		--Add the type to the string
		local str = "Class '" .. rawget(class, "_name") .. "':"

		--Add the attributes to the string
		str = str .. "\r\n\tAttributes:\n"
		for attributeName,attributeType in pairs(rawget(class, "_attributes")) do
			str = str .. "\t\t" .. attributeType .. ": " .. attributeName .. "\n"
		end

		--Add the methods to the string
		str = str .. "\r\n\tMethods:\n"
		for methodName,method in pairs(rawget(class, "_methods")) do
			str = str .. "\t\t" .. methodName .. "\n"
		end

		return str
	end
}

--Declares a class
function Class(params)

	--Unset the class definition flag
	_LOSPerformingClassDefinition = false

	--Extract the name of the class
    local classname = params[1]

	--Check if the class name is valid
	_LOSValidateName(classname, "class")

	--Throw an error if there is already a field defined in the global table with the same name
	assert(_G[classname] == nil, "There is already a field defined with the name '" .. classname .. "'.")

	--Extract the base class (if present)
	baseClass = params[2]
	if (baseClass ~= nil) then
		assert(_LOSIsClass(baseClass), "Invalid base class! Cannot inherit from type.")
	end

	--Create the new class
    local class = {}

	--Add the constructor method to the class
	class._LOSInitializeInstance = _LOSInitializeInstance

	--Add a name attribute to the class
	class._name = classname

	--Add the base class attribute to the class
	class._base = baseClass

	--Add a table to store the methods of the class
	class._methods = {}

	--Add a table to store the attributes of the class
	class._attributes = {}

	--Validate the specified attributes and add them to the attribute table of the class
	for attributeName,attributeType in pairs(params) do

		--Check if the name of the attribute is valid
		_LOSValidateName(attributeName, "attribute")

		--Check validity of the attribute type (skip the attribute "1" this is our classname)
		if (attributeName ~= 1 and attributeName ~= 2) then

			--Throw an error if there is
			attributeNameType = type(attributeName)
			assert(attributeNameType == "string", "Invalid identifier '" .. attributeName .. "'. The identifier of the attribute is not allowed to be a number or boolean")

			--If the type of the attribute is the class we declare, then accept without further validation; otherwise validate the type of the attribute
			if (attributeType == classname) then
				--Add the attribute to the attribute table of the class
				class._attributes[attributeName] = attributeType
			else
				--Make sure that the attribute type is a class (a table is expected to be a class if its metatable is our "_LOSClassMetatable")
				assert(_LOSIsClass(attributeType) or _LOSIsEnum(attributeType), "Invalid type specified for attribute '" .. attributeName .. "'")

				--Add the attribute to the attribute table of the class
				class._attributes[attributeName] = attributeType._name
			end
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
	local object = {}

	--Add the '_class' attribute to be able to identify the class of the object
	object._class = class

	--Add a table to store the values of the attributes in
	object._attributes = {}

	--Initialize all attributes of the object to their default values
	_LOSInitializeAttributes(object._attributes, class)

	--Add the customized metatable for the object
	setmetatable(object, _LOSObjectMetatable)

	--Call the custom constructor if there is one available
	local customConstructor = rawget(class, "_LOSCustomConstructor")
	if (customConstructor) then
		customConstructor(object, ...)
	end

	return object
end

function _LOSInitializeAttributes(objectAttributeTable, class)

	for attributeName,attributeType in pairs(class._attributes) do
		if (attributeType == String._name) then
			objectAttributeTable[attributeName] = ""
		elseif (attributeType == Number._name) then
			objectAttributeTable[attributeName] = 0
		elseif (attributeType == Boolean._name) then
			objectAttributeTable[attributeName] = false
		elseif (_LOSIsEnum(_G[attributeType])) then
			objectAttributeTable[attributeName] = rawget(_G[attributeType], "_default")
		else
			objectAttributeTable[attributeName] = nil
		end
	end

	local baseClass = rawget(class, "_base")
	if (baseClass ~= nil) then
		_LOSInitializeAttributes(objectAttributeTable, baseClass)
	end

end

--Finds the member of the specified class with the specified name
function _LOSFindClassMember(class, memberName, searchInBaseClassesToo)

	--First look if the requested member is an attribute of the class
	local attributeTable = rawget(class, "_attributes")
	local member = attributeTable[memberName]

	--If no attribute with the specified name was found, then look if there is a method available
	if (member == nil) then
		local methodTable = rawget(class, "_methods")
		member = methodTable[memberName]
	end

	--If the member is still not found, then search in the base class if possible
	if (member == nil and searchInBaseClassesToo) then
		local baseClass = rawget(class, "_base")
		if (baseClass ~= nil) then
			return _LOSFindClassMember(baseClass, memberName, searchInBaseClassesToo)
		end
	end

	return member
end

--Checks if the sepcified name is a valid name for a class, method or attribute and throws appropriate exception if not
function _LOSValidateName(name, item)
	--Make sure the name string is not empty
	assert(name ~= nil and name ~= "", "Invalid identifier '" .. name .. "'. The identifier of the " .. item .. " is not allowed to be empty")

	--Make sure the name does not contain blanks
	assert(not string.match(name, " "), "Invalid identifier '" .. name .. "'. The identifier of the " .. item .. " is not allowed to contain white spaces")
end

--Helper function to evaluate if the specified item is an enum
function _LOSIsClass(object)

	return getmetatable(object) == _LOSClassMetatable

end
