require "LOS_gruppe22"

Class{ 'ClassA' , Name = String }
function ClassA:create(name)
	self.Name = name
end
function ClassA:Test()
	print("TestA", _LOSSuperClass, self.Name)
end
function ClassA:Test2()
	print("TestA2", self)
end


Class{ 'ClassB', ClassA }
function ClassB:Test()
	print("TestB", _LOSSuperClass, self.Name)
end

Class{ 'ClassC', ClassB, Bla = Boolean }
function ClassC:create(name, bla)
	super:create(name)
	self.Bla = bla
end
function ClassC:Test()
	super:Test()
	print("TestC", _LOSSuperClass, self.Name)
end
function ClassC:ToStringX()
	return "tostring"
end

object1 = ClassB:create("Lennard")
object1:Test()

print()
object2 = ClassC:create("Sheldon", true)
object2:Test()

print(_LOSGetClassInformationString(ClassC))
print(_LOSGetObjectInformationString(object2))
