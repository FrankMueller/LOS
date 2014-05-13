-- Objektorientierte Softwareentwicklung, Sommersemester 2014
-- Uebung 1


-- Hier steht der Name der LOS-Implementierung
-- Die Datei 'LOS_gruppeXY.lua' muss im gleichen Verzeichnis wie diese Datei liegen.

require("LOS_gruppe22")



-- Klasse, Standard-Konstruktor, Methode ohne Parameter

Class{'Cat'}

function Cat:meow( )
  print("Meow!")
end


kitty = Cat:create( )
kitty:meow()							--> Meow!
print()


-- Attribute, überschriebener Konstruktor, Methode mit Parameter

Class{'Dog', name = String, friend = Cat}
function Dog:create( n)
	self.name = n
end

function Dog:setFriend( f )
  self.friend = f
end

function Dog:bark( )
  print( self.name .. ": Woof!" )
  if self.friend then
    self.friend:meow()
  end
end



-- Aufruf der Methoden (mit gewünschter Ausgabe)

puppy = Dog:create("Puppy")
puppy:bark()							--> Puppy: Woof!

print()

puppy:setFriend(kitty)
puppy:bark()							--> Puppy: Woof!
											--> Meow!

print()



-- Für die folgenden Anweisungen sollen jeweils unterschiedliche, selbst-definierte Fehlermeldungen ausgegeben werden.
-- (Zum Testen muss '--' in der jeweiligen Zeile entfernt werden.)

-- Unbekannte Methode:
--			puppy:dance()

-- Falscher Typ:
--			puppy.name = false

-- Unbekannter Typ:
--			Class{"Mouse", enemy = Elephant}
