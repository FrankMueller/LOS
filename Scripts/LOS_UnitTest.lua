---------------------------------------------
-- A basic unit test for LOS
---------------------------------------------
-- Authors:
--   Ghadah Altayyari  -
--   Felix Held        -
--   Frank Müller      - 200407
---------------------------------------------

require("LOS_gruppe22")

--Counter to count the tests which are run
local testIndex = 1

--Helper function to perform a test and check if the function acts like expected
local function RunTest(testDescription, testFunction, errorExpected)

	--Print a headline for the test and increase the test counter
	print("--> Test " .. testIndex .. ": " .. testDescription)
	testIndex = testIndex + 1

	--Call the test method
	local status, error = pcall(testFunction)

	--If the test method threw an error then print the error message
	if (status == false) then
		print("--> Call resulted in an error: '" .. error .. "'")
	end

	--If the test method threw an error as expected then print that the test has passed; otherwise print that is failed
	if (status ~= errorExpected) then
		print("> Passed")
	else
		print("! Failed")
	end
	print()
end


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


--Call of an unknown method
RunTest("Call of an unknown method", function() puppy:dance() end, true)

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
