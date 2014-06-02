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
	super:Test()
	print("TestB", _LOSSuperClass, self.Name)
end

Class{ 'ClassC', ClassB }
function ClassC:Test()
	super:Test()
	print("TestC", _LOSSuperClass, self.Name)
end

object1 = ClassB:create("Lennard")
object1:Test()

object2 = ClassC:create("Sheldon")
object2:Test()
