log using log\1_1_liablang_year.log,append
*Authors Kory Kantenga & Tzuo Hann Law
*For: Sorting and Wage Inequality 2015
*Used without changes for HLM2015

/*
The orginal files were accessed at http://doku.iab.de/fdz/iabb/panel_syntax_stata.zip
This file is merged from 1_syntax_panel_1993_1998.do and 1_syntax_panel_1999_2010.do
Some variables to identify samples (waves and years) are generated.
Other variables are renamed or recoded so that each variable is named identically and comparable across all waves.
Labels and details on variables are in 3_liablang_labels.do
*/

*************************************
********* Wave 1993 *****************
*************************************

use orig\LIAB_2007_estab_1993.dta

gen jahr=1993
gen west=1

recode a06a (4=1) (1=2) (2=3) (3=4) 
	
replace a61=a61*10 

replace a15b=0 if a12e==1

gen a30qual_g=a30qual+a30fach if (a30qual!=-9 & a30fach!=-9)
replace a30qual_g=a30qual if (a30fach==-9 & a30qual!=-9)
replace a30qual_g=a30fach if (a30qual==-9 & a30fach!=-9)
gen a30einf_g=a30ung+a30einf if (a30einf!=-9 & a30ung!=-9)
replace a30einf_g=a30ung if (a30einf==-9 & a30ung!=-9)
replace a30einf_g=a30einf if (a30ung==-9 & a30einf!=-9)

replace a45ges=0 if a44a==2
replace a51ages=0 if a50==2
replace a55ges=0 if a54==2
replace a57=3 if a56==2

replace a06b=a06b/1.95583 if a06b~=-9 & a06b~=-8 & a06b~=.
replace a15b=a15b/1.95583 if a15b~=-9 & a15b~=-8 & a15b~=.
replace a60=a60/1.95583 if a60~=-9 & a60~=-8 & a60~=.
recode bula1993 (0=11)

rename bula1993   bula
rename hr1993q  hrf_quer
rename a01ges92 ges_vor
rename a01ges93 gesamt
rename a01svb92 svbv
rename a01svb93 svb
rename a01son92 son_vor
rename a01son93 sonstige
rename a06a     geschart
rename a06b     geschvol
rename a15b     invest
rename a10      tech
rename a61      arbzeit
rename a57      uebtarif
rename a60      lohn
rename a30aus   azubi
rename a30einf_g  bea_einf
rename a30qual_g  bea_qual
rename a30anw   beanw
rename a30inh   inhaber
rename a31ges   teilzeit
rename a31frau  tz_frau
rename a32ges   befrist
rename a32frau  bef_frau
rename a45ges   einstell
rename a55ges   entlass
rename a75      betrrat
rename a73      single
rename a74      form
rename a76b     bran_n99
rename a51ages  offen
rename a30ges_f ges_frau
rename a70      weiterb
rename a67      uebstund
rename a12a     plantinvest
rename a12b     itinvest
rename a12c     prodinvest
rename a12d     transpinvest
rename a12e     noinvest
rename a08      ictpc

gen outsourc=.
gen insource=.
gen ertlag=.
gen ertrlagv=.
gen eigentum=.
gen kammer=.
gen grjahr=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf =.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen tarif=.
gen uebstundv=.
gen bran_n00=.
gen betr_and=.

keep idnum jahr bula hrf_quer ges_vor gesamt uebstundv einheit ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west ///
insource ertlag eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and noinvest transpinvest prodinvest itinvest plantinvest ictpc
compress
save data\iabbp_1993_panel.dta, replace
clear

**************************************
********* Wave 1994 *****************
**************************************

use orig\LIAB_2007_estab_1994.dta


gen jahr=1994
gen west=1

replace b02ges94=bz1ges94 if b02ges94==.
replace b01ges93=bz1ges93 if b01ges93==.

replace b02svb94=bz1svb94 if b02svb94==.
replace b01svb93=bz1svb93 if b01svb93==.

recode bula1994 (0=11)
	
replace b21=0 if b17e==1

gen b40qual_g=b40qual+b40fach if (b40qual!=-9 & b40fach!=-9)
replace b40qual_g=b40qual if (b40fach==-9 & b40qual!=-9)
replace b40qual_g=b40fach if (b40qual==-9 & b40fach!=-9)
gen b40einf_g=b40unge+b40einf if (b40einf!=-9 & b40unge!=-9)
replace b40einf_g=b40unge if (b40einf==-9 & b40unge!=-9)
replace b40einf_g=b40einf if (b40unge==-9 & b40einf!=-9)


replace b47ages=0 if b46a==2
replace b52ges=0 if b51==2
replace b57ages=0 if b56==2

replace b13=b13/1.95583 if (b13~=-9 & b13~=-8 & b13~=.)
replace b21=b21/1.95583 if (b21~=-9 & b21~=-8 & b21~=.)
replace b25=b25/1.95583 if (b25~=-9 & b25~=-8 & b25~=.)


rename bula1994   bula
rename hr1994q  hrf_quer
rename b01ges93 ges_vor
rename b02ges94 gesamt
rename b01svb93 svbv
rename b02svb94 svb
rename bz1son93 son_vor
rename bz1son94 sonstige
rename b05      insource
rename b12      geschart
rename b13      geschvol
rename b11      ertlag
rename b21      invest
rename bz13     tech
rename b25      lohn
rename b40aus   azubi
rename b40einf_g  bea_einf
rename b40qual_g  bea_qual
rename b40anw   beanw
rename b40inh   inhaber
rename b42tz    teilzeit
rename b42tz_f  tz_frau
rename b43bef   befrist
rename b43bef_f bef_frau
rename b47ages  einstell
rename b52ges   entlass
rename bz06     betrrat
rename bz04     single
rename bz05     form
rename bz07b    bran_n99
rename b57ages  offen
rename b41ges_f ges_frau
rename b60      weiterb
rename b54      uebstund
rename b03a     partshut
rename b17a     plantinvest
rename b17b     itinvest
rename b17c     prodinvest
rename b17d     transpinvest
rename b17e     noinvest
rename b15      ictpc

gen outsourc=1 if b03b==1
replace outsourc=0 if b03b~=1
count if outsourc==.

gen hiving = 1 if b03c ==1
replace hiving =0 if b03c~=1
count if hiving==.

gen arbzeit=.
gen tarif =.
gen uebtarif=.
gen eigentum=.
gen kammer =.
gen grjahr=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertrlagv=.
gen uebstundv=.
gen bran_n00=.
gen betr_and=.

keep idnum jahr hrf_quer bula hr93_94p ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ///
ertlag eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest ictpc
compress
save data\iabbp_1994_panel.dta, replace
clear

**************************************
********* Wave 1995 ******************
**************************************

use orig\LIAB_2007_estab_1995.dta


gen jahr=1995
gen west=1

replace c02ges95=cz1ges95 if c02ges95==.
replace c01ges94=cz1ges94 if c01ges94==.
replace c02svb95=cz1svb95 if c02svb95==.
replace c01svb94=cz1svb94 if c01svb94==.

replace c21=0 if c17e==1


gen c39qual_g=c39qual+c39fach if (c39qual!=-9 & c39fach!=-9)
replace c39qual_g=c39qual if (c39fach==-9 & c39qual!=-9)
replace c39qual_g=c39fach if (c39qual==-9 & c39fach!=-9)
gen c39einf_g=c39unge+c39einf if (c39einf!=-9 & c39unge!=-9)
replace c39einf_g=c39unge if (c39einf==-9 & c39unge!=-9)
replace c39einf_g=c39einf if (c39unge==-9 & c39einf!=-9)


replace c45ages=0 if c44a==2
replace c54ages=0 if c53==2
replace c50ges=0 if c49==2

replace c63=3 if c62==3

recode bula1995 (0=11)

replace c13=c13/1.95583 if (c13~=-9 & c13~=-8 & c13~=.)
replace c21=c21/1.95583 if (c21~=-9 & c21~=-8 & c21~=.)
replace c64=c64/1.95583 if (c64~=-9 & c64~=-8 & c64~=.)

gen help=c26ab
replace help=0 if c26ah==1
gen help1=c26ac
replace help1=0 if c26ah==1
gen help2=c26af
replace help2=0 if c26ah==1
gen help3=c26aa
replace help3=0 if c26ah==1
gen help4=c26ad
replace help4=0 if c26ah==1
gen help5=c26ag
replace help5=0 if c26ah==1

replace c26aa=0 if c26ah==1
replace c26ab=0 if c26ah==1
replace c26ac=0 if c26ah==1
replace c26ad=0 if c26ah==1
replace c26af=0 if c26ah==1
replace c26ag=0 if c26ah==1

rename bula1995   bula
rename hr1995q  hrf_quer
rename c01ges94 ges_vor
rename c02ges95 gesamt
rename c01svb94 svbv
rename c02svb95 svb
rename cz1son94 son_vor
rename cz1son95 sonstige
rename c05      insource
rename c12      geschart
rename c13      geschvol
rename c11      ertlag
rename c21      invest
rename c24      tech
rename c57      arbzeit
rename c62      tarif
rename c63      uebtarif
rename c64      lohn
rename c39aus   azubi
rename c39einf_g  bea_einf
rename c39qual_g  bea_qual
rename c39anw   beanw
rename c39inh   inhaber
rename c41tz    teilzeit
rename c41tz_f  tz_frau
rename c45ages  einstell
rename c50ges   entlass
rename cz06     betrrat
rename cz04     single
rename cz05     form
rename cz07b    bran_n99
rename c26aa    abbau
rename c26ab    verlag
rename c26ac    gruppe
rename c26ad    reorg
rename c26af    einheit
rename c26ag    sonst
rename c54ages  offen
rename c40ges_f ges_frau
rename c51      weiterb
rename c61      uebstund
rename c03a     partshut
rename c17a     plantinvest
rename c17b     itinvest
rename c17c     prodinvest
rename c17d     transpinvest
rename c17e     noinvest
rename c15      ictpc

gen outsourc=1 if c03b==1
replace outsourc=0 if c03b~=1
count if outsourc==.

gen hiving = 1 if c03c ==1
replace hiving =0 if c03c~=1
count if hiving==.

gen befrist=.
gen bef_frau=.
gen eigentum=.
gen kammer=.
gen grjahr=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen umwelt=.
gen qualität=.
gen ertrlagv=.
gen uebstundv=.
gen bran_n00=.
gen betr_and=.

keep idnum jahr hrf_quer hr93_95p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ///
ertlag eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität help* betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest ictpc
compress
save data\iabbp_1995_panel.dta, replace
clear


**************************************
********* Wave 1996 ******************
**************************************

use orig\LIAB_2007_estab_1996.dta


gen jahr=1996
gen west=1 if wo1996==1
replace west=0 if wo1996==0

replace d22=0 if d21e==1

gen d34qual_g=d34qual+d34fach if (d34qual!=-9 | d34qual!=-8) & (d34fach!=-9 | d34fach!=-8)
replace d34qual_g=d34qual if (d34fach==-9 | d34fach==-8) & (d34qual!=-9 | d34qual!=-8)
replace d34qual_g=d34fach if (d34qual==-9 | d34qual==-8) & (d34fach!=-9 | d34fach!=-8)
gen d34einf_g=d34unge+d34einf if (d34einf!=-9 | d34einf!=-8) & (d34unge!=-9 | d34unge!=-8)
replace d34einf_g=d34unge if (d34einf==-9 | d34einf==-8) & (d34unge!=-9 | d34unge!=-8)
replace d34einf_g=d34einf if (d34unge==-9 | d34unge==-8) & (d34einf!=-9 | d34einf!=-8)

replace d43ages=0 if d42a==2
replace d39ages=0 if d38==2
replace d48ges=0 if d47==2
replace d36tz=0 if d36a==2
replace d36tz_f=0 if d36a==2
replace d36bef=0 if d36b==2
replace d36bef_f=0 if d36b==2

recode bula1996 (0=11) (12=13) (13=12) (14=15) (15=16) (16=14)

replace d50=3 if d49==3
gen help=d34anw-d01aus96 if d34anw>=0 & d01aus96>=0
gen beanw=help if help>=0 & help~=.
replace beanw = 0 if d01aus96 == -8 | d01aus96 == -9

replace d12=d12/1.95583 if (d12~=-9 & d12~=-8 & d12~=.)
replace d22=d22/1.95583 if (d22~=-9 & d22~=-8 & d22~=.)
replace d51=d51/1.95583 if (d51~=-9 & d51~=-8 & d51~=.)

rename bula1996 bula
rename hr1996q  hrf_quer
rename d01ges95 ges_vor
rename d01ges96 gesamt
rename d01svb95 svbv
rename d01svb96 svb
rename d01son95 son_vor
rename d01son96 sonstige
rename d04      insource
rename d11      geschart
rename d12      geschvol
rename d09      ertlag
rename d22      invest
rename d25      tech
rename d52      arbzeit
rename d49      tarif
rename d50      uebtarif
rename d51      lohn
rename d01aus96 azubi
rename d34einf_g  bea_einf
rename d34qual_g  bea_qual
rename d34inh   inhaber
rename d36tz    teilzeit
rename d36tz_f  tz_frau
rename d36bef   befrist
rename d36bef_f bef_frau
rename d43ages  einstell
rename d48ges   entlass
rename d80      betrrat
rename d78      single
rename d79      form
rename d77      eigentum
rename d81b     bran_n99
rename d39ages  offen
rename d35ges_f ges_frau
rename d63      uebstund
rename d02a     partshut
rename d21a     plantinvest
rename d21b     itinvest
rename d21c     prodinvest
rename d21d     transpinvest
rename d21e     noinvest
rename d17      ictpc

gen outsourc=1 if d02b==1
replace outsourc=0 if d02b~=1
count if outsourc==.

gen hiving = 1 if d02c ==1
replace hiving =0 if d02c~=1
count if hiving==.

gen grjahr=1900+d74b if d74b>=0 & d74b~=.
replace grjahr=999 if grjahr<=1989

gen weiterb=.
gen kammer=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertrlagv=.
ge uebstundv=.
gen bran_n00=.
gen betr_and=.

keep idnum jahr hrf_quer hr93_96p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau ///
befrist bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west ///
insource ertlag eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest ictpc
compress
save data\iabbp_1996_panel.dta, replace
clear


**************************************
********* Wave 1997 ******************
**************************************

use orig\LIAB_2007_estab_1997.dta


gen jahr=1997
gen west=1 if wo1997==1
replace west=0 if wo1997==0

replace e31=2 if e31==0

replace e27a=0 if e26e==1

gen e45qual_g=e45qual+e45fach if (e45qual!=-9 | e45qual!=-8) & (e45fach!=-9 | e45fach!=-8)
replace e45qual_g=e45qual if (e45fach==-9 | e45fach==-8) & (e45qual!=-9 | e45qual!=-8)
replace e45qual_g=e45fach if (e45qual==-9 | e45qual==-8) & (e45fach!=-9 | e45fach!=-8)
gen e45einf_g=e45unge+e45einf if (e45einf!=-9 | e45einf!=-8) & (e45unge!=-9 | e45unge!=-8)
replace e45einf_g=e45unge if (e45einf==-9 | e45einf==-8) & (e45unge!=-9 | e45unge!=-8)
replace e45einf_g=e45einf if (e45unge==-9 | e45unge==-8) & (e45einf!=-9 | e45einf!=-8)

replace e53ages=0 if e52a==2

replace e49ages=0 if e48==2
replace e56ges=0 if e55==2
replace e46tz=0 if e46a==2
replace e46tz_f=0 if e46a==2
replace e46bef=0 if e46b==2
replace e46bef_f=0 if e46b==2

replace e58=3 if e57==3

recode bula1997 (0=11) (12=13) (13=12) (14=15) (15=16) (16=14)

replace e12=e12/1.95583 if (e12~=-9 & e12~=-8 & e12~=.)
replace e27a=e27a/1.95583 if (e27a~=-9 & e27a~=-8 & e27a~=.)
replace e59=e59/1.95583 if (e59~=-9 & e59~=-8 &e59~=.)

rename bula1997   bula
rename hr1997q  hrf_quer
rename e01ges96 ges_vor
rename e01ges97 gesamt
rename e01svb96 svbv
rename e01svb97 svb
rename e01son96 son_vor
rename e01son97 sonstige
rename e04      insource
rename e11      geschart
rename e12      geschvol
rename e09      ertlag
rename e27a     invest
rename e30      tech
rename e60      arbzeit
rename e57      tarif
rename e58      uebtarif
rename e59      lohn
rename e45einf_g  bea_einf
rename e45qual_g  bea_qual
rename e45inh   inhaber
rename e45aus   azubi
rename e45anw   beanw
rename e46tz    teilzeit
rename e46tz_f  tz_frau
rename e46bef   befrist
rename e46bef_f bef_frau
rename e53ages  einstell
rename e56ges   entlass
rename e71      betrrat
rename e69      single
rename e70      form
rename ez4      eigentum
rename e76b     bran_n99
rename e49ages  offen
rename e45ges_f ges_frau
rename e31      weiterb
rename e62      uebstund
rename e02a     partshut
rename e26a     plantinvest
rename e26b     itinvest
rename e26c     prodinvest
rename e26d     transpinvest
rename e26e     noinvest
rename e27b     netinvest
rename e17      ictpc

gen outsourc=1 if e02b==1
replace outsourc=0 if e02b~=1
count if outsourc==.

gen hiving = 1 if e02c ==1
replace hiving =0 if e02c~=1
count if hiving==.

gen grjahr=1900+e73b if e68==2 & e73b!=-9

gen kammer=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertrlagv=.
gen uebstundv=.
gen bran_n00=.
gen betr_and=.

keep idnum jahr hrf_quer hr93_97p bula hr96_97p ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist bef_frau ///
einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag ///
eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_1997_panel.dta, replace
clear


**************************************
********* Wave 1998 *****************
**************************************

use orig\LIAB_2007_estab_1998.dta


gen jahr=1998
gen west=1 if wo1998==1
replace west=0 if wo1998==0

replace f19a=0 if f18e==1

gen f45qual_g=f45qual+f45fach if (f45qual!=-9 & f45fach!=-9)
replace f45qual_g=f45qual if (f45fach==-9 & f45qual!=-9)
replace f45qual_g=f45fach if (f45qual==-9 & f45fach!=-9)
gen f45einf_g=f45unge+f45einf if (f45einf!=-9 & f45unge!=-9)
replace f45einf_g=f45unge if (f45einf==-9 & f45unge!=-9)
replace f45einf_g=f45einf if (f45unge==-9 & f45einf!=-9)

replace f49ages=0 if f48a==2
replace f52ages=0 if f51==2
replace f58ges=0 if f57==2
replace f46tz=0 if f46a==2
replace f46tz_f=0 if f46a==2
replace f46bef=0 if f46b==2
replace f46bef_f=0 if f46b==2
replace f60=3 if f59==3

replace f11=f11/1.95583 if (f11~=-9 & f11~=-8 & f11~=.)
replace f19a=f19a/1.95583 if (f19a~=-9 & f19a~=-8 & f19a~=.)
replace f61=f61/1.95583 if (f61~=-9 & f61~=-8 & f61~=.)

gen help6=f26e
replace help6=0 if f26k==1
gen help7=f26f
replace help7=0 if f26k==1
gen help8=f26g
replace help8=0 if f26k==1
gen help9=f26a
replace help9=0 if f26k==1
gen help10=f26b
replace help10=0 if f26k==1
gen help11=f26c
replace help11=0 if f26k==1
gen help12=f26d
replace help12=0 if f26k==1
gen help13=f26h
replace help13=0 if f26k==1
gen help14=f26i
replace help14=0 if f26k==1
gen help15=f26j
replace help15=0 if f26k==1

replace f26a=0 if f26k==1
replace f26b=0 if f26k==1
replace f26c=0 if f26k==1
replace f26d=0 if f26k==1
replace f26e=0 if f26k==1
replace f26f=0 if f26k==1
replace f26g=0 if f26k==1
replace f26h=0 if f26k==1
replace f26i=0 if f26k==1
replace f26j=0 if f26k==1
recode bula1998 (0=11)

rename bula1998   bula
rename hr1998q  hrf_quer
rename f01ges97 ges_vor
rename f01ges98 gesamt
rename f01svb97 svbv
rename f01svb98 svb
rename f01son97 son_vor
rename f01son98 sonstige
rename f04      insource
rename f10      geschart
rename f11      geschvol
rename f08b     ertrlagv
rename f08a     ertlag
rename f19a     invest
rename f22      tech
rename f62      arbzeit
rename f59      tarif
rename f60      uebtarif
rename f61      lohn
rename f45einf_g  bea_einf
rename f45qual_g  bea_qual
rename f45inh   inhaber
rename f45aus   azubi
rename f45anw   beanw
rename f46tz    teilzeit
rename f46tz_f  tz_frau
rename f46bef   befrist
rename f46bef_f bef_frau
rename f49ages  einstell
rename f58ges   entlass
rename f67      betrrat
rename f79      single
rename f69      form
rename f76      eigentum
rename f78b     bran_n99
rename f26a     eigen
rename f26b     zukauf
rename f26c     neugest
rename f26d     reorg
rename f26e     verlag
rename f26f     gruppe
rename f26g     einheit
rename f26h     umwelt
rename f26i     qualität
rename f26j     sonst
rename f52ages  offen
rename f45ges_f ges_frau
rename f64      uebstund
rename f71j     grjahr
rename f02a     partshut
rename f18a     plantinvest
rename f18b     itinvest
rename f18c     prodinvest
rename f18d     transpinvest
rename f18e     noinvest
rename f19b     netinvest
rename f14      ictpc

gen outsourc=1 if f02b==1
replace outsourc=0 if f02b~=1
count if outsourc==.

gen hiving = 1 if f02c ==1
replace hiving =0 if f02c~=1
count if hiving==.

gen weiterb=.
gen kammer=.

gen abbau=.
gen uebstundv=.
gen bran_n00=.
gen betr_and=.

recode single (2=3) (3=2)

replace grjahr=grjahr+1900 if grjahr!=-9
replace grjahr=999 if f71==1
replace grjahr=999 if f73==1 
replace grjahr=1900+f77 if f77>=0 & f77!=. & grjahr==. & f73==2
replace grjahr=999 if grjahr<=1989 & grjahr!=-9 

keep idnum jahr hrf_quer hr93_98p bula hr96_98p ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist bef_frau ///
einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag ///
eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität help* betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_1998_panel.dta, replace

**************************************
********* Wave 1999 ******************
**************************************

use orig\LIAB_2007_estab_1999.dta, clear


gen jahr=1999
gen west=1 if wo1999==1
replace west=0 if wo1999==2

replace g38=g38*10 if g38!=-9 & g38!=-8

replace g23a=0 if g22e==1

gen g27qual_g=g27qual+g27fach if (g27qual!=-9 & g27fach!=-9)
replace g27qual_g=g27qual if (g27fach==-9 & g27qual!=-9)
replace g27qual_g=g27fach if (g27qual==-9 & g27fach!=-9)
gen g27einf_g=g27unge+g27einf if (g27einf!=-9 & g27unge!=-9)
replace g27einf_g=g27unge if (g27einf==-9 & g27unge!=-9)
replace g27einf_g=g27einf if (g27unge==-9 & g27einf!=-9)

replace g30ges=0 if g29a==2
replace g33ges=0 if g32==2
replace g28tz=0 if g28a==2
replace g28tz_f=0 if g28a==2
replace g28bef=0 if g28b==2
replace g28bef_f=0 if g28b==2
replace g52=3 if g50==3 & g51==1

replace g11=g11/1.95583 if (g11~=-9 & g11~=-8 & g11~=.)
replace g23a=g23a/1.95583 if (g23a~=-9 & g23a~=-8 & g23a~=.)
replace g53=g53/1.95583 if (g53~=-9 & g53~=-8 & g53~=.)

recode bula1999 (0=11)

rename bula1999   bula
rename hr1999q  hrf_quer
rename g01ges98 ges_vor
rename g01ges99 gesamt
rename g01svb98 svbv
rename g01svb99 svb
rename g01son98 son_vor
rename g01son99 sonstige
rename g03      insource
rename g10      geschart
rename g11      geschvol
rename g09      ertrlagv
rename g23a     invest
rename g26      tech
rename g38      arbzeit
rename g50      tarif
rename g52      uebtarif
rename g53      lohn
rename g27einf_g  bea_einf
rename g27qual_g  bea_qual
rename g27inh   inhaber
rename g27aus   azubi
rename g27anw   beanw
rename g28tz    teilzeit
rename g28tz_f  tz_frau
rename g28bef   befrist
rename g28bef_f bef_frau
rename g30ges   einstell
rename g33ges   entlass
rename g79      betrrat
rename g77      single
rename g78      form
rename g85      eigentum
rename g75b     kammer
rename g02a     partshut
rename g22a     plantinvest
rename g22b     itinvest
rename g22c     prodinvest
rename g22d     transpinvest
rename g22e     noinvest
rename g23b     netinvest
rename g14      ictpc

gen outsourc=1 if g02b==1
replace outsourc=0 if g02b~=1
count if outsourc==.

gen hiving = 1 if g02c ==1
replace hiving =0 if g02c~=1
count if hiving==.

replace g87b=g87b/10
replace g87b=int(g87b)

rename g87b bran_n99
rename g27ges_f ges_frau
rename g54      weiterb
rename g45      uebstundv
rename g81j     grjahr

gen offen=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertlag=.
gen uebstund=.
gen bran_n00=.
gen betr_and=.

recode single (2=3) (3=2)

replace grjahr=grjahr+1900 if grjahr!=-9
replace grjahr=999 if g81==1
replace grjahr=999 if grjahr<=1989 & grjahr!=-9

replace grjahr=1900+g86 if g86>0 & g86~=.
replace grjahr=999 if g86==-7
replace grjahr=999 if grjahr<1990 & grjahr>0 & g86>0 & g86~=.
  
keep idnum jahr hrf_quer hr93_99p hr96_99p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist bef_frau ///
einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag eigentum ///
kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_1999_panel.dta, replace
clear

**************************************
********* Wave 2000 ******************
**************************************

use orig\LIAB_2007_estab_2000.dta,clear


gen jahr=2000
gen west=1 if wo2000==1
replace west=0 if wo2000==2

recode h80 (2=1) (1=2)

gen h47qual_g=h47qual+h47fach if (h47qual!=-9 & h47fach!=-9)
replace h47qual_g=h47qual if (h47fach==-9 & h47qual!=-9)
replace h47qual_g=h47fach if (h47qual==-9 & h47fach!=-9)
gen h47einf_g=h47unge+h47einf if (h47einf!=-9 & h47unge!=-9)
replace h47einf_g=h47unge if (h47einf==-9 & h47unge!=-9)
replace h47einf_g=h47einf if (h47unge==-9 & h47einf!=-9)

replace h5201=0 if h50==2
replace h61ages=0 if h60==2
replace h65ges=0 if h64==2
replace h48tz=0 if h48a==2
replace h48tz_f=0 if h48a==2
replace h48bef=0 if h48b==2
replace h48bef_f=0 if h48b==2
replace h44=3 if h42==3 & h43==1

replace h12=h12/1.95583 if (h12~=-9 & h12~=-8 & h12~=.)
replace h19=h19/1.95583 if (h19~=-9 & h19~=-8 & h19~=.)
replace h45=h45/1.95583 if (h45~=-9 & h45~=-8 & h45~=.)

gen help16=h08e
replace help16=0 if h08k==1
gen help17=h08f
replace help17=0 if h08k==1
gen help18=h08g
replace help18=0 if h08k==1
gen help19=h08a
replace help19=0 if h08k==1
gen help20=h08b
replace help20=0 if h08k==1
gen help21=h08c
replace help21=0 if h08k==1
gen help22=h08d
replace help22=0 if h08k==1
gen help23=h08h
replace help23=0 if h08k==1
gen help24=h08i
replace help24=0 if h08k==1
gen help25=h08j
replace help25=0 if h08k==1

recode bula2000 (7=18) (0=11)

rename bula2000   bula
rename hr2000q  hrf_quer
rename h01ges99 ges_vor
rename h01ges00 gesamt
rename h01svb99 svbv
rename h01svb00 svb
rename h01son99 son_vor
rename h01son00 sonstige
rename h03      insource
rename h11      geschart
rename h12      geschvol
rename h10      ertrlagv
rename h19      invest
rename h09      tech
rename h42      tarif
rename h44      uebtarif
rename h45      lohn
rename h47anw   beanw
rename h47aus   azubi
rename h47einf_g  bea_einf
rename h47inh   inhaber
rename h47qual_g  bea_qual
rename h48tz    teilzeit
rename h48tz_f  tz_frau
rename h48bef   befrist
rename h48bef_f bef_frau
rename h5201    einstell
rename h65ges   entlass
rename h79      betrrat
rename h77      single
rename h78      form
rename h80      eigentum
rename h76b     kammer
rename h74      grjahr
rename h81b     bran_n00
rename h08a     eigen
rename h08b     zukauf
rename h08c     neugest
rename h08d     reorg
rename h08e     verlag
rename h08f     gruppe
rename h08g     einheit
rename h08h     umwelt
rename h08i     qualität
rename h08j     sonst
rename h61ages  offen
rename h47ges_f ges_frau
rename h66      weiterb
rename h02a     partshut
rename h18a     plantinvest
rename h18b     itinvest
rename h18c     prodinvest
rename h18d     transpinvest
rename h18e     noinvest
rename h20      netinvest
rename h17      ictpc

gen outsourc=1 if h02b==1
replace outsourc=0 if h02b~=1
count if outsourc==.

gen hiving = 1 if h02c ==1
replace hiving =0 if h02c~=1
count if hiving==.

replace grjahr=grjahr+1900 if grjahr!=-9 & grjahr!=0
replace grjahr=2000 if grjahr==0
replace grjahr=999 if h73==1

replace grjahr=999 if h69==1 & grjahr==.

gen arbzeit=.
gen uebstund=.
gen uebstundv=.
gen abbau=.
gen ertlag=.
gen bran_n99=.
gen betr_and=.

recode single (2=3) (3=2)

keep idnum jahr hrf_quer hr93_00p hr96_00p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige geschvol ///
geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist bef_frau ///
einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag eigentum ///
kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität help* betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2000_panel.dta, replace
clear

**************************************
********* Wave 2001 ******************
**************************************

use orig\LIAB_2007_estab_2001.dta


gen jahr=2001
gen west=1 if wo2001==1
replace west=0 if wo2001==2

replace i25=0 if i24e==1
replace i57ges=0 if i55==2
replace i61ages=0 if i60==2
replace i65ges=0 if i64==2

gen i52qual_g=i52qual+i52fach if (i52qual!=-9 & i52fach!=-9)
replace i52qual_g=i52qual if (i52fach==-9 & i52qual!=-9)
replace i52qual_g=i52fach if (i52qual==-9 & i52fach!=-9)
gen i52einf_g=i52unge+i52einf if (i52einf!=-9 & i52unge!=-9)
replace i52einf_g=i52unge if (i52einf==-9 & i52unge!=-9)
replace i52einf_g=i52einf if (i52unge==-9 & i52einf!=-9)

replace i53tz=0 if i53a==2
replace i53tz_f=0 if i53a==2
replace i54bef=0 if i54a==2
replace i54bef_f=0 if i54a==2
replace i69=3 if i67==3 & i68==1

replace i07=i07/1.95583 if (i07~=-9 & i07~=-8 & i07~=.)
replace i25=i25/1.95583 if (i25~=-9 & i25~=-8 & i25~=.)
replace i71=i71/1.95583 if (i71~=-9 & i71~=-8 & i71~=.)

recode i81 (2=1) (1=2)
recode bula2001 (7=18) (0=11)

rename bula2001   bula
rename hr2001q  hrf_quer
rename i01ges00 ges_vor
rename i01ges01 gesamt
rename i01svb00 svbv
rename i01svb01 svb
rename i01son00 son_vor
rename i01son01 sonstige
rename i03      insource
rename i06      geschart
rename i07      geschvol
rename i09      ertrlagv
rename i25      invest
rename i30      tech
rename i72      arbzeit
rename i67      tarif
rename i69      uebtarif
rename i71      lohn
rename i52anw   beanw
rename i52aus   azubi
rename i52einf_g  bea_einf
rename i52inh   inhaber
rename i52qual_g  bea_qual
rename i53tz    teilzeit
rename i53tz_f  tz_frau
rename i54bef   befrist
rename i54bef_f bef_frau
rename i57ges   einstell
rename i65ges   entlass
rename i82      betrrat
rename i79      single
rename i80      form
rename i81      eigentum
rename i90      grjahr
rename i92b     bran_n00
rename i17aa    eigen
rename i17ab    zukauf
rename i17ac    neugest
rename i17ad    reorg
rename i17ae    verlag
rename i17af    gruppe
rename i17ag    einheit
rename i17ah    umwelt
rename i17ai    qualität
rename i17aj    sonst
rename i61ages  offen
rename i52ges_f ges_frau
rename i33      weiterb
rename i74      uebstundv
rename i83b	    kammer
rename i02a     partshut
rename i24a     plantinvest
rename i24b     itinvest
rename i24c     prodinvest
rename i24d     transpinvest
rename i24e     noinvest
rename i26      netinvest
rename i12      ictpc

gen outsourc=1 if i02b==1
replace outsourc=0 if i02b~=1
count if outsourc==.

gen hiving = 1 if i02c ==1
replace hiving =0 if i02c~=1
count if hiving==.

replace grjahr=999 if i89==1
replace grjahr=999 if i85==1

gen abbau=.
gen ertlag=.
gen uebstund=.
gen bran_n99=.
gen betr_and=.

replace single=11 if single==3
replace single=3 if single==2
replace single=2 if single==11

keep idnum jahr hrf_quer hr93_01p hr96_01p bula hr00_01p ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige ///
geschvol geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag ///
eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2001_panel.dta, replace
clear

**************************************
********* Wave 2002 ******************
**************************************

use orig\LIAB_2007_estab_2002.dta


gen jahr=2002
gen west=1 if wo2002==1
replace west=0 if wo2002==2

replace j14=0 if j13e==1

gen j41qual_g=j41qual+j41fach if (j41qual!=-9 & j41fach!=-9)
replace j41qual_g=j41qual if (j41fach==-9 & j41qual!=-9)
replace j41qual_g=j41fach if (j41qual==-9 & j41fach!=-9)
gen j41einf_g=j41unge+j41einf if (j41einf!=-9 & j41unge!=-9)
replace j41einf_g=j41unge if (j41einf==-9 & j41unge!=-9)
replace j41einf_g=j41einf if (j41unge==-9 & j41einf!=-9)

replace j54ges=0 if j52==2
replace j60ages=0 if j59==2
replace j58ges=0 if j57==2
replace j42tz=0 if j42a==2
replace j42tz_f=0 if j42a==2
replace j43bef=0 if j43a==2
replace j43bef_f=0 if j43a==2
replace j32=3 if j30==3 & j31==1

recode j82 (2=1) (1=2)
recode bula2002 (7=18) (0=11)

rename bula2002 bula
rename hr2002q  hrf_quer
rename j01ges01 ges_vor
rename j01ges02 gesamt
rename j01svb01 svbv
rename j01svb02 svb
rename j01son01 son_vor
rename j01son02 sonstige
rename j03      insource
rename j05      geschart
rename j06      geschvol
rename j08      ertrlagv
rename j14      invest
rename j19      tech
rename j20      arbzeit
rename j30      tarif
rename j32      uebtarif
rename j34      lohn
rename j41einf_g  bea_einf
rename j41qual_g  bea_qual
rename j41inh   inhaber
rename j41aus   azubi
rename j41anw   beanw
rename j42tz    teilzeit
rename j42tz_f  tz_frau
rename j43bef   befrist
rename j43bef_f bef_frau
rename j54ges   einstell
rename j58ges   entlass
rename j76      betrrat
rename j80      single
rename j81      form
rename j82      eigentum
rename j83b     kammer
rename j85      grjahr
rename j87b     bran_n00
rename j60ages  offen
rename j41ges_f ges_frau
rename j27      uebstundv
rename j02a     partshut
rename j13a     plantinvest
rename j13b     itinvest
rename j13c     prodinvest
rename j13d     transpinvest
rename j13e     noinvest
rename j15      netinvest
rename j11      ictpc

gen outsourc=1 if j02b==1
replace outsourc=0 if j02b~=1
count if outsourc==.

gen hiving = 1 if j02c ==1
replace hiving =0 if j02c~=1
count if hiving==.

gen weiterb=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertlag=.
gen uebstund=.
gen bran_n99=.
gen betr_and=.

recode single (2=3) (3=2)

replace grjahr=999 if j84==1

keep idnum jahr hrf_quer hr93_02p hr96_02p hr00_02p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige ///
geschvol geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag ///
eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2002_panel.dta, replace
clear

**************************************
********* Wave 2003 ******************
**************************************

use orig\LIAB_2007_estab_2003.dta


gen jahr=2003
gen west=1 if wo2003==1
replace west=0 if wo2003==2

replace k17=0 if k16e==1
replace k41ages=0 if k39==2
replace k48ages=0 if k47==2
replace k45ges=0 if k44==2
replace k24tz=0 if k24a==2
replace k24tz_f=0 if k24a==2
replace k25bef=0 if k25a==2
replace k25bef_f=0 if k25a==2
replace k73=3 if k72==3 

gen k23ber_g=k23ber+k23uni+k23fach if (k23uni!=-9 & k23fach!=-9 & k23ber!=-9)
replace k23ber_g=k23ber if (k23uni==-9 | k23fach==-9) & k23ber!=-9 
replace k23ber_g=k23uni if (k23ber==-9 | k23fach==-9) & k23uni!=-9
replace k23ber_g=k23fach if (k23ber==-9 | k23uni==-9) & k23fach!=-9
gen k23einf_g=k23unge+k23einf if (k23unge!=-9 & k23einf!=-9)
replace k23einf_g=k23unge if k23einf==-9 & k23unge!=-9
replace k23einf_g=k23einf if k23unge==-9 & k23einf!=-9

gen betr_and=1 if k80==2
replace betr_and=2 if k80==1 | k80==3 
replace betr_and=-9 if k80==-9
replace k80=2 if k80==3 | k80==2

recode k84 (2=1) (1=2)	

recode bula2003 (7=18) (0=11)

rename bula2003 bula
rename hr2003q  hrf_quer
rename k01ges02 ges_vor
rename k01ges03 gesamt
rename k01svb02 svbv
rename k01svb03 svb
rename k01son02 son_vor
rename k01son03 sonstige
rename k03      insource
rename k08      geschart
rename k09      geschvol
rename k11      ertrlagv
rename k17      invest
rename k22      tech
rename k72      tarif
rename k73      uebtarif
rename k77      lohn
rename k23einf_g  bea_einf
rename k23ber_g bea_qual
rename k23inh   inhaber
rename k23aus   azubi
rename k23anw   beanw
rename k24tz    teilzeit
rename k24tz_f  tz_frau
rename k25bef   befrist
rename k25bef_f bef_frau
rename k41ages  einstell
rename k45ges   entlass
rename k80      betrrat
rename k82      single
rename k83      form
rename k84      eigentum
rename k85b     kammer
rename k87      grjahr
rename k89b     bran_n00
rename k48ages  offen
rename k23ges_f ges_frau
rename k34      weiterb
rename k28      uebstundv
rename k02a     partshut
rename k16a     plantinvest
rename k16b     itinvest
rename k16c     prodinvest
rename k16d     transpinvest
rename k16e     noinvest
rename k18      netinvest
rename k14      ictpc

gen outsourc=1 if k02b==1
replace outsourc=0 if k02b~=1
count if outsourc==.

gen hiving = 1 if k02c ==1
replace hiving =0 if k02c~=1
count if hiving==.

gen arbzeit=.
gen abbau=.
gen verlag=.
gen gruppe=.
gen einheit=.
gen sonst=.
gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen umwelt=.
gen qualität=.
gen ertlag=.
gen uebstund=.
gen bran_n99=.

recode single (2=3) (3=2)

replace grjahr=999 if k86==1

keep idnum jahr hrf_quer hr93_03p hr96_03p hr00_03p bula ges_vor gesamt uebstundv ertrlagv svbv svb son_vor sonstige ///
geschvol geschart invest tech arbzeit tarif uebtarif lohn azubi bea_einf bea_qual beanw inhaber teilzeit tz_frau befrist ///
bef_frau einstell entlass betrrat single form bran_n99 bran_n00 offen ges_frau weiterb uebstund outsourc west insource ertlag ///
eigentum kammer grjahr abbau verlag gruppe einheit sonst eigen zukauf neugest reorg umwelt qualität betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2003_panel.dta, replace
clear

**************************************
********* Wave 2004 ******************
**************************************
use orig\LIAB_2007_estab_2004


gen jahr=2004
gen     west=1 if wo2004==1
replace west=0 if wo2004==2

replace l16=0 if l15e==1

gen l30ber_g=l30ber+l30uni+l30fach if (l30uni!=-9 & l30fach!=-9 & l30ber!=-9)
replace l30ber_g=l30ber if (l30uni==-9 | l30fach==-9) & l30ber!=-9 
replace l30ber_g=l30uni if (l30ber==-9 | l30fach==-9) & l30uni!=-9
replace l30ber_g=l30fach if (l30ber==-9 | l30uni==-9) & l30fach!=-9
gen l30einf_g=l30unge+l30einf if (l30unge!=-9 & l30einf!=-9)
replace l30einf_g=l30unge if l30einf==-9 & l30unge!=-9
replace l30einf_g=l30einf if l30unge==-9 & l30einf!=-9

replace l31tz=0 if l31a==2
replace l31tz_f=0 if l31a==2
replace l32bef=0 if l32a==2
replace l32bef_f=0 if l32a==2
replace l39ages=0 if l38==2
replace l42ages=0 if l40==2
replace l50ges=0 if l49==2

replace l66=3 if l64==3	& l65==1				
replace l66=-9 if l64~=1 & l64~=2 & l64~=3

recode l91 (2=1) (1=2)	


gen help26=l26ae
replace help26=0 if l26ak==1
gen help27=l26af
replace help27=0 if l26ak==1
gen help28=l26ag
replace help28=0 if l26ak==1
gen help29=l26aa
replace help29=0 if l26ak==1
gen help30=l26ab
replace help30=0 if l26ak==1
gen help31=l26ac
replace help31=0 if l26ak==1
gen help32=l26ad
replace help32=0 if l26ak==1
gen help33=l26ah
replace help33=0 if l26ak==1
gen help34=l26ai
replace help34=0 if l26ak==1
gen help35=l26aj
replace help35=0 if l26ak==1

recode bula2004 (7=18) (0=11)

rename bula2004 bula
rename hr2004q  hrf_quer
rename l01ges03 ges_vor
rename l01ges04 gesamt
rename l01svb03 svbv
rename l01svb04 svb
rename l01son03 son_vor
rename l01son04 sonstige
rename l03 	insource
rename l07b	kammer
rename l08      geschart
rename l09      geschvol
rename l11      ertrlagv
rename l16      invest
rename l26aa    eigen
rename l26ab    zukauf
rename l26ac    neugest
rename l26ad    reorg
rename l26ae    verlag
rename l26af    gruppe
rename l26ag    einheit
rename l26ah    umwelt
rename l26ai    qualität
rename l26aj    sonst
rename l30einf_g  bea_einf
rename l30ber_g bea_qual
rename l30inh   inhaber
rename l30aus   azubi
rename l30anw   beanw
rename l30ges_f ges_frau
rename l31tz    teilzeit
rename l31tz_f  tz_frau
rename l32bef   befrist
rename l32bef_f bef_frau
rename l39ages  offen
rename l42ages  einstell
rename l50ges   entlass
rename l51      arbzeit
rename l62      uebstundv
rename l64      tarif
rename l66      uebtarif
rename l68      lohn
rename l88a     betrrat
rename l88b     betr_and
rename l89      single
rename l90      form
rename l91      eigentum
rename l93      grjahr
rename l95b     bran_n00
rename l02a     partshut
rename l15a     plantinvest
rename l15b     itinvest
rename l15c     prodinvest
rename l15d     transpinvest
rename l15e     noinvest
rename l17      netinvest
rename l14      ictpc

gen outsourc=1 if l02b==1
replace outsourc=0 if l02b~=1
count if outsourc==.

gen hiving = 1 if l02c ==1
replace hiving =0 if l02c~=1
count if hiving==.

gen tech=.
gen abbau=.
gen ertlag=.
gen uebstund=.
gen weiterb=.

recode single (2=3) (3=2)

replace grjahr=999 if l92==1

keep idnum jahr hrf_quer hr93_04p hr96_04p hr00_04p hr03_04p bula ges_vor gesamt svbv svb son_vor sonstige insource geschart geschvol ///
ertrlagv invest eigen zukauf neugest reorg verlag gruppe einheit umwelt qualität sonst bea_einf bea_qual inhaber azubi beanw ///
ges_frau teilzeit tz_frau befrist bef_frau offen weiterb einstell entlass arbzeit uebstundv tarif uebtarif lohn betrrat single ///
form eigentum grjahr bran_n00 outsourc tech abbau ertlag uebstund kammer west betr_and help* partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2004_panel.dta, replace
clear

**************************************
********* Wave 2005 ******************
**************************************
use orig\LIAB_2007_estab_2005.dta


gen jahr=2005
gen west=1 if wo2005==1
replace west=0 if wo2005==2

replace m19=0 if m18e==1

gen m27ber_g=m27ber+m27uni+m27fach if (m27uni!=-9 & m27fach!=-9 & m27ber!=-9)
replace m27ber_g=m27ber if (m27uni==-9 | m27fach==-9) & m27ber!=-9 
replace m27ber_g=m27uni if (m27ber==-9 | m27fach==-9) & m27uni!=-9
replace m27ber_g=m27fach if (m27ber==-9 | m27uni==-9) & m27fach!=-9
gen m27einf_g=m27unge+m27einf if (m27unge!=-9 & m27einf!=-9)
replace m27einf_g=m27unge if m27einf==-9 & m27unge!=-9
replace m27einf_g=m27einf if m27unge==-9 & m27einf!=-9

replace m28tz=0 if m28a==2
replace m28tz_f=0 if m28a==2
replace m29bef=0 if m29a==2
replace m29bef_f=0 if m29a==2
replace m47ages=0 if m46==2
replace m36ages=0 if m34==2
replace m49ges=0 if m48==2

replace m54=3 if m52==3					
replace m54=-9 if m52~=1 & m52~=2 & m52~=3

recode m91 (2=1) (1=2)

recode bula2005  (7=18) (0=11)

rename bula2005 	bula
rename hr2005q  	hrf_quer
rename m01ges04 	ges_vor
rename m01ges05		gesamt
rename m01svb04 	svbv
rename m01svb05 	svb
rename m01son04 	son_vor
rename m01son05 	sonstige
rename m03 		insource
rename m07      	geschart
rename m08      	geschvol
rename m10      	ertrlagv
rename m19      	invest
rename m26      	tech
rename m27einf_g  	bea_einf
rename m27ber_g 	bea_qual
rename m27inh   	inhaber
rename m27aus   azubi
rename m27anw   beanw
rename m27ges_f ges_frau
rename m28tz    teilzeit
rename m28tz_f  tz_frau
rename m29bef   befrist
rename m29bef_f bef_frau
rename m47ages  offen
rename m36ages  einstell
rename m49ges   entlass
rename m52      tarif
rename m54      uebtarif
rename m59      lohn
rename m77	weiterb
rename m85a     betrrat
rename m85b     betr_and
rename m88      single
rename m89      form
rename m90b	kammer
rename m91      eigentum
rename m93      grjahr
rename m95b     bran_n00
rename m02aa     partshut
rename m18a     plantinvest
rename m18b     itinvest
rename m18c     prodinvest
rename m18d     transpinvest
rename m18e     noinvest
rename m20      netinvest
rename m13      ictpc

gen outsourc=1 if m02ab==1
replace outsourc=0 if m02ab~=1
count if outsourc==.

gen hiving = 1 if m02ac ==1
replace hiving =0 if m02ac~=1
count if hiving==.

gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen verlag=.
gen einheit=.
gen gruppe=.
gen umwelt=.
gen qualität=.
gen sonst=.
gen arbzeit=.
gen abbau=.
gen ertrlag=.
gen uebstundv=.
gen uebstund=.
gen ertlag=.
recode single (2=3) (3=2)

replace grjahr=999 if m92==1

keep idnum jahr hrf_quer hr93_05p hr96_05p hr00_05p hr03_05p bula ges_vor gesamt svbv svb son_vor sonstige ///
insource geschart geschvol ertrlagv invest eigen zukauf neugest reorg verlag gruppe einheit umwelt qualität sonst ///
bea_einf bea_qual inhaber azubi beanw ges_frau teilzeit tz_frau befrist bef_frau offen weiterb einstell entlass ///
arbzeit uebstundv tarif uebtarif lohn betrrat single form eigentum grjahr bran_n00 outsourc tech abbau ertlag uebstund kammer west betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2005_panel.dta, replace
clear

**************************************
********* Wave 2006 ******************
**************************************
use orig\LIAB_2007_estab_2006.dta


gen jahr=2006
gen west=1 if wo2006==1
replace west=0 if wo2006==2

replace n01son05=n01son05+n01ger05 if n01ger05~=. | n01ger05~=-9
replace n01son06=n01son06+n01ger06 if n01ger06~=. | n01ger06~=-9

replace n11 = 6 if n07 == 4

replace n15=0 if n14e==1

gen n21ber_g=n21ber+n21uni if n21ber!=-9 & n21uni!=-9			
replace n21ber_g=n21ber if n21uni==-9 & n21ber!=-9
replace n21ber_g=n21uni if n21ber==-9 & n21uni!=-9

replace n22tz=0 if n22a==2
replace n22tz_f=0 if n22a==2
replace n23bef=0 if n23a==2
replace n23bef_f=0 if n23a==2
replace n40ages=0 if n39==2
replace n32ages=0 if n30==2
replace n37ges=0 if n36==2

replace n81=3 if n79==3					
replace n81=-9 if n79~=1 & n79~=2 & n79~=3

recode n92 (2=1) (1=2)

recode bula2006  (7=18) (0=11)

rename bula2006 bula
rename hr2006q  hrf_quer
rename n01ges05 ges_vor
rename n01ges06 gesamt
rename n01svb05 svbv
rename n01svb06 svb
rename n01son05 son_vor
rename n01son06 sonstige
rename n03      insource
rename n07      geschart
rename n08      geschvol
rename n11      ertrlagv
rename n15      invest
rename n20      tech
rename n21inh   inhaber
rename n21aus   azubi
rename n21anw   beanw
rename n21einf  bea_einf
rename n21ber_g   bea_qual   
rename n21ges_f ges_frau
rename n22tz    teilzeit
rename n22tz_f  tz_frau
rename n23bef   befrist
rename n23bef_f bef_frau
rename n40ages  offen
rename n32ages  einstell
rename n37ges   entlass
rename n52	arbzeit
rename n54      uebstundv          
rename n79      tarif
rename n81      uebtarif
rename n83      lohn
rename n84a     betrrat
rename n84b     betr_and
rename n86      single
rename n91      form
rename n06b	kammer
rename n92      eigentum
rename n94      grjahr
rename n96b     bran_n00
rename n02aa    partshut
rename n14a     plantinvest
rename n14b     itinvest
rename n14c     prodinvest
rename n14d     transpinvest
rename n14e     noinvest
rename n16      netinvest
rename n10      ictpc

gen outsourc=1 if n02ab==1
replace outsourc=0 if n02ab~=1
count if outsourc==.

gen hiving = 1 if n02ac ==1
replace hiving =0 if n02ac~=1
count if hiving==.

gen eigen=.
gen zukauf=.
gen neugest=.
gen reorg=.
gen verlag=.
gen einheit=.
gen gruppe=.
gen umwelt=.
gen qualität=.
gen sonst=.
gen abbau=.
gen ertrlag=.
gen uebstund=.
gen weiterb=.
gen ertlag=.
recode single (2=3) (3=2)

replace grjahr=999 if n93==1

keep idnum jahr hrf_quer hr93_06p hr96_06p hr00_06p hr03_06p bula ges_vor gesamt svbv svb son_vor sonstige insource ///
geschart geschvol ertrlagv invest eigen zukauf neugest reorg verlag gruppe einheit umwelt qualität sonst bea_einf ///
bea_qual inhaber azubi beanw ges_frau teilzeit tz_frau befrist bef_frau offen weiterb einstell entlass arbzeit ///
uebstundv tarif uebtarif lohn betrrat single form eigentum grjahr bran_n00 outsourc tech abbau ertlag uebstund kammer west betr_and partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2006_panel.dta, replace
clear

**************************************
********* Wave 2007 ******************
**************************************
use orig\LIAB_2007_estab_2007.dta


gen jahr=2007
gen west=1 if wo2007==1
replace west=0 if wo2007==2

replace o01son06=o01son06+o01ger06 if o01ger06~=. | o01ger06~=-9
replace o01son07=o01son07+o01ger07 if o01ger07~=. | o01ger07~=-9

replace o13 = 6 if o08 == 4

replace o18=0 if o17e==1

gen o33ber_g=o33ber+o33uni if o33ber!=-9 & o33uni!=-9			
replace o33ber_g=o33ber if o33uni==-9 & o33ber!=-9
replace o33ber_g=o33uni if o33ber==-9 & o33uni!=-9

replace o34tz=0 if o34a==2
replace o34tz_f=0 if o34a==2
replace o35bef=0 if o35a==2
replace o35bef_f=0 if o35a==2
replace o51ages=0 if o51==2
replace o42ges=0 if o40==2
replace o50ges=0 if o49==2
replace o83=3 if o81==3					
replace o83=-9 if o81~=1 & o81~=2 & o81~=3

recode o92 (2=1) (1=2)


gen help36=o29ae
replace help36=0 if o29ak==1
gen help37=o29af
replace help37=0 if o29ak==1
gen help38=o29ag
replace help38=0 if o29ak==1
gen help39=o29aa
replace help39=0 if o29ak==1
gen help40=o29ab
replace help40=0 if o29ak==1
gen help41=o29ac
replace help41=0 if o29ak==1
gen help42=o29ad
replace help42=0 if o29ak==1
gen help43=o29ah
replace help43=0 if o29ak==1
gen help44=o29ai
replace help44=0 if o29ak==1
gen help45=o29aj
replace help45=0 if o29ak==1

recode bula2007  (7=18) (0=11)

rename bula2007 bula
rename hr2007q  hrf_quer
rename o01ges06 ges_vor
rename o01ges07 gesamt
rename o01svb06 svbv
rename o01svb07 svb
rename o01son06 son_vor
rename o01son07 sonstige
rename o04      insource
rename o08      geschart
rename o09      geschvol
rename o13      ertrlagv
rename o18      invest
rename o23      tech
rename o33einf  bea_einf						
rename o33ber_g bea_qual
rename o33inh   inhaber
rename o33aus   azubi
rename o33anw   beanw
rename o33ges_f ges_frau
rename o34tz    teilzeit
rename o34tz_f  tz_frau
rename o35bef   befrist
rename o35bef_f bef_frau
rename o51ages  offen
rename o42ges   einstell         
rename o50ges   entlass
rename o81      tarif
rename o83      uebtarif
rename o85      lohn
rename o58      weiterb 
rename o86a     betrrat
rename o86b     betr_and
rename o90      single
rename o87      form
rename o91b    kammer
rename o92      eigentum
rename o94      grjahr
rename o96b	bran_n00
rename o29aa    eigen
rename o29ab    zukauf
rename o29ae    verlag
rename o29af    gruppe
rename o29ag    einheit
rename o29ac    neugest
rename o29ad    reorg
rename o29ah    umwelt
rename o29ai    qualität
rename o29aj    sonst
rename o02a     partshut
rename o17a     plantinvest
rename o17b     itinvest
rename o17c     prodinvest
rename o17d     transpinvest
rename o17e     noinvest
rename o19      netinvest
rename o12      ictpc

gen outsourc=1 if o02b==1 | o02c==1
replace outsourc=0 if o02b~=1 & o02c~=1
count if outsourc==.

gen hiving = 1 if o02d==1 | o02e==1
replace hiving =0 if o02d~=1 & o02e~=1
count if hiving==.

gen arbzeit=.
gen abbau=.
gen uebstundv=.
gen uebstund=.
gen ertlag=.
recode single (2=3) (3=2)

replace grjahr=999 if o93==1

keep idnum jahr hrf_quer hr03_07p hr00_07p bula ges_vor gesamt svbv svb son_vor sonstige insource geschart geschvol ertrlagv ///
invest eigen zukauf neugest reorg verlag gruppe einheit umwelt qualität sonst ///
bea_einf bea_qual inhaber azubi beanw ges_frau teilzeit tz_frau befrist bef_frau offen weiterb ///
entlass arbzeit uebstundv tarif uebtarif lohn betrrat single form eigentum grjahr bran_n00 outsourc ///
tech abbau ertlag uebstund kammer west betr_and einstell help* partshut hiving noinvest transpinvest prodinvest itinvest plantinvest netinvest ictpc
compress
save data\iabbp_2007_panel.dta, replace
clear

log close
