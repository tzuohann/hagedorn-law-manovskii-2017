*******************************
*** EDIT EDUCATION VARIABLE ***
*******************************

gen educ = ausbild

replace educ = . if educ<0
replace educ = . if educ==7

*** Rename labels for education ***
label define bild_de 1 "ND (middle school or no degree at all)", modify
label define bild_de 2 "VT (vocational training degree)", modify
label define bild_de 3 "HS (high school degree)", modify
label define bild_de 4 "HSVT (high school degree and vocational training degree)",modify
label define bild_de 5 "TC (technical college degree)", modify
label define bild_de 6 "UD (university degree)", modify

*** Modify education, such that it fits Fitzenberger's categorization ***
replace educ=1 if educ==21
replace educ=2 if educ==22 | educ==23
replace educ=3 if educ==24 | educ==25
replace educ=5 if educ==26
replace educ=6 if educ==27
replace educ=. if educ==.z | educ==.n

*** Step 1 for all procedures ***

*** Fill Education for unemployment periods with missing values *** 
replace educ =. if quelle ~= 0

*** Drop indiviualds younger than 16 and set education on 1 (= no degree = ND) for individuals between the age of 16 and 18***
drop if age<16
replace educ=1 if age<18

gen educ2 = educ
gen educ3 = educ

*** PROCEDURE IP1:***
*** Step 2 ***
*** Replace education in a spell with that one from the spell before if the current education is missing***
by id: replace educ = educ[_n-1] if educ ==.

*** Replace education in a spell with that one from the spell before if the current education is lower than the previous one***
by id: replace educ = educ[_n-1] if educ < educ[_n-1] & educ[_n-1]~=.

*** Generate indicator variables, which are 1 if high school degree (HS) and vocational training degree (VT) respectively is held and 0 if otherwise***
gen hs = 1 if educ==3
gen vt = 1 if educ==2

*** Generate sum variables, which add up the number of spells, where a person does hold a specific education degree***
by id: gen hssum = sum(hs==1)
by id: gen vtsum = sum(vt==1)

*** Impute "HSVT" whenever individual has "HS" and "VT", impute "HSVT" only from the moment both "HS" and "VT" have been attained and also do not impute it if a higher degree ("TC" or "UD") is attained***
replace educ = 4 if (educ == 2 | educ == 3) & hssum >0 & vtsum >0

*** Step 3 ***
*** Impute the education degree of a spell to the spell before, if the education degree of the previous one is still missing, which occurs if these spells precede an individual's first spell with valid educational information***
*** Do not extrapolate certain degrees beyond degree specific age limits: only UD >= 29, TC >= 27, HSVT >=23, HS >=21, VT >=20, no limit for ND***

local i=1
while `i'< 150{
by id: replace educ = educ[_n+1] if educ ==. & ((educ[_n+1]==2 & age>19) | (educ[_n+1]==3 & age>18) | (educ[_n+1]==4 & age>21) | (educ[_n+1]==5 & age>25) | (educ[_n+1]==6 & age>25) | (educ[_n+1]==1))
local i = `i'+1
}


*** Step 4 ***
*** Impute education degree "2" (= Vocational training degree = VT) if occupation position of person is "skilled worker", "foreman", or "master craftsman" ***
replace educ = 2 if educ == . & (berstell == 2 | berstell ==3)

* Forward imputation of Step 2 *
by id: replace educ = 2 if educ == . & educ[_n-1] ==2
by id: replace educ = educ[_n-1] if educ < educ[_n-1] & educ[_n-1]~=.

* Backward imputation of Step 3 *
local i=1
while `i'< 150{
by id: replace educ = educ[_n+1] if educ ==. & ((educ[_n+1]==2 & age>19) | (educ[_n+1]==3 & age>18) | (educ[_n+1]==4 & age>21) | (educ[_n+1]==5 & age>25) | (educ[_n+1]==6 & age>25) | (educ[_n+1]==1))
local i = `i'+1
}


*** Check still missing values: There are only two possibilities of education values being still missing: Either there is no education information for a person in one single spell or the backward imputation was not executed because the age specific degree limit did not allow it***
*** By accounting for the first possibility, the below count function only counts the missing values of the second possibility which should be very few and can be checked randomly***
by id: egen eductotal = total(educ~=.)
count if educ==. & eductotal~=0

*** Drop some irrelevant variables ***
drop hs
drop vt
drop hssum
drop vtsum
drop eductotal

compress

*** Since there are different kinds of imputation procedures, we know execute the second one and thus rename the imputed education variable***
rename educ educ_ip1
