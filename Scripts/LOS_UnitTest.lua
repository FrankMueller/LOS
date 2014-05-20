require("LOS_gruppe22")


function RunTest(testDescription, testFunction, expectedResult)
	print("--> " .. testDescription)

	local status, error = pcall(testFunction)

	if (status == false) then
		print("--> Call resulted in an error: '" .. error .. "'")
	end

	if (status == expectedResult) then
		print("> Passed")
	else
		print("> Failed")
	end

	print()
end


--Test 1: Simple class test
--=========================
function SimpleClassTest()
	Class{ "Cat" }
	function Cat:meow( )
	  print("Meow!")
	end

	kitty = Cat:create( )
	kitty:meow()							--> Meow!
end
RunTest("Test 1: Simple class test", SimpleClassTest, true)


--Test 2: Class with attributes and custom constructor
--====================================================
function FullClassTest()
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

	puppy = Dog:create("Puppy")
	puppy:bark()							--> Puppy: Woof!
	print()

	puppy:setFriend(kitty)
	puppy:bark()							--> Puppy: Woof!
										--> Meow!
end
RunTest("Test 2: Class with attributes and custom constructor", FullClassTest, true)


--Test 3: Call of an unknown method
--=================================
local function CallOfUnknownMethodTest()
	puppy:dance()
end
RunTest("Test 3: Call of an unknown method", FullClassTest, false)


--Test 4: Assignment of an unknown attributes
--===========================================
local function AssignmentOfValueWithWrongType()
	puppy.name = false
end
RunTest("Test 4: Assignment of a value with a wrong type", AssignmentOfValueWithWrongType, false)


--Test 5: Use of an unknown type for an attribute
--===============================================
local function UnknownTypeTest()
	Class{"Mouse", enemy = Elephant}
	return Mouse
end
RunTest("Test 5: Use of an unknown type for an attribute", UnknownTypeTest, false)


--Test 6: Use of a class name with blanks
--=======================================
local function BlankInClassnameTest()
	Class{"Kitty cat"}
end
RunTest("Test 6: Use of a class name with blanks", BlankInClassnameTest, false)


--Test 7: Use of an empty class name
--==================================
local function EmptyClassnameTest()
	Class{""}
end
RunTest("Test 7: Use of an empty class name", EmptyClassnameTest, false)


--Test 8: Invalid attribute declaration
--=====================================
local function InvalidAttributeTest()
	Class{"Test", attribute1 = 5}
end
RunTest("Test 8: Invalid attribute declaration", InvalidAttributeTest, false)


--Test 9: Add method to object
--============================
local function AddMethodToObjectTest()
	function puppy:walk(steps)
		print("walking ", steps, " steps")
	end
end
RunTest("Test 9: Add method to object", AddMethodToObjectTest, false)


--Test 10: Change method of object
--================================
local function ChangeMethodOfObjectTest()
	function puppy:bark()
		print("barking")
	end
end
RunTest("Test 10: Change method of object", ChangeMethodOfObjectTest, false)


--Test 11: Add attribut to object
--==============================
local function AddAttributeToObjectTest()
	puppy.weight = 10
end
RunTest("Test 11: Add attribut to object", AddAttributeToObjectTest, false)


--Test 12: Add attribut to class
--==============================
local function AddAttributeToClassTest()
	Dog.weight = Number
end
RunTest("Test 12: Add attribut to class", AddAttributeToClassTest, false)
