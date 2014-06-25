---------------------------------------------
-- Implements a the play board of a Dao game
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

require("DaoMarble")

--Declare the class
Class{ 'DaoPlayBoard',
	a1 = DaoMarble, a2 = DaoMarble, a3 = DaoMarble, a4 = DaoMarble,
	b1 = DaoMarble, b2 = DaoMarble, b3 = DaoMarble, b4 = DaoMarble,
	c1 = DaoMarble, c2 = DaoMarble, c3 = DaoMarble, c4 = DaoMarble,
	d1 = DaoMarble, d2 = DaoMarble, d3 = DaoMarble, d4 = DaoMarble,
	PlayingFieldCount = Number
}

--Initializes a new instance of the 'DaoPlayBoard' class
function DaoPlayBoard:create()

	--Set the number of fields of the board
	self.PlayingFieldCount = 4

	--Set the marbles to their start positions
	for i=1,self.PlayingFieldCount,1 do
		self:setMarbleAt(i, i, DaoMarble.B)
		self:setMarbleAt(i, self.PlayingFieldCount - i + 1, DaoMarble.W)
	end
end

--Gets the character which identifies a column by the column index
function DaoPlayBoard:getColumnChar(columnIndex)

	--Make sure the column index is valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "Argument out of range 'columnIndex'")

	--Return the corresponding index
	return string.char(96+columnIndex)
end

--Get the indicies of the play board field with the specified name
function DaoPlayBoard:getFieldIndex(fieldName)

	--Make sure the string has exact  two characters
	assert(string.len(fieldName) == 2, "Invalid play board field name '" .. fieldName .."'")

	--Extracts the characters defining the column and row index
	local columnName = string.lower(string.sub(fieldName, 1, 1))
	local rowName = string.sub(fieldName, 2, 2)

	--Get the indicies of the fields
	local columnIndex = string.byte(columnName) - 96
	local rowIndex = tonumber(rowName)

	--Make sure the indicies are valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "Invalid field name '" .. fieldName .. "'")
	assert(rowIndex > 0 and rowIndex <= self.PlayingFieldCount, "Invalid field name '" .. fieldName .. "'")

	--Return the indicies
	return columnIndex, rowIndex
end

--Sets the DaoMarble at the field specified by column and row index to the specified value
function DaoPlayBoard:setMarbleAt(columnIndex, rowIndex, marble)

	--Make sure the field indicies are valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "The playboard has no column '" .. columnIndex .. "'")
	assert(rowIndex > 0 and rowIndex <= self.PlayingFieldCount, "The playboard has no column '" .. rowIndex .. "'")

	--Make sure the value to set is valid
	assert(marble == DaoMarble.W or marble == DaoMarble.B or marble == DaoMarble.None, "Argument out of range 'marble'")

	--Set the value
	self[self:getColumnChar(columnIndex) .. tostring(rowIndex)] = marble
end

--Gets the DaoMarble at the field specified by column and row index
function DaoPlayBoard:getMarbleAt(columnIndex, rowIndex)

	--Make sure the field indicies are valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "The playboard has no column '" .. columnIndex .. "'")
	assert(rowIndex > 0 and rowIndex <= self.PlayingFieldCount, "The playboard has no column '" .. rowIndex .. "'")

	--Return the value
	return self[self:getColumnChar(columnIndex) .. tostring(rowIndex)]
end

--Prints the playboard
function DaoPlayBoard:print()
	local columnHeader = "   | "
	local columnLine = " --+-"
	for column=1,self.PlayingFieldCount,1 do
		columnHeader = columnHeader .. self:getColumnChar(column) .. " "
		columnLine = columnLine .. "--"
	end
	print(columnHeader)
	print(columnLine)

	for row=self.PlayingFieldCount,1,-1 do
		local rowString = " " .. tostring(row) .. " | "
		for column=1,self.PlayingFieldCount,1 do
			local value = self:getMarbleAt(column, row)
			if (value == DaoMarble.None) then
				rowString = rowString .. ". "
			else
				rowString = rowString .. tostring(value) .. " "
			end
		end
		print(rowString)
	end
end
