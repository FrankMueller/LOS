require "LOS_UnitTest"
require "Dao"


--Tests for getColorAt
----------------------
local game = Dao:create( 'Spieler1', 'Spieler2' )

RunTest("Get color at black field", function() assert(game:getColorAt("a1") == PlayerColor.black) end, false)
RunTest("Get color at white field", function() assert(game:getColorAt("d1") == PlayerColor.white) end, false)
RunTest("Get color at empty field", function() assert(game:getColorAt("a2") == PlayerColor.NONE) end, false)
RunTest("Get color at invalid field", function() game:getColorAt("42") end, true)
RunTest("Get color at field outside the board", function() game:getColorAt("g4") end, true)


--Tests for getNextPlayer
-------------------------
RunTest("Next player initial", function() assert(game:getNextPlayer() == PlayerColor.white) end, false)
game:makeMove('d1', Direction.N)
RunTest("Next player after successful move", function() assert(game:getNextPlayer() == PlayerColor.black) end, false)
game:makeMove('a1', Direction.N)
RunTest("Next player after 2nd successful move", function() assert(game:getNextPlayer() == PlayerColor.white) end, false)
game:makeMove('g1', Direction.N)
RunTest("Next player after invalid move", function() assert(game:getNextPlayer() == PlayerColor.white) end, false)


--Test for getWinner
--------------------
local whiteCount = 0
local blackCount = 0

local winByLineCounter = 0
local winByBlockCounter = 0
local winByEdgeCounter = 0
local winByTrapCounter = 0

function checkForWinner(game)
	if (whiteCount == 4 and blackCount == 4) then
 		if (game:hasWonByLine(DaoMarble.W)) then
			winByLineCounter = winByLineCounter+1
			print("White has won by line", winByLineCounter)
			game:printGame()
			print()
		end
		if (game:hasWonByBlock(DaoMarble.W)) then
			winByBlockCounter = winByBlockCounter+1
			print("White has won by block", winByBlockCounter)
			game:printGame()
			print()
		end
		if (game:hasWonByEdgePoints(DaoMarble.W)) then
			winByEdgeCounter = winByEdgeCounter+1
			print("White has won by edges", winByEdgeCounter)
			game:printGame()
			print()
		end
		if (game:hasWonByTrappedMarble(DaoMarble.W)) then
			winByTrapCounter = winByTrapCounter+1
			print("White has won by trap", winByTrapCounter)
			game:printGame()
			print()
		end
	end
end

function setMarbleAt(playBoard, i, j, marble)

	local currentMarble = playBoard:getMarbleAt(i, j)
	if (currentMarble == DaoMarble.W) then
		whiteCount = whiteCount - 1
	elseif (currentMarble == DaoMarble.B) then
		blackCount = blackCount - 1
	end

	playBoard:setMarbleAt(i, j, marble)
	if (marble == DaoMarble.W) then
		whiteCount = whiteCount + 1
	elseif (marble == DaoMarble.B) then
		blackCount = blackCount + 1
	end

end

function permutate(playBoard, depth)

	if (whiteCount <= 4 and blackCount <= 4) then
		local columnIndex = math.floor(depth / 4)
		local rowIndex = depth - (columnIndex) * 4

		local i = columnIndex+1
		local j = rowIndex+1

		if (depth < 15) then
			setMarbleAt(playBoard, i, j, DaoMarble.B)
			permutate(playBoard, depth+1)

			setMarbleAt(playBoard, i, j, DaoMarble.W)
			permutate(playBoard, depth+1)

			setMarbleAt(playBoard, i, j, DaoMarble.None)
			permutate(playBoard, depth+1)

		else
			setMarbleAt(playBoard, i, j, DaoMarble.B)
			checkForWinner(game)

			setMarbleAt(playBoard, i, j, DaoMarble.W)
			checkForWinner(game)

			setMarbleAt(playBoard, i, j, DaoMarble.None)
			checkForWinner(game)
		end
	end
end

for i=1,4 do
	for j=1,4 do
		game.PlayBoard:setMarbleAt(i, j, DaoMarble.None)
	end
end

permutate(game.PlayBoard, 0)
print("winByLineCounter", winByLineCounter)
print("winByBlockCounter", winByBlockCounter)
print("winByEdgeCounter", winByEdgeCounter)
print("winByTrapCounter", winByTrapCounter)

--(n!/((n-k)! * k!))
RunTest("Win situations by line", function() assert(winByLineCounter == 3960, "Invalid number of win situations!") end, false)
RunTest("Win situations by block", function() assert(winByBlockCounter == 4455, "Invalid number of win situations!") end, false)
RunTest("Win situations by edge", function() assert(winByEdgeCounter == 495, "Invalid number of win situations!") end, false)
RunTest("Win situations by trap", function() assert(winByTrapCounter == 7920, "Invalid number of win situations!") end, false)
