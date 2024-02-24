* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data on demographics and welfare to estimate Senegal PMT. 
*	It is called by 01_createData.do
*	The input files are: 
*		- Menage/s02_me_sen_2021.dta
*	The following data is created:
*		- household_livestock.dta
*	Open points that need to be addressed:
*		- I can't identify in the raw data who is hh head, how was lien created
*			in ehcvm_individu_SEN_2021
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 30 January 2024
* 	Version 2.0 created by Daniel Valderrama 
* 	Version 3.0 by Gabriel N. Camargo-Toledo
*	Reviewer: TBD
*	Last Reviewed: TBD
* ----------------------------------------------------------------------- */


********************************************************
**# Welfare data ---------------------------------------
********************************************************

use "${swdDatain}/ehcvm_welfare_SEN_2021.dta", clear

apoverty pcexp [aw = hhweight*hhsize], varpl(zref)

keep hhid grappe menage vague hhweight hhsize pcexp zref region milieu

gen logsize = ln(hhsize)

save "${swdTemp}/welfare_temp.dta", replace


*******************************************************
**# literacy in french --------------------------------
*******************************************************


use "${swdDataraw}/Menage/s01_me_sen_2021.dta", clear 

	merge 1:1 grappe menage s01q00a using "${swdDataraw}/Menage/s02_me_sen_2021.dta", nogen  keep(matched)
	gen hhid=grappe*100+menage 
	
	gen alfa_french=s02q01__1==1 & s02q02__1==1
	keep if s01q02 == 1 /*Now is the hh head!*/
	keep hhid alfa_french
	label var alfa_french "read and write french"
save "${swdTemp}/french_temp.dta", replace

*******************************************************
**# alphabetization -----------------------------------
*******************************************************

use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

	keep if lien == 1 /*Keep only head of hh*/
	keep hhid alfa alfa2
	save "${swdTemp}/educ_temp.dta", replace

*******************************************************
**# dependency ratios ---------------------------------
*******************************************************
use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

* Generate a variable for oldage group
gen oldgroup =  age < 64 if age!=.
gen working_age= age >=15 & age <= 64 
gen young= age >15 if age!=.

gen oadr=oldgroup
gen yadr=young

*collapse household level
collapse (mean) oadr yadr, by(hhid)

save "${swdTemp}/individual_temp.dta", replace
