---------------------------------------------
-- Contains enum related fields and functions
-- of LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank M�ller      - 200407
---------------------------------------------

--Build a customized metatable to customize the access to the fields of an enum
_LOSEnumMetatable = {

	__index = function(table, key)

		--Get the value of the value table
		local value = rawget(table, "_values")[key]

		--Throw an error if there is no value available with this name
		assert(value ~= nil, "There is no field named '" .. key .. "' defined for enum '" .. rawget(table, "_name") .. "'")

		--Return the value
		return value

	end,

    --Specify a customized function for set access of class members
    __newindex = function(table, key, value)

		--Throw an error if there is a value set (enum fields can only be defined during enum declaration)
		error("Dynamic adding of enum fields is not supported!")

	end,

	--Specify a customized string conversion
	__tostring = function(self)

		--Return the name of the enum
		return rawget(self, "_name")

	end
}

--Declares a class
function Enum(params)

	--Unset the class definition flag
	_LOSPerformingClassDefinition = false

	--Extract the name of the enum
    local enumname = params[1]

	--Check if the class name is valid
	_LOSValidateName(enumname, "enum")

	--Throw an error if there is an field defined in the global table with the same name
	assert(_G[enumname] == nil, "There is already a field defined with the name '" .. enumname .. "'")

	--Throw an error if there are no fields declared
	assert(type(params[2]) == "table" and #params[2] > 0, "There are no fields declared for this enum.")

	--Create the new class
    local enum = {}

	--Add a name attribute to the class
	enum._name = enumname

	--Add a table to store the attributes of the class
	enum._values = {}

	--Validate the specified attributes and add them to the attribute table of the class
	for valueIndex,valueName in pairs(params[2]) do

		--Throw an error if there is an invalid type is used for the enum field name
		assert(type(valueName) == "string", "Invalid identifier '" .. tostring(valueName) .. "'. The identifier of the enum field is not allowed to be a '" .. type(valueName) .. "'")

		--Check if the name of the attribute is valid
		_LOSValidateName(valueName, "enum field")

		--Make sure that the field definition is valid (the index must be a number of "default")
		assert(type(valueIndex) == "number" or valueIndex == "default", "Invalid enum field declaration '" .. valueIndex .. " = " .. valueName .. "'.")

		--Make sure thet the field is not already defined
		assert(enum._values[valueName] == nil, "Invalid identifier '" .. valueName .. "'. There is already a field defined with the same name.")

		local enumField = _LOSCreateEnumField(valueName, enum)

		--Add the attribute to the attribute table of the class
		enum._values[valueName] = enumField

		--Remember which value is the default value (the first one or the one named "default")
		if (defaultValue == nil or valueIndex == "default") then
			defaultValue = enumField
		end

	end

	enum._default = defaultValue

	--Add a customized metatable for the class
	setmetatable(enum, _LOSEnumMetatable)

	--Add the class to the global table
    _G[enumname] = enum

end

--Helper function to evaluate if the specified item is an enum
function _LOSIsEnum(item)
	return item ~= nil and getmetatable(item) == _LOSEnumMetatable
end
