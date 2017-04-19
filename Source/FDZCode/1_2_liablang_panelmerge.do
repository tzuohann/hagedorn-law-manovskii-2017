log using log\1_2_liablang_panelmerge.log,append
*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Used without changes for HLM2015
/*
The orginal files were accessed at http://doku.iab.de/fdz/iabb/panel_syntax_stata.zip
This file is adpated from 3_Zusammenspielen.do
This file merges all the data from waves in sample into 1 panel.
*/

clear all
capture log close
set logtype text
log using log\2_liablang_panelmerge.log, replace

local y=2007

while `y'>1992 {
	append using data\iabbp_`y'_panel.dta
	local y=`y'-1
}
 
compress
sort idnum jahr

*** Lagging investment data by one year ***
by idnum: gen invest_correctyear = invest[_n+1] 
by idnum: replace transpinvest = transpinvest[_n+1]
by idnum: replace prodinvest = prodinvest[_n+1]
by idnum: replace itinvest = itinvest[_n+1]
by idnum: replace plantinvest = plantinvest[_n+1] 
by idnum: replace noinvest = noinvest[_n+1]
by idnum: replace netinvest = netinvest[_n+1]

order *, alpha

compress

save data\liablang_panelmerge.dta, replace

log close
