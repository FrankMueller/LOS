require "LOS_UnitTest"


--Tests for enumerations
------------------------
RunTest("Enum creation with default value", function() Enum {'MyEnum', {'value1', 'value2', default = 'value3'}} end, false)
RunTest("Enum creation without default value", function() Enum {'OtherEnum', {'value1', 'value2', 'value3' }} end, false)
RunTest("Enum redefinition", function() Enum {'OtherEnum', {'value1', 'value2', 'value3' }} end, true)
RunTest("Enum creation without fields", function() Enum {'OtherOtherEnum', { }} end, true)
RunTest("Enum creation with two identical values", function() Enum {'OtherOtherEnum', {'value1', 'value2', 'value1'}} end, true)
RunTest("Enum creation with blanks in the name", function() Enum {'Other Enum', {'value1', 'value2'}} end, true)
RunTest("Enum creation with empty name", function() Enum {'', {'value1', 'value2'}} end, true)
RunTest("Enum creation with blanks in the field name", function() Enum {'OtherOtherEnum', {'value 1', 'value2'}} end, true)
RunTest("Enum creation with empty field name", function() Enum {'OtherOtherEnum', {'', 'value2'}} end, true)
RunTest("Enum creation with invalid field declaration", function() Enum{"OtherOtherEnum", { "Blabla", [1] = Number, [true] = false}} end, true)

RunTest("Enum comparison 1", function() assert(MyEnum.value1 == MyEnum.value1, "Comparison error") end, false)
RunTest("Enum comparison 2", function() assert(MyEnum.value1 ~= MyEnum.value2, "Comparison error") end, false)
RunTest("Enum comparison 3", function() assert(MyEnum.value1 ~= OtherEnum.value1, "Comparison error") end, false)
RunTest("Enum comparison 4", function() assert(MyEnum.value1 ~= "value1", "Comparison error") end, false)

RunTest("Enum to string conversion", function() assert(tostring(MyEnum) == "MyEnum", "Conversion error") end, false)
RunTest("Enum field to string conversion", function() assert(tostring(MyEnum.value1) == "value1", "Conversion error") end, false)


--Tests for inheritance
-----------------------
Enum { 'Gender', { 'male', 'female', default = 'undetermined' } }
Class { 'Pet', name = String, gender = Gender }
function Pet:create( n )
	self.name = n
end
function Pet:getNoise( )
	return "..."
end
function Pet:getNoise2( )
	return "..."
end
function Pet:makeNoise( )
	return self.name .. " (" .. tostring(self.gender) .. "): " .. self:getNoise()
end
function Pet:determineGender( g )
	self.gender = g
end

Class{'Dog', Pet, friend = Pet}
function Dog:getNoise( )
	return 'Woof!'
end
function Dog:makeNoise( )
	local str = super:makeNoise()
	if self.friend then
		str = str .. self.friend:makeNoise()
	end
	return str
end
puppy = Dog:create( "Puppy" )

RunTest("Instanciate class with enum attribute", function() pet = Pet:create("Test")  assert(pet.gender == Gender.undetermined, "Enum default value error") end, false)
RunTest("Inherit from class", function() Class{'Cat', Pet}  kitty = Cat:create("Kitty")  assert(kitty.gender == pet.gender and kitty:getNoise() == pet:getNoise() and kitty.name == "Kitty", "Inheritance error") end, false)
RunTest("Inherit from class which doesn't exist", function() Class{'Human', Ape} end, true)
RunTest("Inherit from class and redefine attribute", function() Class{'Sheep', Pet, name = Number} end, true)

function Cat:getNoise( )
	return 'Meow!'
end
function Cat:getNoise2( )
	return super:getNoise2() .. 'Meow!'
end
RunTest("Override method", function() assert(kitty:getNoise() == "Meow!", "Method override error")  end, false)
RunTest("Override method incl. call to super method", function() assert(kitty:getNoise2() == "...Meow!", "Method override error")  end, false)

RunTest("Inherit from class 2", function() Class{ 'Lion', Cat }  alex = Lion:create("Alex")  assert(alex.gender == pet.gender and alex:getNoise() == kitty:getNoise() and alex.name == "Alex", "Inheritance error") end, false)
function Lion:getNoise2( )
	return super:getNoise2() .. 'Roaw!'
end
RunTest("Override method incl. call to super method 2", function() assert(alex:getNoise2() == "...Meow!Roaw!", "Method override error")  end, false)
RunTest("Assignment of value to inherited attribute on two different instances", function() puppy:determineGender(Gender.female)  kitty:determineGender(Gender.male)  assert(puppy.gender == Gender.female and kitty.gender == Gender.male, "Instanciation error")  end, false)
RunTest("Assign invalid value to an enum attribute", function() puppy.gender = "male" end, true)
RunTest("Assign 'nil' value to an enum attribute", function() puppy.gender = nil end, true)


--Tests for polymorphy
----------------------
RunTest("Polymorphy", function()  puppy.friend = kitty  assert(puppy:makeNoise() == "Puppy (female): Woof!Kitty (male): Meow!", "Method override error")  end, false)
