---------------------------------------------
-- Implements a the game 'Dao'
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

require("Game")
require("DaoPlayBoard")


Enum{ 'Direction', { 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW' } }
Enum{ 'Result', { 'ok', 'noMarble', 'gameOver', 'illegalInput', 'wrongColor', 'noMovement' } }

--Declare the class
Class{ 'Dao', Game, PlayBoard = DaoPlayBoard, InteractiveMode = Boolean }

--Initializes a new instance of the 'DaoPlayBoard' class
function Dao:create(whitePlayerName, blackPlayerName, interactiveMode)
	super:create(whitePlayerName, blackPlayerName)

	self.PlayBoard = DaoPlayBoard:create()
	if (interactiveMode ~= nil and type(interactiveMode) == "boolean") then
		self.InteractiveMode = interactiveMode
	end

	if (interactiveMode) then
		self:InteractiveMainLoop()
	end
end

--The main loop method for the interactive mode
function Dao:InteractiveMainLoop()

	local skipPrintGame = false

	--Request the next move as long as no one has won the game
	while (self:getWinner() == PlayerColor.NONE) do

		--Print the playboard
		if (not skipPrintGame) then
			self:printGame()
		end

		--Request the player to perform his moveLength
		local nextPlayer = tostring(self:getNextPlayer());
		local nextPlayerName = self[nextPlayer]
		print("> " .. nextPlayerName .. " (" .. nextPlayer .. ") - its your turn")

		--Get the command
		local command = io.read()

		--Stop the main loop if requested
		if (command == "exit") then
			break
		end

		--Process the command if possible
		if (command ~= nil and string.len(command) > 2 and string.sub(command, 3, 3) == " ") then
			--Split the command into field name and direction string
			local startFieldNameToken = string.sub(command, 1, 2)
			local directionToken = string.sub(command, 4, -1)

			--Try to parse the field name and direction string
			local fieldNameValid = pcall(self.PlayBoard.getFieldIndex, self.PlayBoard, startFieldNameToken)
			local directionValid, direction = pcall(self.getDirectionFromString, self, directionToken)

			--If parsing failed then show an appropriate error message, otherwise perform the move
			if (not fieldNameValid or not directionValid) then
				if (not fieldNameValid) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: Can't find the field '" .. startFieldNameToken .. "' on the playboard")
					skipPrintGame = true
				end
				if (not directionValid) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: The direction '" .. directionToken .. "' is invalid")
					skipPrintGame = true
				end
			else
				--Perform the move
				local result = self:makeMove(startFieldNameToken, direction)
				if (result == Result.ok) then
					skipPrintGame = false
				elseif (result == Result.noMarble) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: There is no marble at the field '" .. startFieldNameToken .. "'")
					skipPrintGame = true
				elseif (result == Result.illegalInput) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: Your command is illegal.")
					skipPrintGame = true
				elseif (result == Result.wrongColor) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: You should not move your opposits marbles!")
					skipPrintGame = true
				elseif (result == Result.noMovement) then
					print("> sorry " .. nextPlayerName .. ", I can't perform your move: Your marble cannot move in direction '" .. directionToken .. "'!")
					skipPrintGame = true
				elseif (result == Result.gameOver) then
					self:printGame()
					print("! Congratulations " .. self[tostring(self:getWinner())] .. ", You won the game!")
				end
			end

		else
			print("> sorry, I didn't understand...")
			skipPrintGame = true
		end

	end
end

--Performs a single move
function Dao:handleMove(startField, direction)

	--Check if the game is already over
	if (self:getWinner() ~= PlayerColor.NONE) then
		return false, Result.gameOver
	end

	--Make sure the specified field is valid
	local fieldNameValid, result = pcall(self.PlayBoard.getFieldIndex, self.PlayBoard, startField)
	local directionValid = direction == Direction.N or direction == Direction.NE or direction == Direction.E or direction == Direction.SE
	directionValid = directionValid or direction == Direction.S or direction == Direction.SW or direction == Direction.W or direction == Direction.NW

	--If the field name and the direction are valid then go on with the move
	if (fieldNameValid and directionValid) then

		--If there is no marble on the field then return that the move is invalid
		if (self.PlayBoard[startField] == DaoMarble.None) then
			return false, Result.noMarble

		--If the marble on the field belongs to the other player then return that the move is invalid
		elseif (self:getColorAt(startField) ~= self.nextPlayer) then
			return false, Result.wrongColor

		else
			--Get the indicies of the start field
			local startColumnIndex, startRowIndex = self.PlayBoard:getFieldIndex(startField)

			--Compute the indicies of the field where the move ends
			local endColumnIndex, endRowIndex = self:getMoveEndField(startColumnIndex, startRowIndex, direction)

			--Compute the length of the move
			local moveLength = math.max(math.abs(startColumnIndex - endColumnIndex), math.abs(startRowIndex - endRowIndex))

			--If there is no move possible in the direction then  return that the move is invalid; otherwise perform the move
			if (moveLength == 0) then
				return false, Result.noMovement
			else
				--Move the marble from the start field to the target field
				self.PlayBoard:setMarbleAt(endColumnIndex, endRowIndex, self.PlayBoard:getMarbleAt(startColumnIndex, startRowIndex))
				self.PlayBoard:setMarbleAt(startColumnIndex, startRowIndex, DaoMarble.None)

				--Check if this move ends the game
				if (self:getWinner() == PlayerColor.NONE) then
					return true, Result.ok
				else
					return true, Result.gameOver
				end
			end
		end

	else
		return false, Result.illegalInput
	end

end

--Computes where a move starting at the specified field in the specified direction ends
function Dao:getMoveEndField(startColumnIndex, startRowIndex, direction)

	--Compute the index of the row of the next field in move direction
	local newRowIndex = startRowIndex
	if (direction == Direction.N or direction == Direction.NE or direction == Direction.NW) then
		newRowIndex = startRowIndex+1
	elseif (direction == Direction.S or direction == Direction.SE or direction == Direction.SW) then
		newRowIndex = startRowIndex-1
	end

	--Compute the index of the column of the next field in move direction
	local newColumnIndex = startColumnIndex
	if (direction == Direction.E or direction == Direction.NE or direction == Direction.SE) then
		newColumnIndex = startColumnIndex+1
	elseif (direction == Direction.W or direction == Direction.NW or direction == Direction.SW) then
		newColumnIndex = startColumnIndex-1
	end

	--If the next field is still on the board and is free then move forward and try to move on; otherwise end the move here
	if (newRowIndex > 0 and newRowIndex <= self.PlayBoard.PlayingFieldCount and
		newColumnIndex > 0 and newColumnIndex <= self.PlayBoard.PlayingFieldCount and
		self.PlayBoard:getMarbleAt(newColumnIndex, newRowIndex) == DaoMarble.None) then

		--Move on recursivly
		return self:getMoveEndField(newColumnIndex, newRowIndex, direction)
	else
		return startColumnIndex, startRowIndex
	end
end

--Gets the color of the marble at the field with the specified name
function Dao:getColorAt(fieldName)
	local columnIndex, rowIndex = self.PlayBoard:getFieldIndex(fieldName)

	return self:getColorAtIndex(columnIndex, rowIndex)
end

--Gets the color of the marble at the field with the specified indicies
function Dao:getColorAtIndex(columnIndex, rowIndex)
	local fieldValue = self.PlayBoard:getMarbleAt(columnIndex, rowIndex)

	if (fieldValue == DaoMarble.W) then
		return PlayerColor.white
	elseif (fieldValue == DaoMarble.B) then
		return PlayerColor.black
	elseif (fieldValue == DaoMarble.None) then
		return PlayerColor.NONE
	else
		return PlayerColor.BOTH
	end
end

--Parses the specified string into a Direction
function Dao:getDirectionFromString(directionString)
	return Direction[string.upper(directionString)]
end

--Gets the PlayerColor representing the player who has won the game
function Dao:getWinner()
	local blackHasWon = self:hasWon(DaoMarble.B)
	local whiteHasWon = self:hasWon(DaoMarble.W)

	if (blackHasWon and whiteHasWon) then
		return PlayerColor.BOTH
	elseif (blackHasWon) then
		return PlayerColor.black
	elseif (whiteHasWon) then
		return PlayerColor.white
	else
		return PlayerColor.NONE
	end
end

--Checks if the player who owns the specified marble has won the game
function Dao:hasWon(marble)
	return self:hasWonByLine(marble) or self:hasWonByBlock(marble) or self:hasWonByEdgePoints(marble) or self:hasWonByTrappedMarble(marble)
end

--Checks if the player who owns the specified marble has won by the 'full line' criteria
function Dao:hasWonByLine(marble)

	--Loop through all fields and search for full columns/rows
	for	i=1,self.PlayBoard.PlayingFieldCount,1 do

		--Check if all marbles in the current column/row are of the same type like we search for
		local hasRow = true
		local hasColumn = true
		for	j=1,self.PlayBoard.PlayingFieldCount,1 do
			hasRow = hasRow and self.PlayBoard:getMarbleAt(i, j) == marble
			hasColumn = hasColumn and self.PlayBoard:getMarbleAt(j, i) == marble
		end

		--If a full column or row exists then return that the player has won; otherwise check the next column/row
		if (hasRow or hasColumn) then
			return true
		end
	end

	return false
end

--Checks if the player who owns the specified marble has won by the 'block' criteria
function Dao:hasWonByBlock(marble)

	--Compute the center point of all marbles of the same color as the specified marble
	local centerColumn = 0
	local centerRow = 0
	for i=1,self.PlayBoard.PlayingFieldCount,1 do
		for j=1,self.PlayBoard.PlayingFieldCount,1 do
			if (self.PlayBoard:getMarbleAt(i, j) == marble) then
				centerColumn = centerColumn + i
				centerRow = centerRow + j
			end
		end
	end
	centerColumn = centerColumn / self.PlayBoard.PlayingFieldCount
	centerRow = centerRow / self.PlayBoard.PlayingFieldCount

	--Compute the radius where all marbles have to be within to fullfill the block criteria (incl. a small tolerance of 0.1%)
	local radius = 1.001 * math.sqrt(self.PlayBoard.PlayingFieldCount/2)/2

	--Check if all marbles of the same color as the specified marble are within the block radius
	for i=1,self.PlayBoard.PlayingFieldCount,1 do
		for j=1,self.PlayBoard.PlayingFieldCount,1 do

			if (self.PlayBoard:getMarbleAt(i, j) == marble) then

				--Compute the distance of the marble to the center
				local distanceInColumn = centerColumn - i
				local distanceInRow = centerRow - j
				local distanceToCenter = math.sqrt(distanceInColumn*distanceInColumn + distanceInRow*distanceInRow)

				--If one of the marbles is more far away from the center as the radius then the criteria is not full filled
				if (distanceToCenter > radius) then
					return false
				end
			end
		end
	end

	--All marbles are within the radius -> criteria fullfilled
	return true

end

--Checks if the player who owns the specified marble has won by the 'edge point' criteria
function Dao:hasWonByEdgePoints(marble)
	return self.PlayBoard:getMarbleAt(1, 1) == marble and
		self.PlayBoard:getMarbleAt(self.PlayBoard.PlayingFieldCount, 1) == marble and
		self.PlayBoard:getMarbleAt(1, self.PlayBoard.PlayingFieldCount) == marble and
		self.PlayBoard:getMarbleAt(self.PlayBoard.PlayingFieldCount, self.PlayBoard.PlayingFieldCount) == marble
end

--Checks if the player who owns the specified marble has won by the 'trapped marble' criteria
function Dao:hasWonByTrappedMarble(marble)

	--Compute which marble is the marble of the opponent
	local opponentMarble = DaoMarble.None
	if (marble == DaoMarble.W) then
		opponentMarble = DaoMarble.B
	elseif (marble == DaoMarble.B) then
		opponentMarble = DaoMarble.W
	else
		return false
	end

	--Check all edges if there is a marble trapped
	local n = self.PlayBoard.PlayingFieldCount
	if (self.PlayBoard:getMarbleAt(1, 1) == marble and self.PlayBoard:getMarbleAt(1, 2) == opponentMarble and
		self.PlayBoard:getMarbleAt(2, 2) == opponentMarble and self.PlayBoard:getMarbleAt(2, 1) == opponentMarble) then
		return true
	elseif (self.PlayBoard:getMarbleAt(1, n) == marble and self.PlayBoard:getMarbleAt(1, n-1) == opponentMarble and
		self.PlayBoard:getMarbleAt(2, n) == opponentMarble and self.PlayBoard:getMarbleAt(2, n-1) == opponentMarble) then
		return true
	elseif (self.PlayBoard:getMarbleAt(n, 1) == marble and self.PlayBoard:getMarbleAt(n-1, 1) == opponentMarble and
		self.PlayBoard:getMarbleAt(n, 2) == opponentMarble and self.PlayBoard:getMarbleAt(n-1, 2) == opponentMarble) then
		return true
	elseif (self.PlayBoard:getMarbleAt(n, n) == marble and self.PlayBoard:getMarbleAt(n-1, n) == opponentMarble and
		self.PlayBoard:getMarbleAt(n, n-1) == opponentMarble and self.PlayBoard:getMarbleAt(n-1, n-1) == opponentMarble) then
		return true
	else
		return false
	end

end

--Prints the playboard
function Dao:printGame()
	self.PlayBoard:print()
end
