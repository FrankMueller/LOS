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
_LOSEnumFieldMetatable = {

	__index = function(table, key)

		--Throw an error (enum fields can not be accessed)
		error("Access to properties of enum fields is not supported!")

	end,

    --Specify a customized function for set access of class members
    __newindex = function(table, key, value)

		--Throw an error (enum fields can not be accessed)
		error("Access to properties of enum fields is not supported!")

	end,

	--Specify a customized string conversion
	__tostring = function(self)

		--Return the name of the enum
		return rawget(self, "_name")

	end
}

function _LOSCreateEnumField(name, enum)

	local enumField = {}

	enumField._name = name
	enumField._enum = enum

	setmetatable(enumField, _LOSEnumFieldMetatable)

	return enumField

end

--Helper function to evaluate if the specified item is an enum field
function _LOSIsEnumField(item)
	return item ~= nil and getmetatable(item) == _LOSEnumFieldMetatable
end
