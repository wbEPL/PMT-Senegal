* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data that includes the variables needed to estimate Senegal PMT. 
*	The input files are: 
*		- ehcvm_welfare_SEN_2021.dta
*		- ehcvm_menage_SEN_2021.dta
*		- ehcvm_individu_SEN_2021.dta
*	The following data is created:                        
*		- welfare_temp.dta
*		- household_temp.dta
*		- individual_temp.dta
*		- data4model_2021.dta
*	Open points that need to be addressed:
* 		- Ask the lower part of working age ranges
*		- Can't find number of orphans or a variable to create this
*		- Floor and wall material is not as different materials but already 
*			grouped for definitive materials yes or no
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 12 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD
			
*/	 		
*-------------------------------------------------------------------------------	

**# Section 11 -------------

	use "${swdDataraw}/Menage/s11_me_sen_2021.dta", clear

	**## walls ----------------

	tab s11q18
	tab s11q18, nol
	label var s11q18 "Wall material"
	*looks good for model


	**## floor --------------
	tab s11q20
	tab s11q20, nol
	label var s11q20 "Floor material"
	*looks good for model

	**## water ------------
	tab s11q21
	tab s11q26a
	tab s11q26a s11q21
	*the question on running water and on main source of water are not entirely related, will use on source to keep same PMT
	tab s11q26a s11q26b
	tab s11q26a, nol
	*not sure what is the difference between s11q26a and s11q26b, will use s11q26b
	label var s11q26a "Water source"
	label var s11q26b "Water source 2"

	**## electricity -------
	tab s11q37
	tab s11q37, nol
	label var s11q37 "Lightining"

	**## landline --------
	tab s11q42
	tab s11q42, nol
	recode s11q42 (2=0)
	tab s11q42
	tab s11q42, nol
	label var s11q42 "Landline"

	**## toilet -------
	tab s11q54
	tab s11q54, nol
	*not sure how to recode this to get the same variables, used the code from 07_PMT_2022

	gen toilette=1 if inlist(s11q54,1,2,3,4)
		replace toilette=2 if inlist(s11q54,5,6,7,8)
		replace toilette=3 if inlist(s11q54,9)
		replace toilette=4 if inlist(s11q54,10)
		replace toilette=5 if inlist(s11q54,11)
		replace toilette=6 if inlist(s11q54,12)
	
	label var toilette "Toilet"


**## keep variables and save data -----
	keep grappe menage vague s11q18 s11q20 s11q26a s11q26b s11q37 s11q42 toilette
	save "${swdTemp}/section_11_temp.dta", replace



**# Welfare data ---------------------------

use "${swdDatain}/ehcvm_welfare_SEN_2021.dta", clear

apoverty pcexp [aw = hhweight*hhsize], varpl(zref)

keep hhid grappe menage vague hhweight hhsize pcexp zref region milieu

gen logzise = ln(hhsize)

save "${swdTemp}/welfare_temp.dta", replace

**# household data ------------------------
use "${swdDatain}/ehcvm_menage_SEN_2021.dta", clear
drop sh_id_demo sh_co_natu sh_co_eco sh_co_vio sh_co_oth
save "${swdTemp}/household_temp.dta", replace


**# individual data -----------------------
use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

preserve
keep if lien == 1 /*Keep only head of hh*/
keep hhid alfa alfa2
save "${swdTemp}/educ_temp.dta", replace

**## dependency ratios ------

* Generate a variable for oldage group
gen oldgroup = .
replace oldgroup = 1 if age >= 65
replace oldgroup = 0 if age >=15 & age < 65 /*TODO: Ask the lower part of working age ranges*/

* Calculate the number of elderly and working age population by household
egen elderly = total(oldgroup == 1), by(hhid)
egen working_age = total(oldgroup == 0), by(hhid)

* Calculate the old age dependency ratio
gen oadr = .
replace oadr = elderly/working_age * 100
label var oadr "Old age dependency ratio"

* Generate a variable for youngage group
gen younggroup = .
replace younggroup = 1 if age <= 15
replace younggroup = 0 if age >=15 & age < 65 /*TODO: Ask the lower part of working age ranges*/

* Calculate the number of elderly and working age population by household
egen young = total(younggroup == 1), by(hhid)

* Calculate the old age dependency ratio
gen yadr = .
replace yadr = young/working_age * 100
label var yadr "Young age dependency ratio"
*TODO: Can't find number of orphans or a variable to create this

*collapse household level
collapse (mean) oadr yadr, by(hhid)

save "${swdTemp}/individual_temp.dta", replace



**# Merge data -----
merge 1:1 hhid using "${swdTemp}/household_temp.dta"
drop _merge
merge 1:1 hhid using "${swdTemp}/welfare_temp.dta"
drop _merge
merge 1:1 hhid using "${swdTemp}/educ_temp.dta"


save "${swdFinal}/data4model_2021.dta", replace