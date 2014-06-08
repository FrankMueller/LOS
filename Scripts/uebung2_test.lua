-- Objektorientierte Softwareentwicklung, Sommersemester 2014
-- Uebung 2


-- Hier steht der Name der LOS-Implementierung
-- Die Datei 'LOS_gruppeXY.lua' muss im gleichen Verzeichnis wie diese Datei liegen.

require("LOS_gruppe22")



-- Aufzählungstyp
Enum{ 'Gender', {'male', 'female', default = 'undetermined'} }



-- Klasse mit überschriebenem Konstruktur und Methoden (aus Uebung 1 bekannt) und Aufzählungstyp-Attribut

Class{'Pet', name = String, gender = Gender}

function Pet:create( n )
  self.name = n
end

function Pet:getNoise( )
   return "..."
end

function Pet:makeNoise( )
  print( self.name .. " (" .. tostring(self.gender) .. "): " .. self:getNoise() )
end

function Pet:determineGender( g )
  self.gender = g
end



-- Erbende Klassen mit geerbtem Konstruktor sowie unverändert geerbten oder überschriebenen Methoden

Class{'Cat', Pet}

function Cat:getNoise( )
  return 'Meow!'
end


Class{'Dog', Pet, friend = Pet}

function Dog:getNoise( )
  return 'Woof!'
end

function Dog:makeNoise( )
  super:makeNoise()
  if self.friend then
    self.friend:makeNoise()
  end
end




-- Ausführung der Methoden (mit gewünschter Ausgabe)

kitty = Cat:create( "Kitty" )
kitty:makeNoise()					--> Kitty (undetermined): Meow!

print()

puppy = Dog:create( "Puppy" )
puppy:makeNoise()				--> Puppy (undetermined): Woof!

print()

puppy:determineGender( Gender.female )
kitty:determineGender( Gender.male )
puppy.friend = kitty
puppy:makeNoise()				--> Puppy (female): Woof!
										--> Kitty (male): Meow!

print()



-- Für die folgenden Anweisungen sollen jeweils unterschiedliche, selbst-definierte Fehlermeldungen ausgegeben werden.
-- (Zum Testen muss '--' in der jeweiligen Zeile entfernt werden.)

-- Ungültige Oberklasse:
--			Class{'Human', Ape}

-- Ungültige Redefinition eines Attributs:
--			Class{'Sheep', Pet, name = Number}

-- Ungültiger Wert für Aufzählungstyp:
--			puppy.gender = "male"
