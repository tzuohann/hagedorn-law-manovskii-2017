log using log\1_3_liablang_labels.log,append
*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Used without changes for HLM2015
/*
The orginal files were accessed at http://doku.iab.de/fdz/iabb/panel_syntax_stata.zip
This file is taken from 4_Variablen_und_Wertelabels.do
Variables that are not needed are dropped. 
Labels are attached to the remaining variables. 
We keep the original variable names for easier reference.
All firm data is annual. 
*/

clear all
use data\liablang_panelmerge.dta, clear

*Keep variables that are needed
keep idnum west bula lohn jahr ges_vor gesamt geschvol invest einstell netinvest offen hr9* hr0* transpinvest prodinvest itinvest plantinvest noinvest invest_correctyear ictpc

* Generate indicator for firm location in South Germany 
gen south = 1 if bula==8 | bula==9
replace south = 0 if missing(south)

* Labelling
label variable   idnum 		"Firm ID"
label variable   bula		"State"
label variable   west 		"West/East Germany"
label variable   lohn		"Gross pay and sum of salary(CLARIFY)"
label variable   jahr		"Year of Survey"
label variable   ges_vor	"Total Number Employees previous year"
label variable   gesamt		"Total Number Employees this year"
label variable   geschvol   "Revenue"
label variable   invest		"Investings"
label variable   einstell	"Total Number of New Hirings from Jan-June"
label variable   offen		"Total Number of Vacancies at point of interrogation"
label variable   ictpc      "Intermediate consumption & third party costs"

**Refer to IAB_Establishment_Panel_Manual.pdf for details on the weights
label variable hr93_94p "Panel factor W1-W2/Panel weights from 1993 until 1994"
label variable hr93_95p "Panel factor W1-W3/Panel weights from 1993 until 1995"
label variable hr93_96p "Panel factor W1-W4/Panel weights from 1993 until 1996"
label variable hr93_97p "Panel factor W1-W5/Panel weights from 1993 until 1997"
label variable hr93_98p "Panel factor W1-W6/Panel weights from 1993 until 1998"
label variable hr93_99p "Panel factor W1-W7/Panel weights from 1993 until 1999"
label variable hr93_00p "Panel factor W1-W8/Panel weights from 1993 until 2000"
label variable hr93_01p "Panel factor W1-W9/Panel weights from 1993 until 2001"
label variable hr93_02p "Panel factor W1-W10/Panel weights from 1993 until 2002"
label variable hr93_03p "Panel factor W1-W11/Panel weights from 1993 until 2003"
label variable hr93_04p "Panel factor W1-W12/Panel weights from 1993 until 2004"
label variable hr93_05p "Panel factor W1-W13/Panel weights from 1993 until 2005"
label variable hr93_06p "Panel factor W1-W14/Panel weights from 1993 until 2006"
label variable hr96_97p "Panel factor W4-W5/Panel weights from 1996 until 1997"
label variable hr96_98p "Panel factor W4-W6/Panel weights from 1996 until 1998"
label variable hr96_99p "Panel factor W4-W7/Panel weights from 1996 until 1999"
label variable hr96_00p "Panel factor W4-W8/Panel weights from 1996 until 2000"
label variable hr96_01p "Panel factor W4-W9/Panel weights from 1996 until 2001"
label variable hr96_02p "Panel factor W4-W10/Panel weights from 1996 until 2002"
label variable hr96_03p "Panel factor W4-W11/Panel weights from 1996 until 2003"
label variable hr96_04p "Panel factor W4-W12/Panel weights from 1996 until 2004"
label variable hr96_05p "Panel factor W4-W13/Panel weights from 1996 until 2005"
label variable hr96_06p "Panel factor W4-W14/Panel weights from 1996 until 2006"
label variable hr00_01p "Panel factor W8-W9/Panel weights from 2000 until 2001"
label variable hr00_02p "Panel factor W8-W10/Panel weights from 2000 until 2002"
label variable hr00_03p "Panel factor W8-W11/Panel weights from 2000 until 2003"
label variable hr00_04p "Panel factor W8-W12/Panel weights from 2000 until 2004"
label variable hr00_05p "Panel factor W8-W13/Panel weights from 2000 until 2005"
label variable hr00_06p "Panel factor W8-W14/Panel weights from 2000 until 2006"
label variable hr00_07p "Panel factor W8-W15/Panel weights from 2000 until 2007"
label variable hr03_04p "Panel factor W11-W12/Panel weights from 2003 until 2004"
label variable hr03_05p "Panel factor W11-W13/Panel weights from 2003 until 2005"
label variable hr03_06p "Panel factor W11-W14/Panel weights from 2003 until 2006"
label variable hr03_07p "Panel factor W11-W15/Panel weights from 2003 until 2007"

* Needs to be turned around
order hr93_94p hr93_95p hr93_96p hr93_97p hr93_98p hr93_99p hr93_00p hr93_01p hr96_97p hr96_98p hr96_99p hr96_00p hr96_01p  hr96_02p  hr96_03p  hr96_04p  hr96_05p  hr96_06p hr00_01p hr00_02p hr00_03p hr00_04p hr00_05p hr00_06p hr00_07p, last

* Defining the states in Germany
label define	bulalb 0 "Berlin/West" 1 "Schleswig-Holstein" 2 "Hamburg" 3 "Niedersachsen" 4 "Bremen" 5 "Nordrhein-Westfalen" 6 "Hessen" 7 "Rheinland-Pfalz/Saarland" 8 "Baden-Württemberg" 9 "Bayern" 10 "Saarland" 11 "Berlin" 12 "Brandenburg" 13 "Mecklenburg-Vorpommern" 14 "Sachsen" 15 "Sachsen-Anhalt" 16 "Thüringen" 18 "Rheinland-Pfalz"
label value 	bula bulalb

* Defining East or West Germany
label define	west_east 1 "West" 0 "East"
label value	west west_east

compress

sort idnum jahr

save data\liablang_labels.dta, replace

log close
