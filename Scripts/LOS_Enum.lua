---------------------------------------------
-- Contains enum related fields and functions
-- of LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

--Build a customized metatable to customize the access to the fields of an enum
_LOSEnumMetatable = {

	__index = function(table, key)

		local value = rawget(table, "_values")[key]

		assert(value ~= nil, "There is no field named '" .. key .. "' defined for enum '" .. rawget(table, "_name") .. "'")

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
	assert(type(params[2]) ~= table or #params[2] == 0, "There are no fields declared for this enum.")

	--Create the new class
    local enum = {}

	--Add a name attribute to the class
	enum._name = enumname

	--Add a table to store the attributes of the class
	enum._values = {}

	--Validate the specified attributes and add them to the attribute table of the class
	for valueIndex,valueName in pairs(params[2]) do

		--Check if the name of the attribute is valid
		_LOSValidateName(valueName, "enum field")

		--Throw an error if there is an invalid type is used for the enum field name
		assert(type(valueName) == "string", "Invalid identifier '" .. valueName .. "'. The identifier of the enum field is not allowed to be a '" .. type(valueName) .. "'")

		--Make sure that the
		assert(type(valueIndex) == "number" or valueIndex == "default", "Invalid enum field declaration '" .. valueIndex .. " = " .. valueName .. "'.")

		--Add the attribute to the attribute table of the class
		enum._values[valueName] = valueName

		if (defaultValue == nil) then
			defaultValue = valueName
		end

	end

	if (params[2]["default"] == nil) then
		enum._default = defaultValue
	else
		enum._default = params[2]["default"]
	end

	--Add a customized metatable for the class
	setmetatable(enum, _LOSEnumMetatable)

	--Add the class to the global table
    _G[enumname] = enum

end

--Helper function to evaluate if the specified item is an enum
function _LOSIsEnum(object)

	return getmetatable(object) == _LOSEnumMetatable

end
