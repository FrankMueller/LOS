require "LOS_UnitTest"

--Simple class test
function SimpleClassTest()
	Class{ "Cat" }
	function Cat:meow( )
		print("Meow!")
	end

	kitty = Cat:create( )
	kitty:meow()							--> Meow!
end
RunTest("Simple class test", SimpleClassTest, false)


--Class with attributes and custom constructor test
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
RunTest("Class with attributes and custom constructor", FullClassTest, false)

--Class with multiple custom constructors test
function ClassWithMultipleConstructorsTest()
	Class{'Grizzly', name = String, age = Number}
	function Grizzly:create(name)
		self.name = name
	end
	function Grizzly:create(name, age)
		self.name = name
		self.age = age
	end
end
RunTest("Class with multiple custom constructors", ClassWithMultipleConstructorsTest, true)

--Attribute initialization test
function AttributeInitializationTest()
	Class{'Sheep', Name = String, Weight = Number, HasToBeSheared = Boolean, Daddy = Sheep }

	local shawn = Sheep:create()
	assert(shawn.Name == "")
	assert(shawn.Weight == 0)
	assert(shawn.HasToBeSheared == false)
	assert(shawn.Daddy == nil)
end
RunTest("Attribute initialization test", AttributeInitializationTest, false)

--Attribute nil test
RunTest("String attribute nil assignment test", function() local shawn = Sheep:create() shawn.Name = nil end, true)
RunTest("Number attribute nil assignment test", function() local shawn = Sheep:create() shawn.Weight = nil end, true)
RunTest("Boolean attribute nil assignment test", function() local shawn = Sheep:create() shawn.HasToBeSheared = nil end, true)
RunTest("Class attribute nil assignment test", function() local shawn = Sheep:create() shawn.Daddy = nil end, false)

--Call of constructor on an object
RunTest("Call of constructor on an object", function() puppy:create("test") end, true)

--Call of an unknown method
RunTest("Call of an unknown method", function() puppy:dance() end, true)
RunTest("Call of an unknown attribute", function() print(puppy.Age) end, true)

--Assignment of an unknown attributes
RunTest("Assignment of a value with a wrong type", function() puppy.name = false end, true)

--Use of class itself as attribute type
RunTest("Use of class itself as attribute type", function() Class{"Mouse", father = Mouse} end, false)

--Use of an unknown type for an attribute
RunTest("Use of an unknown type for an attribute", function() Class{"Mouse", enemy = Elephant} end, true)

--Use of a class name with blanks
RunTest("Use of a class name with blanks", function() Class{"Kitty cat"} end, true)

--Use of an empty class name
RunTest("Use of an empty class name", function() Class{""} end, true)

--Invalid attribute declaration
RunTest("Invalid attribute declaration", function() Class{"Test", attribute1 = 5} end, true)
RunTest("Invalid attribute declaration", function() Class{"Test2", ["Attribute name with spaces"] = 5, [0] = Number, [true] = false} end, true)

--Add method to object
RunTest("Add method to object", function() function puppy:walk(steps) print("walking ", steps, " steps") end end, true)

--Change method of object
RunTest("Change method of object", function() function puppy:bark() print("barking") end end, true)

--Add method with the same name as an attribute
RunTest("Add method with the same name as an attribute", function() function Dog:name() print("barking") end end, true)
--RunTest("Add two attributes with the same name", function() Class{"Mouse2", enemy = Elephant, enemy = Cat} end, true)  --Not specified

--Add attribut to object
RunTest("Add attribut to object", function() puppy.weight = 10 end, true)

--Add attribut to class
RunTest("Add attribut to class", function()	Dog.weight = Number end, true)

RunTest("Call method on class", function() Dog.bark() end, true);

--Try to redefine LOS keywords
---------------------------------------
RunTest("Try to redefine 'String' keyword", function() String = "" end, true)
RunTest("Try to redefine 'Number' keyword", function() Number = "" end, true)
RunTest("Try to redefine 'Boolean' keyword", function() Boolean = "" end, true)
RunTest("Try to redefine 'Class' keyword", function() Class = "" end, true)
RunTest("Try to redefine '_LOSInitializeInstance' function", function() _LOSInitializeInstance = "" end, true)
RunTest("Try to redefine '_LOSFindClassMember' function", function() _LOSFindClassMember = "" end, true)
RunTest("Try to redefine '_LOSValidateName' function", function() _LOSValidateName = "" end, true)
RunTest("Try to redefine '_LOSClassMetatable' table", function() _LOSClassMetatable = "" end, true)
RunTest("Try to redefine '_LOSObjectMetatable' table", function() _LOSObjectMetatable = "" end, true)
