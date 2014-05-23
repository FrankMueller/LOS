---------------------------------------------
-- Contains object related fields of LOS
---------------------------------------------
-- Authors:
--   Ghadah Altayyari  -
--   Felix Held        -
--   Frank Müller      - 200407
---------------------------------------------

--Build a customized metatable to customize the access to the attributes and methods of an object
_LOSObjectMetatable = {

	--Specify a customized function for get access of object members
    __index = function(table, key)

		--Find the member of the class
		local class = rawget(table, "_class")
		local member = _LOSFindClassMember(class, key)

		--Throw an error if the member was not found
		assert(member ~= nil, "The class '" .. rawget(class, "_name") .. "' has no member " .. tostring(key))

		--If the member is not a function than check if there is a value available on the object; otherwise return the method
		if (type(member) ~= "function") then
			--Get the attribute table of the object
			local attributeTable = rawget(table, "_attributes")

			--Return the value of the attribute
			return attributeTable[key]
		else
			--Return the method
			return member
		end

    end,

    --Specify a customized function for set access of object members
    __newindex = function(table, key, value)

	    --Find the member of the class
		local class = rawget(table, "_class")
		local member = _LOSFindClassMember(class, key)

		--Throw an error if the value is a method (methods can only be defined on classes)
		local valueType = type(value)
		assert(valueType ~= "function", "Defintion of methods on objects is not supported!")

		--Throw an error if the member was not found
		assert(member ~= nil, "The class '" .. rawget(class, "_name") .. "' has no member " .. tostring(k))

		--Throw an error if the member is a method (methods can only be defined on classes)
		assert(member ~= "function", "Unable to assign a value to a method!")

		--Compute the type of the attribute
		local attributeType = member
		if (attributeType == "String" or attributeType == "Number" or attributeType == "Boolean") then
			assert(value ~= nil, "Invalid assignment! 'nil' is an invalid value for attributes of type 'String', 'Number' and 'Boolean'.")

			attributeType = string.lower(attributeType)
		end

		--Compute the type of the value
		if (valueType == "table") then
			local valueClass = rawget(value, "_class")
			valueType = valueClass._name
		end

		assert(valueType == attributeType or value == nil, "Invalid assignment. Unable to cast object of type '" .. valueType .. "' into '" .. attributeType .. "'")

		--Set the new value
		local attributeTable = rawget(table, "_attributes")
        rawset(attributeTable, key, value)
    end,

	--Specify a customized string conversion
	__tostring = function(self)
		--Get the class and attribute tables
		local class = rawget(self, "_class")
		local attributeTable = rawget(self, "_attributes")

		--Add the type to the string
		local str = "Object type:\n\t" .. rawget(class, "_name") .. "\n"

		--Add the attributes to the string
		str = "\r\n" .. str .. "Attributes:\n"
		for attributeName,attributeType in pairs(rawget(class, "_attributes")) do
			str = str .. "\t" .. attributeType .. ": " .. attributeName .. " = " .. tostring(attributeTable[attributeName]) .. "\n"
		end

		--Add the methods to the string
		str = "\r\n" .. str .. "Methods:\n"
		for methodName,method in pairs(rawget(class, "_methods")) do
			str = str .. "\t" .. methodName .. "\n"
		end

		return str
	end
}
