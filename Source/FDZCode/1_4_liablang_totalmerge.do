log using log\1_4_liablang_totalmerge.log,append
*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Used without changes for HLM2015
/*
This files merges the firm data with employee data.
*/
clear all

u data\liablang_labels.dta, replace
sort idnum jahr
drop hr* 
drop invest* 
drop *invest
drop geschvol 
drop ictpc
drop south 
drop lohn
save data\liablang_panel_idnumdate.dta, replace

u orig\LIAB_LM2_2007_v2_pers.dta, replace
drop betnr
drop dat_ber 
drop fam 
drop kind 
drop pers_gr
drop anz_lst 
drop ein_*
drop tage* 
drop west 
drop wohn_kr 
drop leistart 
drop lohn 
drop arb_kr
drop abm_gr
drop abg_gr
drop bew_art
drop estat8tv
drop begorig
drop endorig

*** Preparing for merging 
gen jahr = year(begepi)
sort idnum jahr

drop if missing(id)
drop if missing(jahr)

merge m:1 idnum jahr using "data\liablang_panel_idnumdate.dta"
drop _merge
drop if missing(id)
drop if missing(jahr)

drop jahr

compress
sort id spell_nr

order id idnum begepi endepi quelle tag_entg ausbild 

gen w73 = wz73
gen w93 = int(wz93/1000)
gen w03 = int(wz03/1000)
gen w08 = .

gen year = year(begepi)

replace w73=. if w73==.n | w73==.z
replace w93=. if w93==.n | w93==.z
replace w03=. if w03==.n | w03==.z
replace w08=. if w08==.n | w08==.z


gen wziv73_98 = w73 if year < 1999
gen wziv99_07 = w93 if year >=1999 & year <=2002
replace wziv99_07  = w03 if year >= 2003 & year <= 2007
gen wziv08_09 = w08 if year >=2008 & year <=2009
  
gen w73_98=.
replace w73_98=1  if wziv73_98>=0 & wziv73_98<=31
replace w73_98=2  if wziv73_98>=50 & wziv73_98<=80
replace w73_98=3  if wziv73_98>=540 & wziv73_98<=581
replace w73_98=4  if wziv73_98>=450 & wziv73_98<=529
replace w73_98=5  if (wziv73_98>=400 & wziv73_98<=410) | wziv73_98>=413 & wziv73_98<=421
replace w73_98=6  if (wziv73_98>=430 & wziv73_98<=441) | wziv73_98==770 | wziv73_98==830
replace w73_98=7  if wziv73_98==110 
replace w73_98=8  if (wziv73_98>=92 & wziv73_98<=100) | wziv73_98==90
replace w73_98=9  if (wziv73_98>=120 & wziv73_98<=133) | wziv73_98==91
replace w73_98=10 if wziv73_98>=140 & wziv73_98<=162
replace w73_98=11 if (wziv73_98>=170 & wziv73_98<=240)|(wziv73_98>=370 & wziv73_98<=372)| wziv73_98==375 | (wziv73_98>=377 & wziv73_98<=378)
replace w73_98=12 if (wziv73_98>=260 & wziv73_98<=271) | wziv73_98==345 | wziv73_98==371 | (wziv73_98>=373 & wziv73_98<=374)
replace w73_98=13 if (wziv73_98>=331 & wziv73_98<=344) | (wziv73_98>=346 & wziv73_98<=360)| wziv73_98==374
replace w73_98=14 if wziv73_98==240 | (wziv73_98>=280 & wziv73_98<=291) | (wziv73_98>=310 & wziv73_98<=320) | wziv73_98==379
replace w73_98=15 if wziv73_98==376 | (wziv73_98>=380 & wziv73_98<=390) | (wziv73_98>=411 & wziv73_98<=412) | wziv73_98==530
replace w73_98=16 if wziv73_98>=40 & wziv73_98<=46
replace w73_98=17 if wziv73_98==250 | (wziv73_98>=590 & wziv73_98<=616)
replace w73_98=18 if (wziv73_98>=292 & wziv73_98<=301) | (wziv73_98>=620 & wziv73_98<=625)| wziv73_98==361
replace w73_98=19 if wziv73_98>=700 & wziv73_98<=703
replace w73_98=20 if wziv73_98>=630 & wziv73_98<=683
replace w73_98=21 if wziv73_98>=690 & wziv73_98<=691
replace w73_98=22 if wziv73_98==377 | wziv73_98==741   | wziv73_98==810| (wziv73_98>=850 & wziv73_98<=851)
replace w73_98=23 if (wziv73_98>=720 & wziv73_98<=731) | (wziv73_98>=790 & wziv73_98<=801) | ///
			   (wziv73_98>=820 & wziv73_98<=822) | (wziv73_98>=861 & wziv73_98<=863)|wziv73_98==865 | wziv73_98==900
replace w73_98=24 if (wziv73_98>=710 & wziv73_98<=712) | (wziv73_98>=756 & wziv73_98<=758) | ///
			   (wziv73_98>=760 & wziv73_98<=765) | (wziv73_98>=771 & wziv73_98<=785)|(wziv73_98>=840 & wziv73_98<=845)| ///
			   wziv73_98==860 | wziv73_98==864   | (wziv73_98>=870 & wziv73_98<=890)|(wziv73_98>=910 & wziv73_98<=995) | ///
			   (wziv73_98>=997 & wziv73_98<=999)
replace w73_98=25 if (wziv73_98>=740 & wziv73_98<=755) | wziv73_98==996


gen w99_07=.
replace w99_07=1 if wziv99_07>=1 & wziv99_07<=5
replace w99_07=2 if wziv99_07>=10 & wziv99_07<=14
replace w99_07=3 if wziv99_07>=15 & wziv99_07<=16
replace w99_07=4 if wziv99_07>=17 & wziv99_07<=19
replace w99_07=5 if wziv99_07==20
replace w99_07=6 if wziv99_07>=21 & wziv99_07<=22
replace w99_07=7 if wziv99_07==23
replace w99_07=8 if wziv99_07==24
replace w99_07=9 if wziv99_07==25
replace w99_07=10 if wziv99_07==26
replace w99_07=11 if wziv99_07>=27 & wziv99_07<=28
replace w99_07=12 if wziv99_07==29
replace w99_07=13 if wziv99_07>=30 & wziv99_07<=33
replace w99_07=14 if wziv99_07>=34 & wziv99_07<=35
replace w99_07=15 if wziv99_07>=36 & wziv99_07<=37
replace w99_07=16 if wziv99_07>=40 & wziv99_07<=41
replace w99_07=17 if wziv99_07==45
replace w99_07=18 if wziv99_07>=50 & wziv99_07<=52
replace w99_07=19 if wziv99_07==55
replace w99_07=20 if wziv99_07>=60 & wziv99_07<=64
replace w99_07=21 if wziv99_07>=65 & wziv99_07<=67
replace w99_07=22 if wziv99_07>=70 & wziv99_07<=73
replace w99_07=23 if wziv99_07==74 | wziv99_07==93 | wziv99_07==95
replace w99_07=24 if wziv99_07==75 | wziv99_07==85 | wziv99_07>=90 & wziv99_07<=92 | wziv99_07==94 | wziv99_07>=96 & wziv99_07<=99
replace w99_07=25 if wziv99_07==80


gen w08_09=.

tab w73_98 if year <= 1998 & betr_st == 1 , miss  
tab w99_07 if year >= 1999 & year <= 2007 & betr_st == 1 , miss
tab w08_09 if year >= 2008 & betr_st == 1 , miss

gen wz25 =.
replace wz25 = w73_98 if year <= 1998
replace wz25 = w99_07 if year >= 1999 & year <= 2007
replace wz25 = w08_09 if year >= 2008

tab wz25, miss
tab year if wz25==.

#delimit ; 
label define lwz25
 1 "Agriculture"
 2 "Mining"
 3 "Man Food"
 4 "Man Textiles / Leather"
 5 "Man Wood"
 6 "Man Paper"
 7 "Man Coke" 
 8 "Man Chemical"
 9 "Man Rubber"
10 "Man Non Metallic"
11 "Man Basic Metal"
12 "Man Machinery"
13 "Man Electric"
14 "Man Transport"
15 "Man Other"
16 "Electric"
17 "Construction"
18 "Ser Wholesale"
19 "Ser Hotel"
20 "Ser Transport"
21 "Ser Finance"
22 "Ser Real Estate"
23 "Ser Other Services"
24 "Ser Public"
25 "Ser Education", modify;

#delimit cr 

label value wz25 lwz25 


*******************************************
*** TRANSFORM TO 6 INDUSTRIES *************
*******************************************

gen wz6 = wz25
  recode wz6 (2 7 17 = 1) (3/6 8/10 15/16 = 2) (11/13 = 3) (14 = 4) (18/25 = 5) (1 = 6)
label var wz6 "6 industries"

#delimit ; 
label define lwz6
 1 "Construction"
 2 "Man Other"
 3 "Man Metall"
 4 "Man Transport"
 5 "Service"
 6 "Agriculture";
#delimit cr 

label value wz6 lwz6
drop w73 w93 w03 w08 wziv73_98 wziv99_07 wziv08_09 w73_98 w99_07 w08_09
drop wz73 wz93 wz03 year

save data\liablang_totalmerge.dta, replace

log close
