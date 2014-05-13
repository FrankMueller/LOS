_LOSObjectMetatable = {

	--Specify a customized function for get access of object members
    __index = function(t, k)

		--Find the member of the class
		local member = _LOSFindClassMember(t, k)

		--If the member is not a function than check if there is a value available on the object
		if (type(member) ~= "function") then

			--Get the attribute table of the object
			local attributeTable = rawget(t, "_attributes")

			--Get the value of the attribute
			local value = attributeTable[k];

			return value
		else
			return member
		end

    end,

    --Specify a customized function for set access of object members
    __newindex = function(t, k, v)

	    --Find the member of the class
		local classMember = _LOSFindClassMember(t, k)

		--If the member is a method then throw an error
		assert(type(classMember) ~= "function", "Redefinition of methods on objects is not supported!")

		--Check if the type of the value matches the type of the attribute
		local valueType = type(v)
		local attributeType = classMember

		if (valueType == "table") then
		    local valueClass = rawget(v, "_class")
		    assert(valueClass._name == attributeType, "Invalid cast. Unable to cast object of type '" .. valueClass._name .. "' into '" .. attributeType .. "'")
		else
		    assert(valueType == attributeType, "Invalid assignment. Unable to cast object of type '" .. valueType .. "' into '" .. attributeType .. "'")
		end

		--Set the new value
		local attributeTable = rawget(t, "_attributes")
        rawset(attributeTable, k, v)
    end,

	__tostring = function(self)
		--Get the class and attribute tables
		local class = rawget(self, "_class")
		local attributeTable = rawget(self, "_attributes")

		--Add the type to the string
		local str = "Object type:\n\t" .. class._name .. "\n"

		--Add the attributes to the string
		str = "\r\n" .. str .. "Attributes:\n"
		for attributeName,attributeType in pairs(class._attributes) do
			str = str .. "\t" .. attributeType .. ": " .. attributeName .. " = " .. tostring(attributeTable[attributeName]) .. "\n"
		end

		--Add the methods to the string
		str = "\r\n" .. str .. "Methods:\n"
		for methodName,method in pairs(class) do
			if (methodName ~= "_name" and methodName ~= "_attributes") then
				str = str .. "\t" .. methodName .. "\n"
			end
		end

		return str
	end
}


function _LOSFindClassMember(object, memberName)

	--Get the class of the object
	local class = rawget(object, "_class")

	--First look if the requested member is an attribute of the class
	local member = class._attributes[memberName]

	--If no attribute with the specified name was found, then look if there is a method available
	if (member == nil) then
		member = class[memberName]
	end

	--Throw an error if the member was not found
	assert(member ~= nil, "The class '" .. class._name .. "' has no member " .. tostring(memberName))

	return member
end
