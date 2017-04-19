*master fdz463
*For: Sorting and Wage Inequality 2015 and Identifying Eqbm Models of Labor Mkt Sorting


/* Program Description:
 Workers and establishments are completely anonymized, because we relabel their id's.
 Most statistics we report are aggregate at the level of the entire sample.
 We also request the match density, wages and the value of vacancy at 
 the level of worker/firm types (which consists of bins set by the global macro 
 "WORKERBINSIZE" below. Each bin contains about 2% of the number of observations
 in the full sample.
 
 Firms are ranked based on their expected surplus from hiring a workers. 
 This is just a measure of the wage premium the firms pay to poach workers.
 Workers are ranked based on their wages.
 
 The binning is done from these rankings.
 
 The binning of workers and firms (as well as relabelling of their id's)
 ensure that no worker or firm can be identified from the information we display. 

 The program is structured as follows:
 1) Set up model parameters, select data and time period and clean data
 2) Load the data into Matlab and restrict the sample to sufficient observations
 3) Display some summary statistics
 4) Run wage regressions to obtain residual wages
 5) Estimate a structural model. (Ranking, binning, etc)
 6) Do counterfactuals and display records that we want to keep.
*/

clear all
set logtype text
cap version 12
set more off
set linesize 80

*************************************************************************
** ALWAYS RUN THIS FILE BY CHANGING DIRECTORY TO \prog THEN do master.do*
** On IAB Servers, we run up to 4_2. Start ranking outside STATA/MATLAB.*
** Run master again from 4_3 ********************************************
*************************************************************************

*********************************
***** Set Directory and Path ****
*********************************
cap set mem 20g
cd ..
adopath ++ prog
global ROOTDIR = "c(pwd)"
global ROOTDIR = $ROOTDIR

disp "PLEASE DO NOT RUN IN BATCH MODE. IT WILL NOT OPEN MATLAB."
disp "PLEASE DO NOT RUN IN BATCH MODE. IT WILL NOT OPEN MATLAB."
disp "PLEASE DO NOT RUN IN BATCH MODE. IT WILL NOT OPEN MATLAB."
disp "PLEASE DO NOT RUN IN BATCH MODE. IT WILL NOT OPEN MATLAB."
disp "PLEASE DO NOT RUN IN BATCH MODE. IT WILL NOT OPEN MATLAB."

disp "We are currently in folder:"
disp "$ROOTDIR"

log using log\master.log, replace

*********************************
***** Set Globals ***************
*********************************
* These variables are used to control what step the program runs
* as well as the inputs to restrictions on the sample
global IAB 	            = 1

*Data Parameters
global startingyear     = 1993 		   // which year to start everything after
global wage_min2 		= 10           // drop if wages less than wage_min2 euros/day

*Model Parameters
global WORKERBINSIZE 	= 50		// Parameters for binning workers

global minage = 20
global maxage = 60

* Display what is in each folder
dir prog\*
dir log\*
dir data\*
dir orig\*
dir doc\*
 
log close

**************
** DO ORIG ***
**************
* Reconstruct LIAB Panel (provided by IAB)
do prog\1_1_liablang_year.do
do prog\1_2_liablang_panelmerge.do
do prog\1_3_liablang_labels.do
do prog\1_4_liablang_totalmerge.do

*******************
** RUN DO FILES ***
*******************
do prog\2_1_liab_build.do  //Splits the data into monthly spells, data cleaning
do prog\2_2_liab_impute.do //Imputation of wages

**********************
* END Stata do files *
**********************

******************
** RUN M FILES ***
******************
*All output is logged to log file with same name as the m file that is run
*First erase the file that indicates the matlab program is done.
capture erase "$ROOTDIR\log\done.done"
*After this done.done file is found, it is deleted immediately in STATA. See below.

global header 	 	= "men"
global spec      	= "Card"
***Period 1993 - 2007
global startyear  = 1993
global endyear    = 2007

***Convert to matlab file
* These files were previously run.
global cmdrunning = "m3_1_dataInput('$header','$spec','$ROOTDIR')"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m3_1_dataInput$spec$header.log -r m3_1_dataInput('$header','$spec','$ROOTDIR')
do prog\functioncompletecheck.do

global cmdrunning = "m3_2_dataPreparation($startyear,$endyear,'$spec','$header','$ROOTDIR')"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m3_2_dataPreparation$startyear$endyear$spec$header.log -r m3_2_dataPreparation($startyear,$endyear,'$spec','$header','$ROOTDIR')
do prog\functioncompletecheck.do

global cmdrunning = "m3_3_estimateAKMMQ($startyear,$endyear,'$spec','$header','$ROOTDIR')"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m3_3_estimateAKMMQ$startyear$endyear$spec$header.log -r m3_3_estimateAKMMQ($startyear,$endyear,'$spec','$header','$ROOTDIR')
do prog\functioncompletecheck.do

global cmdrunning = "m4_1_makeSimFromReal($startyear,$endyear,'$spec','$header','$ROOTDIR')"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m4_1_makeSimFromReal$startyear$endyear$spec$header.log -r m4_1_makeSimFromReal($startyear,$endyear,'$spec','$header','$ROOTDIR')
do prog\functioncompletecheck.do

global cmdrunning = "m4_2_WantedVars_ToRankW($startyear,$endyear,'$spec','$header','$ROOTDIR')"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m4_2_WantedVars_ToRankW$startyear$endyear$spec$header.log -r m4_2_WantedVars_ToRankW($startyear,$endyear,'$spec','$header','$ROOTDIR')
do prog\functioncompletecheck.do

* Files that are new and needed.
global cmdrunning = "m4_3_WantedVars_FromRankW($startyear,$endyear,'$spec','$header','$ROOTDIR',0.1)"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m4_3_WantedVars_FromRankW$startyear$endyear$spec$header.log -r m4_3_WantedVars_FromRankW($startyear,$endyear,'$spec','$header','$ROOTDIR',0.1)
do prog\functioncompletecheck.do

global cmdrunning = "m4_4_PostProcess($startyear,$endyear,'$spec','$header','$ROOTDIR',0.1)"
shell matlab -nosplash -sd $ROOTDIR\prog -logfile $ROOTDIR\log\m4_4_PostProcess$startyear$endyear$spec$header.log -r m4_4_PostProcess($startyear,$endyear,'$spec','$header','$ROOTDIR',0.1)
do prog\functioncompletecheck.do

*Display new contents of folders
log using log\master.log,append
	macro list
	scalar list
	dir data\*
	dir log\*
log close
