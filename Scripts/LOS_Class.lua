

_LOSClassMetatable = {

	--Specify a customized function for get access of object members
    __index = function(t, k)

	    if (k == "create") then
			return rawget(t, "_LOSInitializeInstance");
		else
			return rawget(t, k)
		end
    end,

    --Specify a customized function for set access of object members
    __newindex = function(t, k, v)

		if (k == "create") then
			rawset(t, "_LOSCustomConstructor", v)
		else
			rawset(t, k, v)
		end

		--assert(member == nil, "The class '" .. t._name .. "' already contains a member with the name " .. tostring(k))
    end

}

--Declares a class
function Class(params)

	--Extract the attributes of the class
    local classname = params[1]

	--Check if the class name is valid
	assert(classname ~= nil and classname ~= "", "The name of the class is not allowed to be empty")
	assert(not string.match(classname, " "), "The name of the class is not allowed to contain white spaces")

	--Create the new class
    local class = {}
    class._name = classname

	--Add the attributes to the class
	class._attributes = {}
	for attributeName,attributeType in pairs(params) do

		--ToDo: Check validity of the attribute type and name
		if (attributeName ~= 1) then
		    local attributeTypeValue = type(attributeType)

			if (attributeTypeValue == type(table)) then
				class._attributes[attributeName] = attributeType._name
			else
				class._attributes[attributeName] = attributeTypeValue
			end
		end

	end

	--Add a customized metatable for the class
	setmetatable(class, _LOSClassMetatable)

	--Define a constructor for this new class
	function class:_LOSInitializeInstance(...)
		object = {}
		object._class = class
		object._attributes = {}

		for attributeName,attributeType in pairs(class._attributes) do
			if (attributeType == type(String)) then
				object._attributes[attributeName] = String
			elseif (attributeType == type(Number)) then
				object._attributes[attributeName] = Number
			elseif (attributeType == type(Boolean)) then
				object._attributes[attributeName] = Boolean
			else
				object._attributes[attributeName] = nil
			end

			print(attributeName, attributeType)
		end

		--Add the customized metatable for the object
		setmetatable(object, _LOSObjectMetatable)

		--Call the custom constructor if there is one available
		if (class._LOSCustomConstructor) then
			class._LOSCustomConstructor(object, ...)
		end

		return object
	end

	--Add the class to the global table
    _G[classname] = class

end
