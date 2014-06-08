---------------------------------------------
-- Contains object related fields of LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

--Build a customized metatable to customize the access to the attributes and methods of an object
_LOSObjectMetatable = {

	--Specify a customized function for get access of object members
    __index = function(table, key)

		--Determin the class to search the member within
		local class = _LOSGetObjectClass(table)

		--If we process a call of a method on "super", then search the member within the super class
		if (_LOSCallingSuperMethod) then
			--Throw an error if there is no super class to call on
			assert(_LOSSuperClass ~= nil, "Invalid call of 'super'! There is no base class to call on.")

			--Manipulate the class we target so that we call on our super class
			class = _LOSSuperClass

			--If we are in a constructor and call the super constructor then manipulate the method we target to the custom constructor
			if (_LOSCallingConstructor and key == "create") then
				key = "_LOSCustomConstructor"
			end
		end

		--Find the member of the class
		local member = _LOSFindClassMember(class, key, true)

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
		local class = _LOSGetObjectClass(table)
		local member = _LOSFindClassMember(class, key, type(value) ~= "function")

		--Throw an error if the value is a method (methods can only be defined on classes)
		local valueType = type(value)
		assert(valueType ~= "function", "Defintion of methods on objects is not supported!")

		--Throw an error if the member was not found
		assert(member ~= nil, "The class '" .. rawget(class, "_name") .. "' has no member " .. tostring(key))

		--Throw an error if the member is a method (methods can only be defined on classes)
		assert(member ~= "function", "Unable to assign a value to a method!")

		--Compute the type of the attribute
		local attributeTypeName = member
		local attributeType = _G[attributeTypeName]

		--Check if the assignment is valid
		if (attributeTypeName == "String" or attributeTypeName == "Number" or attributeTypeName == "Boolean") then

			--Throw an error if nil should be assigned to a base type attribute
			assert(value ~= nil, "Invalid assignment! 'nil' is an invalid value for attributes of type 'String', 'Number' and 'Boolean'.")

			--Throw an error if the type of the value can not be assigned
			assert(valueType == string.lower(attributeTypeName), "Invalid assignment! Unable to cast object of type '" .. valueType .. "' into '" .. attributeTypeName .. "'")

		elseif (_LOSIsClass(attributeType)) then

			--Throw an error if the specified value is not an object
			assert(_LOSIsObject(value), "Invalid assignment! The specified value is not an object ('" .. attributeTypeName .. "')")

			--Throw an error if the object is of a type which is not conform to the type of the attribute
			assert(value == nil or _LOSGetClassIsComformTo(_LOSGetObjectClass(value), attributeType), "Invalid assignment. Unable to cast object of type '" .. valueType .. "' into '" .. attributeTypeName .. "'")

		elseif (_LOSIsEnum(attributeType)) then

			--Throw an error if nil should be assigned to an enum type attribute
			assert(value ~= nil, "Invalid assignment! 'nil' is an invalid value for attributes of type 'Enum'.")

			--Throw an error if the specified value is not an enum field
			assert(_LOSIsEnumField(value), "Invalid assignment! The specified value is not an enum ('" .. attributeTypeName .. "')")

		else

			--Throw an error if none of the cases above matches (This should never happen but...)
			error("Invalid assignment! Unknown error.")

		end

		--Set the new value
		local attributeTable = rawget(table, "_attributes")
        rawset(attributeTable, key, value)
    end,

	--Specify a customized string conversion
	__tostring = function(self)

		--Get the class and attribute table
		local class = _LOSGetObjectClass(self)

		--If there is a method available which is named "ToString" then call this, otherwise return the object info string
		local toStringMethod = _LOSFindClassMember(class, "ToString", true)
		if (toStringMethod ~= nil and type(toStringMethod) == "function") then
			local stringRepresentation = toStringMethod(self)
			return stringRepresentation or ""
		else
			return _LOSGetObjectInformationString(self)
		end
	end
}

--Helper function to evaluate if the specified item is an object
function _LOSIsObject(item)
	return item == nil or getmetatable(item) == _LOSObjectMetatable
end

--Helper function to determin the class of an object
function _LOSGetObjectClass(object)
	return rawget(object, "_class")
end

--Helper method for debugging which creates a string containing information about the specified object
function _LOSGetObjectInformationString(object)

	--Get the class and attribute table
	local class = _LOSGetObjectClass(object)
	local attributeTable = rawget(object, "_attributes")

	--Add the type to the string
	local str = "Object type:\t" .. rawget(class, "_name") .. "\n"

	--Add the attributes to the string
	str = str .. "\tAttributes:\n"
	for attributeName,attributeType in pairs(_LOSGetClassMembers(class, "_attributes")) do
		str = str .. "\t\t" .. attributeType .. ": " .. attributeName .. " = " .. tostring(attributeTable[attributeName]) .. "\n"
	end

	--Add the methods to the string
	str = str .. "\tMethods:\n"
	for methodName,method in pairs(_LOSGetClassMembers(class, "_methods")) do
		str = str .. "\t\t" .. methodName .. "\n"
	end

	return str
end
