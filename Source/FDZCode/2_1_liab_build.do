*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Adapted so that sampling frequency is monthly instead yearly
*Contents: preparation of data

u "data/liablang_totalmerge.dta", clear

************************************************************
******Restrict to Males Females 16-60 (<150 spells)*********
************************************************************

***** keep ids with no mistakes *****
keep if id !=.

***** Keep appropriate gender *****
keep if geschl == 1

*Drop all individuals who have more than 150 spells or 1 spell
bysort id: gen nos = _N
drop if nos > 150 | nos < 2
drop nos

*Employment Status
replace quelle = 0 if quelle==.z & idnum~=. 
replace quelle = . if quelle==.n | quelle==.z
replace quelle = 0 if quelle==1
replace quelle = 1 if quelle>1

* If occupation status is training/edu (0), job from home (7),
* part-time with hours less than 18 per week (8) then set status to unemployed
replace quelle = 1 if (berstell==0 | berstell==7 | berstell==8)

* Labels
label define erwstat_gr_de 0 "Employed", modify
label define erwstat_gr_de 1 "Unemployed", modify
label value quelle erwstat_gr_de

*Construct Year and Age Variable
capture ge jahr = year(begepi)
ge age = jahr - gebjahr
drop if jahr < 1993
drop if jahr > 2007

compress

*Recode Education variable according to Fitzenberger's IP1 imputation procedure
set more off
do prog/genIP1.do

sort id begepi endepi
duplicates drop id idnum begepi endepi tag_entg quelle, force

ge long spellid = _n

preserve
  keep spellid tag_entg
  sa "data/LIAB_DAILYWAGE.dta", replace
restore

preserve
	keep spellid age educ_ip1
	sa "data/LIAB_AGE_AUSBILD.dta", replace
restore

preserve
	keep spellid betr_st jahr
	sa "data/LIAB_BETR_ST.dta", replace
restore
	
*Save unemployment spells
preserve
	keep if quelle==1
	keep id idnum spellid begepi endepi quelle
	sa "data/LIAB_UnemploymentSpells.dta", replace
restore

sa "data/LIAB_1993_2007.dta", replace

keep if quelle==0

*Keep minimum number of variables
keep id idnum spellid begepi endepi quelle

***************************************
***Split Ends of Spells into Monthly***
***************************************
rename begepi start
rename endepi end

ge start_month 	= month(start)
ge end_month 	= month(end)
ge start_year  	= year(start)
ge end_year		= year(end)

//Case 2: Spell across multiple months
ge mcase 		= 2
//Case 0: Spell contained within month
replace mcase 	= 0 if (start_month == end_month & start_year == end_year)
//Case 1: Spell across two months
replace mcase 	= 1 if ((start_year == end_year) & (end_month - start_month == 1)) //spell during same year but one month apart
replace mcase 	= 1 if ((end_year - start_year == 1) & (start_month == 12 & end_month == 1)) //spell from Dec to Jan

//Case 0: Spell contained in one month, do nothing

//Case 1: Split spells that run across two months
expand 2 if mcase == 1, gen(idcopy1) //create duplicate of spell and generate variable indicating copy
replace start 		= mdy(end_month,1,end_year) if (mcase == 1 & idcopy1 == 1) //replace start date for duplicate spell
replace end 		= mdy(end_month,1,end_year) - 1 if (mcase == 1 & idcopy1 == 0) //replace end date for original spell

//Case 2: Split spells that run across more than two months
*Trim off ends of spell to expand to month observations
expand 2 if mcase == 2, gen(idcopy2end) //create duplicate of spell and generate variable indicating copy
replace start 	= mdy(end_month,1,end_year) if (mcase == 2 & idcopy2end == 1) //replace start date for duplicate spell
replace end 	= mdy(end_month,1,end_year) - 1 if (mcase == 2 & idcopy2end == 0) //replace end date for original spell
*Trim off starts of spell to expand to monthly observations
expand 2 if (mcase == 2 & idcopy2end == 0), gen(idcopy2start)
replace start 	= mdy(start_month + 1,1,start_year) if (mcase == 2 & idcopy2end == 0 & idcopy2start == 0 & start_month < 12) //replace start date for original spell
replace start 	= mdy(1,1,start_year+1) if (mcase == 2 & idcopy2end == 0 & idcopy2start == 0 & start_month == 12) //to deal with Dec/Jan dates
replace end 	= mdy(start_month + 1,1,start_year) - 1 if (mcase == 2 & idcopy2end == 0 & idcopy2start == 1 & start_month < 12) //replace end date for duplicate spell
replace end 	= mdy(1,1,start_year + 1) - 1 if (mcase == 2 & idcopy2end == 0 & idcopy2start == 1 & start_month == 12) //to deal with Dec/Jan dates

//At this point all spells start and end at the beginning or end of a month
*Identify spells spanning over multiple months
replace start_month 	= month(start)
replace end_month		= month(end)
replace start_year    	= year(start)
replace end_year 		= year(end)

ge longspell = 0
replace longspell = 1 if (start_month~=end_month)
replace longspell = 2 if longspell==1&(start_year~=end_year)
tab longspell quelle
su longspell
if `r(max)'==2{
	display("Some spells go over a year and are in the short spells file.")
}

*Save spells that are already monthly
preserve
	keep if longspell~=1
	keep id idnum spellid start end quelle
	sa "data/LIAB_Monthly_ShortSpells.dta", replace
restore

*Keep only spells longer than one month
keep if longspell==1
keep id idnum spellid start end quelle

**************************************
*****Split Spells into Monthly********
**************************************

ge replicates = month(end)-month(start)+1

expand replicates, gen(toffset)

sort id spellid toffset
by id spellid: replace toffset = sum(toffset)
by id spellid: ge start_month  = month(start) + toffset
by id spellid: replace start   = mdy(start_month,1,year(start))
by id spellid: replace end     = start[_n+1]-1 if month(start)~=month(end)
drop toffset start_month replicates


**************************************
*****Append Short Spells**************
**************************************

append using "data/LIAB_Monthly_ShortSpells.dta"
		
rename start begepi
rename end endepi
	
**************************************
*****Append Unemployment Spells ******
**************************************

append using "data/LIAB_UnemploymentSpells.dta"
	

format begepi endepi %d
	
**************************************
*****Merge Unemployment Spells********
**************************************

** Split dataset into two to make it more maneageable
** first do the second half,save it then do first half.
** Append the second. Avoid sorting on all dataset
qui sum id
preserve
	drop if id > `r(mean)'
	save "data/tempfirsthalf.dta",replace
restore

** Second half first, then save.
drop if id <= `r(mean)'

sort id begepi endepi
ge nendepi = -1*endepi
gen ind = 0
set more off
local continue = 1
local iter = 0
quietly {
  while `continue' == 1 {
	local iter = `iter' + 1
	replace ind = 1 if id == id[_n-1] & quelle == quelle[_n-1] & quelle==1	
	bysort id: egen affected = total(ind)
	preserve
	  drop if affected > 0
	  drop affected ind nendepi
	  save "data/tempunaffected`iter'.dta",replace
	restore
	drop if affected == 0
	drop affected
	replace begepi = begepi[_n-1] if ind == 1 & quelle==1
	sort id begepi nendepi
	replace endepi = endepi[_n-1] if ind[_n-1] == 1 & quelle==1
	sort id begepi endepi
	qui sum ind
	if `r(N)' > 0 {
	  drop if ind ==1
	}
	else {
	  local continue = 0
	}
  }
}

drop ind nendepi 
forval loop = 1/`iter'{
	qui append using "data/tempunaffected`loop'.dta"
}

sort id begepi endepi
save "data/tempsecondhalf.dta", replace

use "data/tempfirsthalf.dta", replace
sort id begepi endepi
ge nendepi = -1*endepi
gen ind = 0
set more off
local continue = 1
local iter = 0
quietly {
  while `continue' == 1 {
	local iter  = `iter' + 1
	replace ind = 1 if id == id[_n-1] & quelle == quelle[_n-1] & quelle==1
	
	bysort id: egen affected = total(ind)
	preserve
	  drop if affected > 0
	  drop affected ind nendepi
	  save "data/tempunaffected`iter'.dta",replace
	restore
	
	drop if affected == 0
	drop affected
	replace begepi = begepi[_n-1] if ind == 1 & quelle==1
	sort id begepi nendepi
	replace endepi = endepi[_n-1] if ind[_n-1] == 1 & quelle==1
	sort id begepi endepi
	if `r(N)' > 0 {
	  drop if ind ==1
	  replace ind = 0
	}
	else {
  local continue = 0
		}
	}
}

drop ind nendepi 
forval loop = 1/`iter'{
	qui append using "data/tempunaffected`loop'.dta"
}

sort id begepi endepi
qui append using "data/tempsecondhalf.dta"


**************************************
******Drop Unemp-Emp Overlaps*********
**************************************
bysort id: ge unemp_end  = endepi[_n-1]    if quelle[_n-1]==1
by id: replace unemp_end = unemp_end[_n-1] if unemp_end>=.
gen nbegepi              = -begepi
gen nendepi              = -endepi

sort id nbegepi nendepi
drop nbegepi nendepi

by id: ge unemp_start      = begepi[_n-1]      if quelle[_n-1]==1
by id: replace unemp_start = unemp_start[_n-1] if unemp_start>=.

sort id begepi endepi
format unemp_start unemp_end %d

ge overlap      = 0
replace overlap = 1 if endepi>unemp_start & unemp_start~=.
replace overlap = 1 if begepi<unemp_end & unemp_end~=.

*Drop Overlaps
* 1. Any unemployment during the month becomes the employment status for the month 
drop if overlap==1 & quelle==0
drop overlap unemp_start unemp_end

**************************************
**** Keep Relevant Employment ********
**************************************

*Merge wage into file to select highest paying job by monthly 
capture drop _merge
compress
merge m:1 spellid using "data/LIAB_DAILYWAGE.dta", update
drop if id==.

tab _merge quelle, m
drop _merge

//This isn't a bug because at this point, the longest duration is 1 month or 1 year if CARDSAMPLE = 1
ge int duration  = endepi - begepi + 1 if quelle==0
ge earnings      = tag_entg*duration  if quelle==0
ge byte month    = month(begepi)      if quelle==0
ge int year      = year(begepi)       if quelle==0
ge byte nouse    = 0
replace nouse    = 1 if earnings==.


sort nouse id year month earnings
by nouse id year month: ge byte maxobs = _N if quelle==0
by nouse id year month: ge byte dropz  = 1  if quelle==0 & _n<maxobs

ge byte eras      = 0
replace eras = 1 if dropz==1 | (nouse==1 & quelle==0)

drop if eras ==1
drop nouse eras dropz

compress
sort id begepi endepi

*********************************************************
*** Generate Unemployment-Employment Switch Indicators***
*********************************************************
*Rules:
* 1. If there is a spell of official registration as unemployed, it determines whether out of unemployment.
* 2. If there is a job within 31 days out of unenemployment and the worker does not continue with the same firm, set to unemployment switch.

*** ind_u = 1 if employee left ``unemployment'' and = 0 if otherwise ***
by id: ge int spell_nr = _n

*** Generate Indicator, which states how long unemployment has been ***;
*** Both formally declared unemployment (defined by quelle == 1) and not declared unemployment, that is the duration between two consecutive spells, are counted ***;
by id: gen int dur_gap 	= begepi - endepi[_n - 1] - 1 if spell_nr ~= 1
replace dur_gap         = 0 if (spell_nr == 1 | dur_gap < 0)

*** ind_enter = 1 if employee enters sample and 0 otherwise ***
gen byte ind_enter = 0
replace ind_enter  = 1 if id~=id[_n-1] //worker enters the sample

*** first_job = 1 if employee takes first job in sample ***
*   generate a variable indicating observation for first job
replace quelle = 2 if quelle == 1
replace quelle = 1 if quelle == 0
replace quelle = 0 if quelle == 2

by id: gen int first_job = sum(quelle)
replace first_job        = 0 if first_job ~= 1
compress first_job

replace quelle = 2 if quelle == 1
replace quelle = 1 if quelle == 0
replace quelle = 0 if quelle == 2

sa "data/ind_u_definition.dta", replace


**************************************
****** Various Ind_U Def Stats *******
**************************************

*Produce Statistics about Ind_U using various definitons
u "data/ind_u_definition.dta", clear

sort quelle id begepi
by quelle id : ge spell_nr_job = _n 
by quelle id: gen dur_gap_job = begepi - endepi[_n - 1] - 1 if spell_nr_job ~= 1 & quelle == 0
replace dur_gap_job = 0 if (spell_nr_job == 1 | dur_gap_job < 0)
drop spell_nr_job
sort id begepi endepi

global u_thres  = 28
global dgj 		= 28    //Smaller is slacker (28) Unused below
global acoHSm 	= 26    //Bigger is slacker (19)
global acoHS  	= 26    //Bigger is slacker (21)
global acoCp  	= 26    //Bigger is slacker (23)

***Out of Unemployment means official benefit receipts and work within 1 month
gen byte ind_u = 0

*This is the stricter criteria
by id: replace ind_u = 1 if quelle[_n-1] == 1 & quelle == 0 & dur_gap <= $u_thres

*This is the slackest criteria
*by id: replace ind_u = 1 if quelle[_n-1] == 1 & quelle == 0 
by id: replace ind_u = 1 if dur_gap_job > $dgj

***Fill in lag idnum and set ind_u = 0 when back to same firm***
***Create a switch indicator for job to job transition in the same firm
gen ind_ee              = 0
by id: gen lagidnum     = idnum[_n-1]
by id: replace lagidnum = lagidnum[_n-1] if lagidnum>=.
by id: replace ind_ee   = 1 if idnum==lagidnum & ind_u==1
by id: replace ind_u    = 0 if idnum==lagidnum & ind_u==1

***Change to out of unemployment if recently enter sample
merge m:1 spellid using "data/LIAB_AGE_AUSBILD.dta", nogen update

*ge byte edgroup = 0 if (ausbild==0|ausbild==.|ausbild==.n|ausbild==.z)
*replace edgroup = 1 if (ausbild==1|ausbild==21)
*replace edgroup = 2 if (ausbild==2|ausbild==22|ausbild==23)
*replace edgroup = 3 if (ausbild==3|ausbild==4|ausbild==24|ausbild==25)
*replace edgroup = 4 if (ausbild==5|ausbild==6|ausbild==26|ausbild==27)
*drop ausbild

ge byte edgroup = educ_ip1

***Allow first jobs for young worker to be out of unemp
replace ind_u = 1 if first_job == 1  &  age <= $acoHSm  &  (edgroup == 0 | edgroup == 1 | edgroup == 2)
replace ind_u = 1 if first_job == 1  &  age <= $acoHS  &  edgroup == 3
replace ind_u = 1 if first_job == 1  &  age <= $acoCp  &  edgroup == 4
drop age edgroup

*Drop all unemployment spells
keep if quelle==0
keep id idnum begepi endepi spellid ind* ind_enter tag_entg

*Mark all spell observations as coming out of unemployment
bysort spellid: egen byte ind_u2 = max(ind_u)
drop ind_u
rename ind_u2 ind_u
sort id begepi endepi
replace ind_u = ind_u[_n-1] if id == id[_n-1] & idnum == idnum[_n-1] & begepi == endepi[_n-1]+1

**************************************
*******Merge Adjacent Episodes********
**************************************
gen byte ind = 0
rename begepi start
rename endepi end
set more off

gen jahr = year(start)

*code censoring - use ssmax from LIAB - from now on tag_entg is strictly capped
ge ssmax=.
replace ssmax=90 if jahr==1985
replace ssmax=94 if jahr==1986
replace ssmax=95 if jahr==1987
replace ssmax=100 if jahr==1988
replace ssmax=102 if jahr==1989
replace ssmax=105 if jahr==1990
replace ssmax=109 if jahr==1991
replace ssmax=113 if jahr==1992
replace ssmax=121 if jahr==1993
replace ssmax=127 if jahr==1994
replace ssmax=131 if jahr==1995
replace ssmax=134 if jahr==1996
replace ssmax=137 if jahr==1997
replace ssmax=141 if jahr==1998
replace ssmax=142 if jahr==1999
replace ssmax=144 if jahr==2000
replace ssmax=146 if jahr==2001
replace ssmax=147 if jahr==2002
replace ssmax=167 if jahr==2003
replace ssmax=168 if jahr==2004
replace ssmax=170 if jahr==2005
replace ssmax=172 if jahr==2006
replace ssmax=172 if jahr==2007
replace ssmax=173 if jahr==2008
replace ssmax=177 if jahr==2009
replace ssmax=180 if jahr==2010

*create censor dummy and real wages from tag_entg/cpi
ge censor = 0
replace censor = 1 if tag_entg>=ssmax
replace tag_entg = ssmax if tag_entg >= ssmax

ge cpi = .
replace cpi=80.2 if jahr==1985
replace cpi=80.1 if jahr==1986
replace cpi=80.3 if jahr==1987
replace cpi=81.3 if jahr==1988
replace cpi=83.6 if jahr==1989
replace cpi=85.8 if jahr==1990
replace cpi=89.0 if jahr==1991
replace cpi=92.5 if jahr==1992
replace cpi=95.8 if jahr==1993
replace cpi=98.4 if jahr==1994
replace cpi=100.0 if jahr==1995
replace cpi=101.3 if jahr==1996
replace cpi=103.2 if jahr==1997
replace cpi=104.1 if jahr==1998
replace cpi=104.8 if jahr==1999
replace cpi=106.3 if jahr==2000
replace cpi=108.4 if jahr==2001
replace cpi=110.0 if jahr==2002
replace cpi=111.1 if jahr==2003
replace cpi=112.9 if jahr==2004
replace cpi=114.7 if jahr==2005
replace cpi=116.5 if jahr==2006
replace cpi=119.1 if jahr==2007
replace cpi=122.2 if jahr==2008
replace cpi=122.7 if jahr==2009

*NEED CPI 2010
replace tag_entg=tag_entg*100/cpi
drop ssmax cpi ind_enter ind_ee ind

replace start = start[_n-1] if id == id[_n-1] & idnum == idnum[_n-1] & tag_entg == tag_entg[_n-1] & jahr == jahr[_n-1]
drop jahr
sort id start end
by id start: drop if _n < _N
rename start begepi
rename end endepi

sa "data/LIAB_EmpSpells.dta", replace


