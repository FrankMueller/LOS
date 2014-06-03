---------------------------------------------
-- Contains global table mainpulations for
-- LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

--Create an empty table to use to store everything which is saved into the global table
local _LOSGlobalTable = {}

--Build a metatable which redirects accesses to the _LOSGlobalTable
local _GlobalMetaTable = {

	--Customize the get function
	__index = function(table, key)

		--If the function "Class" is called then set a flag that we are in class definition mode
		if (key == "Class" or key == "Enum") then
			_LOSGlobalTable._LOSPerformingClassDefinition = true
		end

		--If the requested item is named "super" set a flag that we called "super" and return the "_LOSCallingObject" we set for the method called in LOS_Class->LOS_ClassMetaTable->newindex
		if (key == "super") then
			_LOSGlobalTable._LOSCallingSuperMethod = true
			return _LOSGlobalTable._LOSCallingObject
		end

		--If we are in class definition mode then replace accesses to undefined fields with a placeholder (the key); otherwise redirect the access to _LOSGlobalTable
		if (_LOSGlobalTable._LOSPerformingClassDefinition) then

			--Get the value
			local value = _LOSGlobalTable[key]

			--If no value is available then return the key as placeholder; otherwise return the value
			if (value == nil) then
				return key
			else
				return value
			end

		else

			--Simply redirect the access to _LOSGlobalTable
			return _LOSGlobalTable[key]

		end
	end,

	--Customize the set function
	__newindex = function(table, key, value)

		--Make sure no LOS keyword, function or table is overwritten
		if (_LOSGlobalTable[key]) then
			assert(key ~= "String" and key ~= "Number" and key ~= "Boolean" and key ~= "Class", "'" .. key .. "' is a reserved keyword of LOS. Redefinition is not allowed.")
			assert(key ~= "_LOSInitializeInstance" and key ~= "_LOSFindClassMember" and key ~= "_LOSValidateName", "'" .. key .. "' is a system function of LOS. Redefinition is not allowed.")
			assert(key ~= "_LOSClassMetatable" and key ~= "_LOSObjectMetatable", "'" .. key .. "' is a system table of LOS. Redefinition is not allowed.")
		end

		--Simply redirect the access to _LOSGlobalTable
		_LOSGlobalTable[key] = value

	end,

	--Specify a customized string conversion
	__tostring = function(self)

		--Add the type to the string
		local str = "_G:\n"

		--Add the attributes to the string
		for key,value in pairs(_LOSGlobalTable) do
			str = str .. "\t" .. key .."\n"--.. " = " .. tostring(value) .. "\n"
		end

		return str
	end
}

--Set the metatable of the global table to _GlobalMetaTable
setmetatable(_G, _GlobalMetaTable)
