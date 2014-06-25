
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
--		uebung2_bewertungstest.lua major minor
--
--	Runs the test case with the given number ("uebung2_bewertungstest.lua 2 1" --> Test 2.1) and prints
--		- OK, if the test was successfull
--		- VALUE/MESSAGE and the return value, if the test's result requires a manual check
--		- FAILED, if the test failed
--

if not _testframework then

	-- Die 'type'-Funktion wird eventuell in der LOS-Implementierung überschrieben, daher vorher gespeichert.
	_oldtype = type
	require("LOS_gruppe22")

	major = arg[1] or 3
	minor = arg[2] or 13

end

------------------------------------------------------





-----
----- 1 Allgemein -----
-----
function test_1()
	return "Allgemein"
end


-- 1.1 LOS gibt im Fehlerfall eigene, aussagekräftige Meldungen aus
function test_1_1()
	return "Aus den weiteren Tests ersichtlich."
end


-- 1.2 LOS produziert keine eigenen Ausgaben, falls kein Fehler vorliegt
function test_1_2()
	return "Aus den weiteren Tests ersichtlich."
end





-----
----- 2 Vererbung -----
-----
function test_2()
	return "Vererbung"
end


-- 2.1 Class kann mit optionalem Argument für Oberklasse verwendet werden
function test_2_1()
	Class{"SuperClass"}
	Class{"MyClass", SuperClass}

	return assert(
						type(SuperClass) == 'table' and type(MyClass) == 'table',
						"Das optionale Argument für eine Oberklasse in der Klassendefinition kann nicht korrekt verwendet werden."
					  )
end


-- 2.2 Attribute aus Oberklassen (direkt) sind an Instanzen der Unterklasse verwendbar
function test_2_2()
	Class{"MySuper", numberAttribute = Number}
	Class{"MyClass", MySuper}

	local object = MyClass:create()
	local defaultValue = object.numberAttribute

	object.numberAttribute = 2014
	local alteredValue = object.numberAttribute

	return assert(
						defaultValue == 0 and alteredValue == 2014,
						"Ein in der Oberklasse (direkt) deklariertes Attribut kann nicht an Instanzen der Unterklassen verwendet werden (Initial: " .. tostring(defaultValue) .. "; altered: " .. tostring(alteredValue) .. ")."
					  )
end


-- 2.3 Attribute aus Oberklassen (indirekt) sind an Instanzen der Unterklasse verwendbar
function test_2_3()
	Class{"MySuper", numberAttribute = Number}
	Class{"MyInter", MySuper}
	Class{"MyClass", MyInter}

	local object = MyClass:create()
	local defaultValue = object.numberAttribute

	object.numberAttribute = 2014
	local alteredValue = object.numberAttribute

	return assert(
						defaultValue == 0 and alteredValue == 2014,
						"Ein in der Oberklasse (indirekt) deklariertes Attribut kann nicht an Instanzen der Unterklassen verwendet werden (Initial: " .. tostring(defaultValue) .. "; altered: " .. tostring(alteredValue) .. ")."
					  )
end


-- 2.4 Zuweisung mit Unterklassen (direkt) des deklarierten Typs möglich
function test_2_4()
	Class{"MySuper"}
	Class{"MyClass", MySuper}

	Class{"MyOther", myAttribute = MySuper}

	local objectOther = MyOther:create()
	local objectMy = MyClass:create()

	objectOther.myAttribute = objectMy

	return assert(
						objectOther.myAttribute == objectMy,
						"Zuweisung eines Wertes mit konformem Subtyp (direkt) nicht möglich."
					  )
end


-- 2.5 Zuweisung mit Unterklassen (indirekt) des deklarierten Typs möglich
function test_2_5()
	Class{"MySuper"}
	Class{"MyInter", MySuper}
	Class{"MyClass", MyInter}

	Class{"MyOther", myAttribute = MySuper}

	local objectOther = MyOther:create()
	local objectMy = MyClass:create()

	objectOther.myAttribute = objectMy

	return assert(
						objectOther.myAttribute == objectMy,
						"Zuweisung eines Wertes mit konformem Subtyp (indirekt) nicht möglich."
					  )
end


-- 2.6 Zugriff auf Methoden der Oberklassen (direkt) ist möglich
function test_2_6()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething( param )
		methodExecuted = param
		return 2014
	end

	Class{"MyClass", MySuper}
	local object = MyClass:create()
	local returnValue = object:doSomething( true )

	return assert(
						methodExecuted == true and returnValue == 2014,
						"Der Zugriff auf in einer Oberklasse (direkt) deklarierte Methoden ist nicht möglich (" .. tostring(methodExecuted) .. ", " .. tostring(returnValue) .. ")."
					  )
end


-- 2.7 Zugriff auf Methoden der Oberklassen (indirekt) ist möglich
function test_2_7()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething( param )
		methodExecuted = param
		return 2014
	end

	Class{"MyInter", MySuper}
	Class{"MyClass", MyInter}
	local object = MyClass:create()
	local returnValue = object:doSomething( true )

	return assert(
						methodExecuted == true and returnValue == 2014,
						"Der Zugriff auf in einer Oberklasse (indirekt) deklarierte Methoden ist nicht möglich (" .. tostring(methodExecuted) .. ", " .. tostring(returnValue) .. ")."
					  )
end


-- 2.8 Überschreiben von Methoden ist möglich, korrekter Zugriff auf überschriebene Methode
function test_2_8()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething() end

	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		methodExecuted = true
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						methodExecuted == true,
						"Es wird nicht die überschriebene Methode ausgeführt."
					  )
end


-- 2.9 Bei überschriebenen Methoden wird die jeweils speziellste ausgeführt (Dynamisches Binden)
function test_2_9()
	local methodValue = 0

	Class{"MySuper"}
	function MySuper:setValue()
		methodValue = 42
	end
	function MySuper:doSomething()
		self:setValue()
	end

	Class{"MyClass", MySuper}
	function MyClass:setValue()
		methodValue = 2014
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						methodValue == 2014,
						"Die überschreibende Version einer Methode wird nicht ausgeführt (" .. tostring(methodValue) .. ")."
					  )
end


-- 2.10 Konstruktoren werden geerbt (direkte Oberklassen) und können überschrieben werden
function test_2_10()
	local methodExecuted = false
	local specializedValue = 0

	Class{"MySuper"}
	function MySuper:create( param )
		methodExecuted = param
	end

	Class{"MyClass", MySuper}
	local object = MyClass:create( true )

	function MyClass:create( param )
		specializedValue = param
	end
	object = MyClass:create( 2014 )


	return assert(
						methodExecuted == true and specializedValue == 2014,
						"Ein spezieller Konstruktor wurde nicht aus der (direkten) Oberklasse geerbt (" .. tostring(methodExecuted) .. ", " .. tostring(specializedValue) .. ")."
					  )
end


-- 2.11 Konstruktoren werden geerbt (indirekte Oberklassen) und können überschrieben werden
function test_2_11()
	local methodExecuted = false
	local specializedValue = 0

	Class{"MySuper"}
	function MySuper:create( param )
		methodExecuted = param
	end

	Class{"MyInter", MySuper}
	Class{"MyClass", MyInter}
	local object = MyClass:create( true )

	function MyClass:create( param )
		specializedValue = param
	end
	object = MyClass:create( 2014 )

	return assert(
						methodExecuted == true and specializedValue == 2014,
						"Ein spezieller Konstruktor wurde nicht aus der (indirekten) Oberklasse geerbt (" .. tostring(methodExecuted) .. ", " .. tostring(specializedValue) .. ")."
					  )
end


-- 2.12 Ungültiges Argument für Oberklasse (Number) führt zu Fehlermeldung
function test_2_12()
	local success, result = pcall(function()
		Class{"MyClass", Number}
	end)

	if not success then
		return result
	else
		error("Eine Klasse mit nicht erlaubter Oberklasse (Number) kann definiert werden.")
	end
end


-- 2.13 Ungültiges Argument für Oberklasse (leere table) führt zu Fehlermeldung
function test_2_13()
	local success, result = pcall(function()
		Class{"MyClass", {} }
	end)

	if not success then
		return result
	else
		error("Eine Klasse mit nicht erlaubter Oberklasse (leere table) kann definiert werden.")
	end
end


-- 2.14 Attributsdeklaration (direkte Oberklasse) darf nicht überschrieben werden
function test_2_14()
	Class{"MySuper", numberAttribute = Number}

	local success, result = pcall(function()
		Class{"MyClass", MySuper, numberAttribute = String}
	end)

	if not success then
		return result
	else
		error("Attribute aus (direkten) Oberklassen können überschrieben werden.")
	end
end


-- 2.15 Attributsdeklaration (indirekte Oberklasse) darf nicht überschrieben werden
function test_2_15()
	Class{"MySuper", numberAttribute = Number}
	Class{"MyInter", MySuper}

	local success, result = pcall(function()
		Class{"MyClass", MyInter, numberAttribute = String}
	end)

	if not success then
		return result
	else
		error("Attribute aus (indirekten) Oberklassen können überschrieben werden.")
	end
end


-- 2.16 Zuweisung mit Oberklassen des deklarierten Typs nicht möglich
function test_2_16()
	Class{"MySuper"}
	Class{"MyClass", MySuper}

	Class{"MyOther", myAttribute = MyClass}

	local objectOther = MyOther:create()
	local objectSuper = MySuper:create()

	local success, result = pcall(function()
		objectOther.myAttribute = objectSuper
	end)

	if not success then
		return result
	else
		error("Zuweisung eines Wertes vom Typ einer Oberklasse des deklarierten Typs möglich.")
	end
end


-- 2.17 Zugriff auf Methoden der Unterklassen nicht möglich
function test_2_17()
	Class{"MySuper"}
	Class{"MyClass", MySuper}
	function MyClass:doSomething() end
	local object = MySuper:create()

	local success, result = pcall(function()
		object:doSomething()
	end)

	if not success then
		return result
	else
		error("Zugriff auf Methoden einer Unterklasse möglich.")
	end
end


-- 2.18 Zugriff auf Attribute der Unterklassen nicht möglich
function test_2_18()
	Class{"MySuper"}
	Class{"MyClass", MySuper, numberAttribute = Number}
	local object = MySuper:create()

	local success, result = pcall(function()
		object.numberAttribute = 2014
	end)

	if not success then
		return result
	else
		error("Zugriff auf Attribute einer Unterklasse möglich.")
	end
end





-----
----- 3 super-Aufrufe -----
-----
function test_3()
	return "super-Aufrufe"
end


-- 3.1 Die richtigen Methode der Oberklasse (direkt) wird aufgerufen
function test_3_1()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething( param )
		methodExecuted = param
		return 2014
	end

	Class{"MyClass", MySuper}
	function MyClass:doSomething( param )
		return super:doSomething( param )
	end

	local object = MyClass:create()
	local returnValue = object:doSomething( true )

	return assert(
						methodExecuted == true and returnValue == 2014,
						"Bei einem super-Aufruf wurde nicht die korrekte Methode der (direkten) Oberklasse ausgeführt (" .. tostring(methodExecuted) .. ", " .. tostring(returnValue) .. ")."
					  )
end


-- 3.2 Die richtigen Methode der Oberklasse (indirekt) wird aufgerufen
function test_3_2()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething( param )
		methodExecuted = param
		return 2014
	end

	Class{"MyInter", MySuper}

	Class{"MyClass", MyInter}
	function MyClass:doSomething( param )
		return super:doSomething( param )
	end

	local object = MyClass:create()
	local returnValue = object:doSomething( true )

	return assert(
						methodExecuted == true and returnValue == 2014,
						"Bei einem super-Aufruf wurde nicht die korrekte Methode der (direkten) Oberklasse ausgeführt (" .. tostring(methodExecuted) .. ", " .. tostring(returnValue) .. ")."
					  )
end


-- 3.3 Innerhalb der aufgerufenen Methode der Oberklasse ist die self-Referenz korrekt
function test_3_3()
	local selfInsideMethod = false

	Class{"MySuper"}
	function MySuper:doSomething()
		selfInsideMethod = self
	end

	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		super:doSomething()
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						selfInsideMethod == object,
						"Die self-Referenz in einem super-Aufruf ist nicht korrekt."
					  )
end


-- 3.4 Innerhalb der aufgerufenen Methode der Oberklasse können in der Unterklasse überschriebene Methoden korrekt aufgerufen werden
function test_3_4()
	local methodValue = 0

	Class{"MySuper"}
	function MySuper:setValue()
		methodValue = 42
	end
	function MySuper:doSomething()
		self:setValue()
	end

	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		super:doSomething()
	end
	function MyClass:setValue()
		methodValue = 2014
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						methodValue == 2014,
						"Dynamisches Binden innerhalb von super-Aufrufen ist nicht erfolgreich."
					  )
end


-- 3.5 Innerhalb von super-Aufrufen sind weitere super-Aufrufe möglich (weiter in Hierarchie)
function test_3_5()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:doSomething()
		methodExecuted = true
	end

	Class{"MyInter", MySuper}
	function MyInter:doSomething()
		super:doSomething()
	end

	Class{"MyClass", MyInter}
	function MyClass:doSomething()
		super:doSomething()
	end

	local object = MyClass:create()
	object:doSomething()

	return assert(
						methodExecuted == true,
						"Ein super-Aufruf innerhalb eines super-Aufrufs ist nicht korrekt möglich."
					  )
end


-- 3.6 Innerhalb von super-Aufrufen sind weitere super-Aufrufe möglich (an mehreren Objekten)
function test_3_6()
	local myExecuted = false
	local otherExecuted = false

	Class{"MyOther"}
	function MyOther:doSomethingElse()
		otherExecuted = true
	end

	Class{"MySub", MyOther}
	function MySub:doSomethingElse()
		super:doSomethingElse()
	end

	Class{"MySuper", myAttribute = MySub}
	function MySuper:doSomething()
		myExecuted = true
	end

	Class{"MyInter", MySuper}
	function MyInter:doSomething()
		self.myAttribute:doSomethingElse()
		super:doSomething()
	end

	Class{"MyClass", MyInter}
	function MyClass:doSomething()
		super:doSomething()
	end

	local myObject = MyClass:create()
	local otherObject = MySub:create()
	myObject.myAttribute = otherObject
	myObject:doSomething()

	return assert(
						myExecuted == true and otherExecuted == true,
						"Ein super-Aufruf innerhalb eines super-Aufrufs ist nicht korrekt möglich."
					  )
end



-- 3.7 Innerhalb von Konstruktoren kann eine create-Methode der Oberklasse (direkt) aufgerufen werden.
function test_3_7()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:create()
		methodExecuted = true
	end

	Class{"MyClass", MySuper}
	function MyClass:create()
		super:create()
	end

	local object = MyClass:create()

	return assert(
						methodExecuted == true,
						"Innerhalb eines Konstruktors kann kein Konstruktor der Superklasse aufgerufen werden."
					  )
end


-- 3.8 Innerhalb von Konstruktoren kann eine create-Methode der Oberklasse (indirekt) aufgerufen werden.
function test_3_8()
	local methodExecuted = false

	Class{"MySuper"}
	function MySuper:create()
		methodExecuted = true
	end

	Class{"MyInter", MySuper}

	Class{"MyClass", MyInter}
	function MyClass:create()
		super:create()
	end

	local object = MyClass:create()

	return assert(
						methodExecuted == true,
						"Innerhalb eines Konstruktors kann kein Konstruktor der Superklasse aufgerufen werden."
					  )
end


-- 3.9 Innerhalb von Konstruktoren können sowohl create-Methoden der Oberklasse als auch andere Methoden der Oberklasse aufgerufen werden (korrekte self-Referenzen)
function test_3_9()
	local methodSelf = false
	local createSelf = false

	Class{"MySuper"}
	function MySuper:create()
		createSelf = self
	end
	function MySuper:doSomething()
		methodSelf = self
	end

	Class{"MyClass", MySuper}
	function MyClass:create()
		super:create()
		super:doSomething()
	end

	local object = MyClass:create()

	return assert(
						methodSelf == object and createSelf == object,
						"Innerhalb eines Konstruktors ist die self-Referenz in super-Aufrufen nicht korrekt (Methode: " .. tostring(methodSelf == object) .. ", Konstruktor:" .. tostring(createSelf == object) .. ")."
					  )
end


-- 3.10 Ein super-Aufruf ohne Oberklasse führt zu einer Fehlermeldung
function test_3_10()
	Class{"MyClass"}
	function MyClass:doSomething()
		super:doSomething()
	end
	local object = MyClass:create()

	local success, result = pcall(function()
		object:doSomething()
	end)

	if not success then
		return result
	else
		error("Ein super-Aufruf ohne gültige Oberklasse war erfolgreich.")
	end
end


-- 3.11 Ein super-Aufruf mit Oberklasse ohne entsprechende Methode führt zu einer Fehlermeldung
function test_3_11()
	Class{"MySuper"}
	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		super:doSomething()
	end
	local object = MyClass:create()

	local success, result = pcall(function()
		object:doSomething()
	end)

	if not success then
		return result
	else
		error("Ein super-Aufruf ohne entsprechende Methode in der Oberklasse war erfolgreich.")
	end
end


-- 3.12 Ein super-Aufruf außerhalb einer erlaubten Methoden (außerhalb aller Methoden) führt zu einer Fehlermeldung
function test_3_12()
	Class{"MySuper"}
	function MySuper:doSomething() end

	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		super:doSomething()
	end

	local object = MyClass:create()
	object:doSomething()

	local success, result = pcall(function()
		super:doSomething()
	end)

	if not success then
		return result
	else
		error("Ein super-Aufruf außerhalb von Methoden ist möglich.")
	end
end


-- 3.13 Ein super-Aufruf außerhalb einer erlaubten Methoden (Konstruktoraufruf außerhalb eines Konstruktors) führt zu einer Fehlermeldung
function test_3_13()
	Class{"MySuper"}
	function MySuper:create() end

	Class{"MyClass", MySuper}
	function MyClass:doSomething()
		super:create()
	end

	local object = MyClass:create()

	local success, result = pcall(function()
		object:doSomething()
	end)

	if not success then
		return result
	else
		error("Der Aufruf eines super-Konstruktors außerhalb eines Konstruktors ist möglich.")
	end
end





-----
----- 4 Aufzählungstypen -----
-----
function test_4()
	return "Aufzählungstypen"
end


-- 4.1 Definition (ohne default-Wert) möglich, global verfügbar
function test_4_1()
	Enum{"MyEnum", {'value1', 'value2', 'value3'} }

	return assert(
						MyEnum ~= nil,
						"Ein korrekt definierte Aufzählungstyp (ohne default-Wert) ist nicht global verfügbar."
					  )
end


-- 4.2 Definition (mit default-Wert) möglich, global verfügbar
function test_4_2()
	Enum{"MyEnum", {'value1', 'value2', default='value3'} }

	return assert(
						MyEnum ~= nil,
						"Ein korrekt definierte Aufzählungstyp (mit default-Wert) ist nicht global verfügbar."
					  )
end


-- 4.3 Auf Werte (ohne default-Wert) kann mit Punktnotation zugegriffen werden
function test_4_3()
	Enum{"MyEnum", {'value1', 'value2', 'value3'} }

	return assert(
						MyEnum.value1 ~= nil,
						"Zugriff mittels Punktnotation nicht möglich (".. tostring(MyEnum.value1) .. ")."
					  )
end


-- 4.4 Auf Werte (mit default-Wert) kann mit Punktnotation zugegriffen werden
function test_4_4()
	Enum{"MyEnum", {'value1', 'value2', default='value3'} }

	return assert(
						MyEnum.value3 ~= nil,
						"Zugriff mittels Punktnotation auf default-Wert nicht möglich (".. tostring(MyEnum.value3) .. ")."
					  )
end


-- 4.5 Vergleiche zwischen Werten korrekt
function test_4_5()
	Enum{"MyEnum", {'value1', 'value2', default = 'value3'} }
	Enum{"OtherEnum", {'value1', 'value2'} }

	local sameValue = MyEnum.value1 == MyEnum.value1
	local otherValue = MyEnum.value1 == MyEnum.value2
	local otherEnum = MyEnum.value1 == OtherEnum.value1
	local stringValue = MyEnum.value1 == "value1"

	return assert(
						sameValue and not otherValue and not otherEnum and not stringValue,
						"Vergleiche mit Werten von Aufzählungstypen sind nicht korrekt (" .. tostring(sameValue) .. ", " .. tostring(otherValue) .. ", " .. tostring(otherEnum) .. ", " .. tostring(stringValue) .. ")."
					  )
end


-- 4.6 Typen und Werte haben tostring-Repräsentation
function test_4_6()
	Enum{"MyEnum", {'value1', 'value2', default = 'value3'} }

	local enumString = tostring(MyEnum)
	local valueString = tostring(MyEnum.value1)

	return assert(
						enumString == 'MyEnum' and valueString == 'value1',
						"Aufzählungstypen oder deren Werte haben keine korrekte tostring-Repräsentation (" .. enumString .. ", " .. valueString .. ")."
					  )
end


-- 4.7 Initialisierung als Attribut korrekt (ohne/mit default-Wert)
function test_4_7()
	Enum{"MyEnum", {'value1', 'value2', 'value3'} }
	Class{"MyClass", enumAttribute = MyEnum}

	local object = MyClass:create()

	return assert(
						object.enumAttribute == MyEnum.value1,
						"Die Initialisierung von Attributen (Aufzählungstyp, ohne default-Wert) ist nicht korrekt."
					  )
end


-- 4.8 Initialisierung als Attribut korrekt (mit default-Wert)
function test_4_8()
	Enum{"MyEnum", {'value1', 'value2', default = 'value3'} }
	Class{"MyClass", enumAttribute = MyEnum}

	local object = MyClass:create()

	return assert(
						object.enumAttribute == MyEnum.value3,
						"Die Initialisierung von Attributen (Aufzählungstyp, mit default-Wert) ist nicht korrekt."
					  )
end


-- 4.9 Erlaubte Werte können einem Attribut zugewiesen und wieder gelesen werden
function test_4_9()
	Enum{"MyEnum", {'value1', 'value2', 'value3'} }
	Class{"MyClass", enumAttribute = MyEnum}

	local object = MyClass:create()
	object.enumAttribute = MyEnum.value2

	return assert(
						object.enumAttribute == MyEnum.value2,
						"Einem Attribut mit Aufzählungstyp konnte ein korrekter Wert nicht zugewiesen und wieder gelesen werden."
					  )
end


-- 4.10 Korrektheit der Definition wird geprüft (Name des Typs)
function test_4_10()
	local success, result = pcall(function()
		Enum{"My Enum", {'value1', 'value2'} }
	end)

	if not success then
		return result
	else
		error("Ein Aufzählungstyp mit unzulässigem Namen konnte definiert werden.")
	end
end


-- 4.11 Korrektheit der Definition wird geprüft (Name eines Werts)
function test_4_11()
	local success, result = pcall(function()
		Enum{"MyEnum", {'value1', 'value 2'} }
	end)

	if not success then
		return result
	else
		error("Ein Aufzählungstyp mit unzulässigem Wert konnte definiert werden.")
	end
end


-- 4.12 Korrektheit der Definition wird geprüft (keine Werte)
function test_4_12()
	local success, result = pcall(function()
		Enum{"MyEnum", { } }
	end)

	if not success then
		return result
	else
		error("Ein Aufzählungstyp ohne Werte konnte definiert werden.")
	end
end


-- 4.13 Korrektheit der Definition wird geprüft (Doppelter Wert)
function test_4_13()
	local success, result = pcall(function()
		Enum{"MyEnum", {'value1', 'value1'} }
	end)

	if not success then
		return result
	else
		error("Ein Aufzählungstyp mit doppelten Werten konnte definiert werden.")
	end
end


-- 4.14 Attributen kann kein unzulässiger Wert zugewiesen werden (String)
function test_4_14()
	Enum{"MyEnum", {'value1', 'value2'} }
	Class{"MyClass", enumAttribute = MyEnum}
	local object = MyClass:create()

	local success, result = pcall(function()
		object.enumAttribute = "value1"
	end)

	if not success then
		return result
	else
		error("Einem Attribut mit Aufzählungstyp kann ein unzulässiger Wert (String) zugewiesen werden.")
	end
end


-- 4.15 Attributen kann kein unzulässiger Wert zugewiesen werden (nil)
function test_4_15()
	Enum{"MyEnum", {'value1', 'value2'} }
	Class{"MyClass", enumAttribute = MyEnum}
	local object = MyClass:create()

	local success, result = pcall(function()
		object.enumAttribute = nil
	end)

	if not success then
		return result
	else
		error("Einem Attribut mit Aufzählungstyp kann ein unzulässiger Wert (nil) zugewiesen werden.")
	end
end


-- 4.16 Attributen kann kein unzulässiger Wert zugewiesen werden (anderer Aufzählungstyp)
function test_4_16()
	Enum{"MyEnum", {'value1', 'value2'} }
	Enum{"OtherEnum", {'value1', 'value2'} }
	Class{"MyClass", enumAttribute = MyEnum}
	local object = MyClass:create()

	local success, result = pcall(function()
		object.enumAttribute = OtherEnum.value1
	end)

	if not success then
		return result
	else
		error("Einem Attribut mit Aufzählungstyp kann ein unzulässiger Wert (anderer Aufzählungstyp) zugewiesen werden.")
	end
end


-- 4.17 Zugriff auf nicht-definitierte Werte eines Aufzählungstyps nicht möglich
function test_4_17()
	Enum{"MyEnum", {'value1', 'value2'} }

	local success, result = pcall(function()
		local mysteriousValue = MyEnum.value3
	end)

	if not success then
		return result
	else
		error("Der Zugriff auf nicht existierende Werte eines Aufzählungstyps ist möglich (" .. tostring(mysteriousValue) .. ").")
	end
end





------------------------------------------------------

-- Hilfsfunktion um die entsprechende Testfunktion aufzurufen und das Ergebnis als print-Ausgabe darzustellen

if major and minor then
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

