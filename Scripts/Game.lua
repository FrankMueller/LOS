require("LOS_gruppe22")

-----------------------
----- PlayerColor -----
-----------------------

--[[
	An Enumeration holding two values for the players' colors.
	Additionally holding values for none of the players and both of the players (e.g. a draw)
--]]
Enum{ "PlayerColor", {'black', 'white', 'BOTH', 'NONE'} }


----------------
----- Game -----
----------------


--[[
	A class to model the general structure of two player games.
	Handles the names of the two players (internally named 'black' and 'white'), the player to move next and whether the game is already over.

	--== The game specific elements have to be added in subclasses. ==--

--]]
Class{'Game', white = String, black = String, nextPlayer = PlayerColor, gameOver = Boolean }


--[[
	Creates a new game.
	Names the two players with given Strings and sets the white player to go first.

	@param wName The white player's name.
	@param bName The black player's name.
--]]
function Game:create( wName, bName )

	self.white = tostring(wName)
	self.black = tostring(bName)

	self.nextPlayer = PlayerColor.white

	--== The game specific elements have to be added in subclasses. ==--

end


--[[
	Makes a move in the game.
	Does not handle game specific elements, only sets the other player to move next and checks whether the game is over.
--]]
function Game:makeMove( ... )

	local ok, result = self:handleMove( ... )

	if not ok then
		return result
	end

	if self.nextPlayer == PlayerColor.white then
		self.nextPlayer = PlayerColor.black
	else
		self.nextPlayer = PlayerColor.white
	end

	if self:getWinner() ~= PlayerColor.NONE then
		self.gameOver = true
	end

	return result
end


--[[
	Handles the game specific part of a move.
	The first return value is a boolean indicating whether this move is allowed, the second is a result to return.

	--== This method Should be overriden in subclasses. ==--

--]]
function Game:handleMove( ... )
	return true, nil
end


--[[
	Returns the winner's PlayerColor.
	Returns NONE if the game is not over, and BOTH, if the result is a draw.

	--== This method Should be overriden in subclasses. ==--

--]]
function Game:getWinner()
	return PlayerColor.NONE
end


--[[
	Returns the name of the player who has to move next, if the game has not ended yet.
--]]
function Game:getNextPlayer()
	if self:getWinner() == PlayerColor.NONE then
		return self.nextPlayer
	else
		return PlayerColor.NONE
	end
end
