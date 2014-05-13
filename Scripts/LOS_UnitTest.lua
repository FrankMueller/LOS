require("LOS_gruppe22")


--Test 1: Simple class test
--=========================
print("Test 1: Simple class test")
Class{ "Cat" }
function Cat:meow( )
  print("Meow!")
end

kitty = Cat:create( )
kitty:meow()							--> Meow!
print()


--Test 2: Class with attributes and custom constructor
--====================================================
print("Test 2: Class with attributes and custom constructor")
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
print()


--Test 3: Call of an unknown method
--=================================
print("Test 3: Call of an unknown method")
local function CallOfUnknownMethodTest()
	puppy:dance()
end
print(pcall(CallOfUnknownMethodTest))


--Test 4: Assignment of an unknown attributes
--===========================================
print("Test 4: Assignment of an unknown attributes")
local function AssignmentOfUnknownAttributeTest()
	puppy.name = false
end
print(pcall(AssignmentOfUnknownAttributeTest))


--Test 5: Use of an unknown type for an attribute
--===============================================
print("Test 5: Use of an unknown type for an attribute")
local function UnknownTypeTest()
	Class{"Mouse", enemy = Elephant}
	return Mouse
end
print(pcall(UnknownTypeTest))


--Test 6: Use of a class name with blanks
--=======================================
print("Test 6: Use of a class name with blanks")
local function BlankInClassnameTest()
	Class{"Kitty cat"}
end
print(pcall(BlankInClassnameTest))


--Test 7: Use of an empty class name
--==================================
print("Test 7: Use of an empty class name")
local function EmptyClassnameTest()
	Class{""}
end
print(pcall(EmptyClassnameTest))


--Test 8: Invalid attribute declaration
--=====================================
print("Test 8: Invalid attribute declaration")
local function InvalidAttributeTest()
	Class{"Test", attribute1 = 5}
end
print(pcall(InvalidAttributeTest))


--Test 9: Add method to object
--============================
print("Test 9: Add method to object")
local function AddMethodToObjectTest()
	function puppy:walk(steps)
		print("walking ", steps, " steps")
	end
end
print(pcall(AddMethodToObjectTest))


--Test 10: Change method of object
--================================
print("Test 10: Change method of object")
local function ChangeMethodOfObjectTest()
	function puppy:bark()
		print("barking")
	end
end
print(pcall(ChangeMethodOfObjectTest))


--Test 11: Add attribut to object
--==============================
print("Test 11: Add attribut to object")
local function AddAttributeToObjectTest()
	puppy.weight = 10
end
print(pcall(AddAttributeToObjectTest))


--Test 12: Add attribut to class
--==============================
print("Test 12: Add attribut to class")
local function AddAttributeToClassTest()
	Dog.weight = Number
end
print(pcall(AddAttributeToClassTest))
