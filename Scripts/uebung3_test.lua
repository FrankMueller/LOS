require("LOS_gruppe22")
require("Dao")


local game = Dao:create( 'Stefan', 'Kristian' )
print()

------------------------
-- Initiales Spielfeld --
------------------------
game:printGame()

--[[ Erwartete Ausgabe:
W . . B
. W B .
. B W .
B . . W
--]]


---------------
-- Spielzüge --
---------------
print()
print(game:getNextPlayer() == PlayerColor.white)			--> true
print(game:makeMove('b1', Direction.E ) == Result.noMarble)	--> true
print(game:makeMove('b3', Direction.N ) == Result.ok)		--> true
game:makeMove('c3', Direction.W )
game:makeMove('c2', Direction.N )
game:makeMove('d4', Direction.SW)
game:makeMove('d1', Direction.N )
print(game:makeMove('a1', Direction.E) == Result.gameOver)	--> true

print(game:getColorAt('c4') == PlayerColor.white)			--> true


--------------
-- Gewinner --
--------------
print()

local winnerColor = game:getWinner()
local winnerName = game[tostring(winnerColor)]

print( "Gewinner: " .. winnerName .." (".. tostring(winnerColor) .. ")" )
--> Gewinner: Stefan (white)


---------------
-- Spielfeld --
---------------
print()
game:printGame()

--[[ Ausgabe:
W W W W
B . B .
. B . .
B . . .
--]]



------------------------
-- Interaktiver Modus --
------------------------

print()
print()
print("Interaktiver Modus")
print([[
Beispielzugfolge / -eingaben:
> a1 N
> Hallo Welt
> b3 N
> c3 W
> c2 N
> d4 SW
> d1 N
]])
local interactiveGame = Dao:create("Stefan", "Kristian", true)

print(interactiveGame:getWinner() == PlayerColor.white)		--> true


--[[ Beispielausgabe:

W . . B
. W B .
. B W .
B . . W

Spieler Stefan (white) ist am Zug, bitte Zug eingeben:
a1 N
Der gewählte Spielstein gehört dem anderen Spieler! Bitte Eingabe wiederholen:
Hallo Welt
Die Eingabe entspricht nicht dem Format 'a1 S' oder Feld bzw. Richtung sind keine gültigen Werte, bitte Eingabe wiederholen:
b3 N

W W . B
. . B .
. B W .
B . . W

Spieler Kristian (black) ist am Zug, bitte Zug eingeben:
c3 W

W W . B
B . . .
. B W .
B . . W

Spieler Stefan (white) ist am Zug, bitte Zug eingeben:
c2 N

W W W B
B . . .
. B . .
B . . W

Spieler Kristian (black) ist am Zug, bitte Zug eingeben:
d4 SW

W W W .
B . B .
. B . .
B . . W

Spieler Stefan (white) ist am Zug, bitte Zug eingeben:
d1 N

W W W W
B . B .
. B . .
B . . .

Spieler Stefan hat das Spiel gewonnen!


--]]
