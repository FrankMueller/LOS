
------------------------------------------------------

--[[

	Informationen

	* Die Funktion "pcall" führt ein 'geschütztes Aufrufen' ('protected call') einer übergebenen Funktion aus, pcall kann mehrere Rückgabewerte haben, unterschieden wird in zwei Fälle:
		- Die Ausführung war erfolgreich, kein Fehler ist aufgetreten. Der erste Rückgabewert ist 'true', die weiteren sind die Rückgaben der übergebenen, ausgeführten Funktion.
		- Die Ausführung war nicht erfolgreich, ein Fehler ist aufgetreten. Der erste Rückgabewert ist 'false', der zweite ist die Fehlermeldung.
		Häufig ist die Nutzung von "local success, result = pcall( f )", wobei success dann ein Boolean ist, der den Erfolg angibt und result entweder das Ergebnis oder die Fehlermeldung enthält

	* Die Funktion "assert" bekommt zwei Argumente, wobei das zweite optional ist, in der Regel ein String.
		- Ist das erste Argument 'false' oder 'nil', dann wird hier ein Fehler erzeugt mit dem zweiten Argument als Fehlermeldung.
		- Ist das erste Argument weder 'false' noch 'nil', dann wird dieses von assert zurückgegeben.

	* Im Folgenden kommen zwei Arten von Tests vor:
		- Tests für die Positivfälle überprüfen, ob etwas, das funktionieren sollte, tatsächlich funktioniert.
			Falls alles ok ist, wird lediglich 'true' zurückgegeben. [OK]
			Falls ein Fehler auftritt, so wird dieser i.d.R. nicht behandelt. [FAILED ---> ...]
		- Tests für die Fehlerfälle sind erfolgreich, wenn ein Fehler auftritt.
			Falls ein Fehler auftritt, so wird dieser abgefangen (pcall) und nur die Fehlermeldung zurückgegeben, damit manuell überprüft werden kann, ob die Fehlermeldung zum erwarteten Fehler passt. [VALUE/MESSAGE ---> ...]
			Falls kein Fehler auftritt, so wird ein Fehler erzeugt. [FAILED ---> ...]

	* Die Hilfsfunktionen (in dieser Datei ganz oben und ganz unten) dienen lediglich dazu, einen Test aufzurufen und eine entsprechende print-Ausgabe zu erzeugen.
		Die geteste Funktionalität ist komplett im jeweiligen Test zu finden.

	* Die Testfunktionen sollten einzeln ausgeführt werden, damit kein Testfall die anderen beeinflussen kann.
		So können auch Fehler leichter auf wenige Zeilen Code eingegrenzt werden.

--]]

------------------------------------------------------

-- Usage:
--		uebung1_bewertungstest.lua major minor
--
--	Runs the test case with the given number ("uebung1_bewertungstest.lua 2 1" --> Test 2.1) and prints
--		- OK, if the test was successfull
--		- VALUE/MESSAGE and the return value, if the test's result requires a manual check
--		- FAILED, if the test failed
--

if not _testframework then

	-- Die 'type'-Funktion wird eventuell in der LOS-Implementierung überschrieben, daher vorher gespeichert.
	_oldtype = type
	require("LOS_gruppe22")

	major = arg[1] or 3
	minor = arg[2] or 12

end


------------------------------------------------------





-----
----- 1 Allgemein -----
-----
function test_1()
	return "Allgemein"
end


-- 1.1 "Normale" Nutzung von Lua-Variablen nicht beeinträchtigt
function test_1_1()
	three = 3

	local knownVar = (three == 3)
	local unknownVar = (unknown == nil)

	return assert(
						knownVar and unknownVar,
						"Normale Verwendung von Lua-Variablen nicht möglich (" .. tostring(knownVar) .. ", " .. tostring(unknownVar) .. ")."
					  )
end


-- 1.2 LOS gibt im Fehlerfall eigene, aussagekräftige Meldungen aus
function test_1_2()
	return "Aus den weiteren Tests ersichtlich."
end


-- 1.3 LOS produziert keine eigenen Ausgaben, falls kein Fehler vorliegt
function test_1_3()
	return "Aus den weiteren Tests ersichtlich."
end





-----
----- 2 Klassendefinition und Objektinstanziierung -----
-----
function test_2()
	return "Klassendefinition und Objektinstanziierung"
end


-- 2.1 Class erzeugt Klasse (table), welche global verfügbar ist
function test_2_1()
	Class{"MyClass"}

	local MyClassType = _oldtype(MyClass)

	return assert(
						MyClassType == 'table',
						"Nach Deklaration einer Klasse 'MyClass' ist unter dem Namen global ein Wert vom Typ '" .. tostring(MyClassType) .. "' zu finden."
					  )
end


-- 2.2 Default-Konstruktor erzeugt Objekt (table)
function test_2_2()
	Class{"MyClass"}

	local object = MyClass:create()
	local objectType = _oldtype(object)

	return assert(
						objectType == 'table',
						"Die 'create'-Methode liefert einen Wert vom Typ '" .. tostring(objectType) .. "'."
					  )
end


-- 2.3 Konstruktor kann überschrieben werden und spezieller Konstruktor erzeugt Objekt
function test_2_3()
	Class{"MyClass"}
	local createMethodExecuted = false

	function MyClass:create()
		createMethodExecuted = true
	end

	local object = MyClass:create()
	local objectType = _oldtype(object)

	return assert(
						createMethodExecuted == true and objectType == 'table',
						"Spezielle 'create'-Methode wird nicht ausgeführt oder Objekt wird nicht erzeugt (" .. tostring(createMethodExecuted) .. ", " .. tostring(objectType) .. ")."
					  )
end


-- 2.4 Im überschriebenen Konstruktor können Parameter und die self-Referenz korrekt verwendet werden
function test_2_4()
	Class{"MyClass"}

	local referenceInsideCreate = nil
	local p1InsideCreate = false
	local p2InsideCreate = 0

	function MyClass:create( p1, p2 )
		referenceInsideCreate = self
		p1InsideCreate = p1
		p2InsideCreate = p2
	end

	local object = MyClass:create( true, 2014 )

	return assert(
						p1InsideCreate == true and p2InsideCreate == 2014 and referenceInsideCreate == object,
						"Parameter oder self-Referenz in spezieller 'create'-Methode sind nicht korrekt (" .. tostring(p1InsideCreate) .. ", " .. tostring(p2InsideCreate) .. ", " .. tostring(referenceInsideCreate == object) ..")."
					  )
end


-- 2.5 Mehrere Objekte einer Klasse können erzeugt werden
function test_2_5()
	Class{"MyClass"}

	local object1 = MyClass:create()
	local object2 = MyClass:create()

	return assert(
						object1 ~= object2,
						"Mehrere erstellte Objekte sind identisch."
					  )
end


-- 2.6 Klassendefinition mit nicht erlaubtem Namen nicht möglich (Fehler erwartet)
function test_2_6()
	local success, result = pcall(function()
		Class{"Class name with spaces"}
	end)

	if not success then
		return result
	else
		error("Klassendefinition mit nicht erlaubtem Namen war erfolgreich.")
	end
end


-- 2.7 Default create-Methode steht an Objekten nicht zur Verfügung (Fehler erwartet)
function test_2_7()
	Class{"MyClass"}
	local object = MyClass:create()

	local success, result = pcall(function()
		return object:create()
	end)


	if not success then
		return result
	else
		error("Eine default 'create'-Funktion konnte an einem Objekt aufgerufen werden: " .. tostring(result) )
	end
end


-- 2.8 Spezielle create-Methode steht an Objekten nicht zur Verfügung (Fehler erwartet)
function test_2_8()
	Class{"MyClass"}
	function MyClass:create() end
	local object = MyClass:create()

	local success, result = pcall(function()
		return object:create()
	end)


	if not success then
		return result
	else
		error("Eine spezielle 'create'-Funktion konnte an einem Objekt aufgerufen werden: " .. tostring(result) )
	end
end





-----
----- 3 Attribute (Basistypen) und Methoden -----
-----
function test_3()
	return "Attribute (Basistypen) und Methoden"
end


-- 3.1 Attribute werden mit korrekten Default-Werten initialisiert
function test_3_1()
	Class{"MyClass", stringAttribute = String, numberAttribute = Number, booleanAttribute = Boolean}

	local object = MyClass:create()

	return assert(
						object.stringAttribute == "" and object.numberAttribute == 0 and object.booleanAttribute == false,
						"Attribute wurden vom Default-Konstruktor nicht oder nicht korrekt initialisiert (" .. tostring(object.stringAttribute) .. ", " .. tostring(object.numberAttribute) .. ", " .. tostring(object.booleanAttribute) .. ")."
					  )
end


-- 3.2 Auch bei Ausführung eines speziellen Konstruktors werden Werte korrekt initialisiert
function test_3_2()
	Class{"MyClass", stringAttribute = String, numberAttribute = Number, booleanAttribute = Boolean}
	function MyClass:create() end

	local object = MyClass:create()

	return assert(
						object.stringAttribute == "" and object.numberAttribute == 0 and object.booleanAttribute == false,
						"Attribute wurden von speziellem Konstruktor nicht oder nicht korrekt initialisiert (" .. tostring(object.stringAttribute) .. ", " .. tostring(object.numberAttribute) .. ", " .. tostring(object.booleanAttribute) .. ")."
					  )
end


-- 3.3 Deklarierten Attributen können korrekte Werte zugewiesen und wieder gelesen werden und diese sind objektspezifisch
function test_3_3()
	Class{"MyClass", stringAttribute = String, numberAttribute = Number, booleanAttribute = Boolean}

	local objectDefault = MyClass:create()
	local objectAltered = MyClass:create()

	objectAltered.stringAttribute = "Hello World!"
	objectAltered.numberAttribute = 2014
	objectAltered.booleanAttribute = true

	return assert(
						objectDefault.stringAttribute == "" and objectDefault.numberAttribute == 0 and objectDefault.booleanAttribute == false and
							objectAltered.stringAttribute == "Hello World!" and objectAltered.numberAttribute == 2014 and objectAltered.booleanAttribute == true,
						"Das Lesen und Schreiben von objektspezifischen Attributwerten ist fehlgeschlagen "
							.. "(unveränderte Werte: "
							.. tostring(objectDefault.stringAttribute) .. ", " .. tostring(objectDefault.numberAttribute) .. ", " .. tostring(objectDefault.booleanAttribute)
							.. "; veränderte Werte: "
							.. tostring(objectAltered.stringAttribute) .. ", " .. tostring(objectAltered.numberAttribute) .. ", " .. tostring(objectAltered.booleanAttribute)
							.. ")."
					  )
end


-- 3.4 Methoden können an Klassen deklariert werden, stehen an Objekten zur Verfügung
function test_3_4()
	Class{"MyClass"}
	local methodExecuted = false

	function MyClass:doSomething()
		methodExecuted = true
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						methodExecuted == true,
						"Für Klasse deklarierte Methode konnte nicht an Objekt ausgeführt werden."
					  )
end


-- 3.5 Innerhalb von Methoden zeigt die self-Referenz auf das entsprechende Objekt und Parameter sind verwendbar
function test_3_5()
	Class{"MyClass"}

	local referenceInsideMethod = nil
	local p1InsideMethod = false
	local p2InsideMethod = 0

	function MyClass:doSomething( p1, p2 )
		referenceInsideMethod = self
		p1InsideMethod = p1
		p2InsideMethod = p2
	end

	local object = MyClass:create()
	object:doSomething( true, 2014 )

	return assert(
						p1InsideMethod == true and p2InsideMethod == 2014 and referenceInsideMethod == object,
						"Parameter oder self-Referenz in Methode sind nicht korrekt (" .. tostring(p1InsideMethod) .. ", " .. tostring(p2InsideMethod) .. ", " .. tostring(referenceInsideMethod == object) ..")."
					  )
end


-- 3.6 Attributdeklaration mit nicht erlaubtem Namen nicht möglich (Fehler erwartet)
function test_3_6()
	local success, result = pcall(function()
		Class{"MyClass", ["Attribute name with spaces"] = String, [0] = Number, [true] = false}
	end)

	if not success then
		return result
	else
		error("Attribute mit nicht erlaubten Namen konnten deklariert werden." )
	end
end


-- 3.7 Attributdefinition mit definiertem, aber nicht erlaubtem Typ schlägt fehl (Fehler erwartet)
function test_3_7()
	local success, result = pcall(function()
		Class{"MyClass", illegalAttribute = 2014 }
	end)

	if not success then
		return result
	else
		error("Ein Attribut mit nicht erlaubtem Typ konnte deklariert werden.")
	end
end


-- 3.8 Attributzuweisungen mit falschem Typ nicht möglich (Fehler erwartet)
function test_3_8()
	Class{"MyClass", numberAttribute = Number}
	local object = MyClass:create()

	local success, result = pcall(function()
		object.numberAttribute = "Hello World!"
	end)

	if not success then
		return result
	else
		error("Die Zuweisung eines Wertes mit nicht erlaubtem Typ ist möglich." )
	end
end


-- 3.9 Überschreiben von Methoden nicht möglich (Fehler erwartet)
function test_3_9()
	Class{"MyClass"}

	function MyClass:doSomething() end

	local success, result = pcall(function()
		function MyClass:doSomething() end
	end)

	if not success then
		return result
	else
		error("Das Überschreiben einer bereits definierten Funktion ist möglich.")
	end
end


-- 3.10 Zugriff (lesend) auf nicht deklarierte Features an Objekt resultiert in Fehlermeldung (Fehler erwartet)
function test_3_10()
	Class{"MyClass"}
	local object = MyClass:create()

	local success, result = pcall(function()
		return object.nothing
	end)

	if not success then
		return result
	else
		error("Der (lesende) Zugriff auf nicht deklarierte Features an einem Objekt ist möglich.")
	end
end


-- 3.11 Zugriff (schreibend) auf nicht deklarierte Features an Objekt resultiert in Fehlermeldung (Fehler erwartet)
function test_3_11()
	Class{"MyClass"}
	local object = MyClass:create()

	local success, result = pcall(function()
		object.nothing = 2014
	end)

	if not success then
		return result
	else
		error("Der (schreibende) Zugriff auf nicht deklarierte Features an einem Objekt ist möglich.")
	end
end


-- 3.12 Zugriff auf deklarierte Attribute an Klasse nicht möglich (Fehler erwartet)
function test_3_12()
	Class{"MyClass", numberAttribute = Number}

	local success, result = pcall(function()
		return MyClass.numberAttribute
	end)

	if not success then
		return result
	else
		error("Auf Attribute kann an der Klasse zugegriffen werden.")
	end
end


-- 3.13 Zugriff auf deklarierte Attribute an Klasse nicht möglich (Fehler erwartet)
function test_3_13()
	Class{"MyClass", numberAttribute = Number}

	function MyClass:doSomething() end

	local success, result = pcall(function()
		MyClass:doSomething()
	end)

	if not success then
		return result
	else
		error("Auf Methoden kann an der Klasse zugegriffen werden.")
	end
end





-----
----- 4 Referenztypen und Objektreferenzen -----
-----
function test_4()
	return "Referenztypen und Objektreferenzen"
end


-- 4.1 Attributdefinition mit Klassentyp möglich
function test_4_1()
	Class{"MyClass"}
	Class{"MyOther", classAttribute = MyClass}

	return assert(
						_oldtype(MyOther) == 'table',
						"Die Deklaration eines Attributs mit Klassentyp ist nicht möglich."
					  )
end


-- 4.2 Attribut von Klassentyp wird mit nil initialisiert und kann gelesen werden
function test_4_2()
	Class{"MyClass"}
	Class{"MyOther", classAttribute = MyClass}
	local object = MyOther:create()

	-- Test nur sinnvoll, wenn überhaupt auf Deklaration geprüft wird
	local success, result = pcall(function() local a = object.noAttribute end)
	if success then error("Keine Überprüfung auf Deklaration.") end

	return assert(
						object.classAttribute == nil,
						"Ein Attribut mit Klassentyp wird nicht korrekt initialisiert."
					  )
end


-- 4.3 Attributdefinition mit Typ der zu erstellenden Klasse möglich und Attribut wird mit nil initialisiert
function test_4_3()
	Class{"MyClass", classAttribute = MyClass}
	local object = MyClass:create()

	-- Test nur sinnvoll, wenn überhaupt auf Deklaration geprüft wird
	local success, result = pcall(function() local a = object.noAttribute end)
	if success then error("Keine Überprüfung auf Deklaration.") end

	return assert(
						object.classAttribute == nil,
						"Ein Attribut mit Typ der zu erstellenden Klasse kann nicht deklariert werden oder wird nicht korrekt initialisiert."
					  )
end


-- 4.4 Ein typkonformer Wert kann zugewiesen und wieder gelesen werden
function test_4_4()
	Class{"MyClass"}
	Class{"MyOther", classAttribute = MyClass}
	local objectClass = MyClass:create()
	local objectOther = MyOther:create()

	-- Test nur sinnvoll, wenn Deklaration irgendwie geprüft wird
	local success, result = pcall(function() objectOther.noAttribute = objectClass end)
	if success then error("Keine Überprüfung auf Deklaration.") end

	objectOther.classAttribute = objectClass

	return assert(
						objectOther.classAttribute == objectClass,
						"Ein typkonformer Wert konnte nicht zugewiesen oder nicht wieder gelesen werden."
					  )
end


-- 4.5 Ein typkonformer Wert (eigene Klasse) kann zugewiesen und wieder gelesen werden
function test_4_5()
	Class{"MyClass", classAttribute = MyClass}
	local object = MyClass:create()

	-- Test nur sinnvoll, wenn Deklaration irgendwie geprüft wird
	local success, result = pcall(function() object.noAttribute = object end)
	if success then error("Keine Überprüfung auf Deklaration.") end

	object.classAttribute = object

	return assert(
						object.classAttribute == object,
						"Ein typkonformer Wert (eigene Klasse) konnte nicht zugewiesen oder nicht wieder gelesen werden."
					  )
end


-- 4.6 Attribut kann wieder auf nil gesetzt werden
function test_4_6()
	Class{"MyClass"}
	Class{"MyOther", classAttribute = MyClass}
	local objectClass = MyClass:create()
	local objectOther = MyOther:create()

	objectOther.classAttribute = objectClass
	objectOther.classAttribute = nil

	return assert(
						objectOther.classAttribute == nil,
						"Einem Attribut mit Typ einer Klasse kann nicht der Wert 'nil' zugewiesen werden."
					  )
end


-- 4.7 Attributdefinition mit undefinierter Variable nicht möglich (Fehler erwartet)
function test_4_7()
	local success, result = pcall(function()
		Class{"MyClass", unknownAttribute = unknownType}
	end)

	if not success then
		return result
	else
		error("Deklaration eines Attributs mit nicht definiertem Typ ist möglich.")
	end
end


-- 4.8 Zuweisung bei Klassentyp mit unzulässigem Wert resultiert in Fehlermeldung (Fehler erwartet)
function test_4_8()
	Class{"MyClass"}
	Class{"MyOther", classAttribute = MyClass}

	local object = MyOther:create()

	local success, result = pcall(function()
		object.classAttribute = 2014
	end)

	if not success then
		return result
	else
		error("Einem Attribut mit Klassentyp kann ein Wert mit nicht konformem Typ zugewiesen werden.")
	end
end


-- 4.9 Zuweisung bei Typ der eigenen Klasse mit unzulässigem Wert resultiert in Fehlermeldung (Fehler erwartet)
function test_4_9()
	Class{"MyClass", classAttribute = MyClass}

	local object = MyClass:create()

	local success, result = pcall(function()
		object.classAttribute = true
	end)

	if not success then
		return result
	else
		error("Einem Attribut mit Klassentyp (eigene Klasse) kann ein Wert mit nicht konformem Typ zugewiesen werden.")
	end
end





------------------------------------------------------

-- Hilfsfunktion um die entsprechende Testfunktion aufzurufen und das Ergebnis als print-Ausgabe darzustellen

if not _testframework then
	local name = "Test " .. major .. "."..minor
	local testmethod = _G["test_"..major.."_"..minor]

	-- Die Ausführung der entsprechenden Methode
	local success, result = pcall( testmethod )

	-- Falls Rückgabe 'true', dann war der Test erfolgreich (Test eines Positivfalls)
	if success and result == true then
		print(name .. ": OK")
	-- Falls kein Fehler, aber Rückgabe nicht 'true', dann manuelle Überprüfung (Test eines Fehlerfalls, Rückgabe ist Text der Fehlermeldung)
	elseif success then
		print(name .. ": VALUE/MESSAGE", "--->", result)
	-- Sonst Fehler, Test nicht erfolgreich (Test eines Positivfalls oder eines Fehlerfalls)
	else
		print(name .. ": FAILED", "--->", result)
	end
end

------------------------------------------------------

