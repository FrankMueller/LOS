---------------------------------------------
-- Implements a the play board of a Dao game
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

require("DaoMeeple")

--Declare the class
Class{ 'DaoPlayBoard',
	a1 = DaoMeeple, a2 = DaoMeeple, a3 = DaoMeeple, a4 = DaoMeeple,
	b1 = DaoMeeple, b2 = DaoMeeple, b3 = DaoMeeple, b4 = DaoMeeple,
	c1 = DaoMeeple, c2 = DaoMeeple, c3 = DaoMeeple, c4 = DaoMeeple,
	d1 = DaoMeeple, d2 = DaoMeeple, d3 = DaoMeeple, d4 = DaoMeeple,
	PlayingFieldCount = Number
}

--Initializes a new instance of the 'DaoPlayBoard' class
function DaoPlayBoard:create()

	--Set the number of fields of the board
	self.PlayingFieldCount = 4

	--Set the meeples to their start positions
	for i=1,self.PlayingFieldCount,1 do
		self:setMeepleAt(i, i, DaoMeeple.B)
		self:setMeepleAt(i, self.PlayingFieldCount - i + 1, DaoMeeple.W)
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

--Sets the DaoMeeple at the field specified by column and row index to the specified value
function DaoPlayBoard:setMeepleAt(columnIndex, rowIndex, meeple)

	--Make sure the field indicies are valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "The playboard has no column '" .. columnIndex .. "'")
	assert(rowIndex > 0 and rowIndex <= self.PlayingFieldCount, "The playboard has no column '" .. rowIndex .. "'")

	--Make sure the value to set is valid
	assert(meeple == DaoMeeple.W or meeple == DaoMeeple.B or meeple == DaoMeeple.None, "Argument out of range 'meeple'")

	--Set the value
	self[self:getColumnChar(columnIndex) .. tostring(rowIndex)] = meeple
end

--Gets the DaoMeeple at the field specified by column and row index
function DaoPlayBoard:getMeepleAt(columnIndex, rowIndex)

	--Make sure the field indicies are valid
	assert(columnIndex > 0 and columnIndex <= self.PlayingFieldCount, "The playboard has no column '" .. columnIndex .. "'")
	assert(rowIndex > 0 and rowIndex <= self.PlayingFieldCount, "The playboard has no column '" .. rowIndex .. "'")

	--Return the value
	return self[self:getColumnChar(columnIndex) .. tostring(rowIndex)]
end

--Prints the playboard
function DaoPlayBoard:print()
	for row=self.PlayingFieldCount,1,-1 do
		local rowString = ""
		for column=1,self.PlayingFieldCount,1 do
			local value = self:getMeepleAt(column, row)
			if (value == DaoMeeple.None) then
				rowString = rowString .. ". "
			else
				rowString = rowString .. tostring(value) .. " "
			end
		end
		print(rowString)
	end
end
