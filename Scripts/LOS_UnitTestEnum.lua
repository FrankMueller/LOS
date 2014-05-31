require("LOS_gruppe22")

Enum {'OtherEnum', {'value1', 'value2', default = 'value3'}}
Enum {'MyEnum', {'value1', 'value2', default = 'value3'}}

print ( MyEnum . value1 == MyEnum . value1 ) --> true
print ( MyEnum . value1 == MyEnum . value2 ) --> false
print ( MyEnum . value1 == OtherEnum . value1 ) --> false
print ( MyEnum . value1 == " value1 " ) --> false

print ( tostring ( MyEnum ) ) --> MyEnum
print ( tostring ( MyEnum . value1 ) ) --> value1
