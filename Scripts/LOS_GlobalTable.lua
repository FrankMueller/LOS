--Create an empty table to use to store everything which is saved into the global table
local _LOSGlobalTable = {}

--Build a metatable which redirects accesses to the _LOSGlobalTable
local _GlobalMetaTable = {

	--Customize the get function
	__index = function(t, k)

		--If the function Class is called then set a flag that we are in class definition mode
		if (k == "Class") then
			_LOSGlobalTable._LOSPerformingClassDefinition = true
		end

		--If we are in class definition mode then replace incoming undefined accesses with a placeholder (the key); otherwise redirect the access to _LOSGlobalTable
		if (_LOSGlobalTable._LOSPerformingClassDefinition) then

			--Get the value
			local value = _LOSGlobalTable[k]

			--If no value is available then replace the key as placeholder; otherwise return the value
			if (value == nil) then
				return k
			else
				return value
			end

		else

			--Simply redirect the access to _LOSGlobalTable
			return _LOSGlobalTable[k]

		end
	end,

	--Customize the set function
	__newindex = function(t, k, v)

		--Make sure no LOS keyword, function or table is overwritten
		if (_LOSGlobalTable[k]) then
		assert(k ~= "String" and k ~= "Number" and k ~= "Boolean" and k ~= "Class", "'" .. k .. "' is a reserved keyword of LOS. Redefinition is not allowed.")
		assert(k ~= "_LOSInitializeInstance" and k ~= "_LOSFindClassMember" and k ~= "_LOSValidateName", "'" .. k .. "' is a system function of LOS. Redefinition is not allowed.")
		assert(k ~= "_LOSClassMetatable" and k ~= "_LOSObjectMetatable", "'" .. k .. "' is a system table of LOS. Redefinition is not allowed.")
		end

		--Simply redirect the access to _LOSGlobalTable
		_LOSGlobalTable[k] = v

	end
}

--Set the metatable of the global table to _GlobalMetaTable
setmetatable(_G, _GlobalMetaTable)
