---------------------------------------------
-- A basic unit test for LOS
---------------------------------------------
-- Authors:
--   Ghadh Altaiari    - 322844
--   Felix Held        - 350194
--   Frank Müller      - 200407
---------------------------------------------

require("LOS_gruppe22")

--Counter to count the tests which are run
local testIndex = 1

--Helper function to perform a test and check if the function acts like expected
function RunTest(testDescription, testFunction, errorExpected)

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
