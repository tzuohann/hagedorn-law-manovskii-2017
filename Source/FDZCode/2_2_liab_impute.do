*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Modified so that the only imputation is multiplying censored wages by 1.2 
*Contents: preparation of data

set more off
u "data\LIAB_EmpSpells.dta", clear
sort id begepi endepi
merge m:1 spellid using "data\LIAB_1993_2007.dta"
keep if _merge==3
drop _merge

sort id begepi endepi
drop spellid quelle
compress

************************************************************************************************************
***Restrictions - employment spells, valid personal and firmid, 20-60yo, W Germ only************************
************************************************************************************************************

*Drop Indicator to impose sample restrictions
gen byte dropz = 0

*Restrict age
keep if age >= $minage
keep if age <= $maxage

*Drop if the firm's id is missing but the worker is employed
count if missing(idnum)
replace dropz = 1 if missing(idnum)

*Replace daily wage if it is negative and the person is employed
*Replace daily wage if it is missing
count if tag_entg <= 0
replace tag_entg  = 0 if tag_entg <= 0

count if missing(tag_entg)|tag_entg==.n
replace tag_entg = 0 if missing(tag_entg)|tag_entg==.n

*impose restrictions on sample
count if id == .
replace dropz = 1 if id == .

/* berstell labels
0 in training | semiskilled workers 1 | 2 skilled workers | 3 masters, foremen 
| 4 employees | 7 jobs from home | 8 part-time employment without unemployment insurance 
| 9 part-time employment with unemployment insurance */

*Definitions from Card, Heining and Kleine
count if (berstell==0|berstell==7)
replace dropz = 1 if (berstell==0|berstell==7) //drop training and jobs from home

ge byte part_time = 0
replace part_time = 1 if (berstell==8|berstell==9)

replace dropz = 1 if part_time==1

replace jahr = year(begepi)

*label variables
la var id "iab_prs_id = identifier"
capture la var betnr "betnr = artificial establishment-ID "
la var idnum "idnum = establishment panel ID "
la var educ_ip1 "ausbild=combo educ/training,0=miss"
la var gebjahr "gebjahr=year of birth"
la var berstell "occ stat and ft/pt status"
la var tag_entg "daily wage=tag_entg"
la var bula "place of work, state 1-16"

drop berstell bula 

//education dummies
ge byte edgroup = 1 if  educ_ip1==.
replace edgroup = 1 if  educ_ip1==1
replace edgroup = 2 if  educ_ip1==2
replace edgroup = 3 if (educ_ip1==3|educ_ip1==4)
replace edgroup = 4 if (educ_ip1==5|educ_ip1==6)

*These categories are not in the documentation. 
*I do this this way anyway because later on we are going to use a different imputation so it never decreases.
drop educ_ip1
drop if dropz == 1
drop if tag_entg < $wage_min2 
ge logwage = log(tag_entg)
gen logwage_1p2     = logwage
replace logwage_1p2 = log(1.2) + logwage if censor == 1

sa "data/liab_monthly_imputed.dta", replace

keep id idnum begepi endepi edgroup logwage* betr_st ind_u gebjahr
	
sort id begepi
gen start_year = year(begepi)
gen start_month = month(begepi)
gen end_year = year(endepi)
gen end_month = month(endepi)
drop begepi endepi

global GENDER = "$GENDER"
global startingyear = 1993
global endingyear = 2007

foreach var of varlist _all {
	replace `var' = -666 if missing(`var')
	local bla = "$GENDER$startingyear$endingyear"
	outfile `var' using "data/`bla'_`var'.txt", comma replace wide nolabel
}
