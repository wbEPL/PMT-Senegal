* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data on livestock to estimate Senegal PMT. 
*	It is called by 01_createData.do
*	The input files are: 
*		- Menage/s17_me_sen_2021.dta
*	The following data is created:
*		- household_livestock.dta
*	Open points that need to be addressed:
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 30 January 2024
* 	Version 2.0 created by Daniel Valderrama 
* 	Version 3.0 by Gabriel N. Camargo-Toledo
*	Reviewer: TBD
*	Last Reviewed: TBD
* ----------------------------------------------------------------------- */


use "${swdDataraw}/Menage/s17_me_sen_2021.dta", clear
gen hhid=grappe*100+menage 
keep hhid grappe menage s17q01 s17q03 s17q05

recode s17q03  (1 = 1) (2   = 0)  (missing = 0 )
label define s17q03 0 "No" 1 "Yes", replace

replace s17q05 = 0 if s17q03 == 0
recode s17q05 (0 = 0 "Not owned") ///
			  (1 = 1 "Owns 1") ///
			  (2/max = 2 "Owns more than 1"), ///
			  gen(s17q06)


**## Reshape so column is one animal --------------
reshape wide s17q03 s17q05 s17q06, i(hhid) j(s17q01) favor(speed)

** Dummies
label var s17q031 "Cattle"
label var s17q032 "Sheep"
label var s17q033 "Goats"
label var s17q034 "Camels"
label var s17q035 "Equines (Horses)"
label var s17q036 "Asins (Donkeys, mules, mules) "
label var s17q037 "Pigs"
label var s17q038 "Rabbits"
label var s17q039 "Chickens"
label var s17q0310 "Guinea fowl"
label var s17q0311 "Other poultry"

rename s17q031 l_bovines
rename s17q032 l_sheep
rename s17q033 l_goats
rename s17q034 l_camels
rename s17q035 l_horses
rename s17q036 l_donkeys
rename s17q037 l_pigs
rename s17q038 l_rabbits
rename s17q039 l_chickens 
rename s17q0310 l_guinea_fowl
rename s17q0311 l_other_poultry

** numbers

label var s17q051 "Num Cattle"
label var s17q052 "Num Sheep"
label var s17q053 "Num Goats"
label var s17q054 "Num Camels"
label var s17q055 "Num Equines (Horses)"
label var s17q056 "Num Asins (Donkeys, mules, mules) "
label var s17q057 "Num Pigs"
label var s17q058 "Num Rabbits"
label var s17q059 "Num Chickens"
label var s17q0510 "Num Guinea fowl"
label var s17q0511 "Num Other poultry"

rename s17q051 l_bovines_n
rename s17q052 l_sheep_n
rename s17q053 l_goats_n
rename s17q054 l_camels_n
rename s17q055 l_horses_n
rename s17q056 l_donkeys_n
rename s17q057 l_pigs_n
rename s17q058 l_rabbits_n
rename s17q059 l_chickens_n
rename s17q0510 l_guinea_fowl_n
rename s17q0511 l_other_poultry_n

** recode

label var s17q061 "Rec Cattle"
label var s17q062 "Rec Sheep"
label var s17q063 "Rec Goats"
label var s17q064 "Rec Camels"
label var s17q065 "Rec Equines (Horses)"
label var s17q066 "Rec Asins (Donkeys, mules, mules) "
label var s17q067 "Rec Pigs"
label var s17q068 "Rec Rabbits"
label var s17q069 "Rec Chickens"
label var s17q0610 "Rec Guinea fowl"
label var s17q0611 "Rec Other poultry"

rename s17q061 l_bovines_r
rename s17q062 l_sheep_r
rename s17q063 l_goats_r
rename s17q064 l_camels_r
rename s17q065 l_horses_r
rename s17q066 l_donkeys_r
rename s17q067 l_pigs_r
rename s17q068 l_rabbits_r
rename s17q069 l_chickens_r
rename s17q0610 l_guinea_fowl_r
rename s17q0611 l_other_poultry_r


*Poultry
gen l_poultry = 0 
replace l_poultry = 1 if l_chickens == 1 |	l_guinea_fowl == 1 | l_other_poultry == 1
label var l_poultry "All Poultry"

egen l_poultry_n = rowtotal(l_chickens_n l_guinea_fowl_n l_other_poultry_n)
label var l_poultry_n "Num All Poultry"

recode l_poultry_n (0 = 0 "Not owned") ///
				   (1 = 1 "Owns 1") ///
				   (2/max = 2 "Owns more than 1"), ///
				   gen(l_poultry_r)
label var l_poultry_r "Rec All Poultry"

*Large ruminants
gen l_grosrum = 0
replace l_grosrum = 1 if l_bovines == 1 | l_camels == 1 | l_horses == 1 | l_donkeys == 1
label var l_grosrum "Large ruminants"

egen l_grosrum_n = rowtotal(l_bovines_n l_camels_n l_horses l_donkeys_n)
label var l_grosrum_n "Num Large ruminants"

recode l_grosrum_n (0 = 0 "Not owned") ///
				   (1 = 1 "Owns 1") ///
				   (2/max = 2 "Owns more than 1"), ///
				   gen(l_grosrum_r)
label var l_grosrum_r "Rec Large ruminants"

*Small ruminants
gen l_petitrum = 0
replace l_petitrum = 1 if l_sheep == 1 | l_goats == 1
label var l_petitrum "Small ruminants"

egen l_petitrum_n = rowtotal(l_sheep_n l_goats_n)
label var l_petitrum_n "Num Small ruminants"

recode l_petitrum_n (0 = 0 "Not owned") ///
				   (1 = 1 "Owns 1") ///
				   (2/max = 2 "Owns more than 1"), ///
				   gen(l_petitrum_r)
label var l_grosrum_r "Rec Small ruminants"

save "${swdTemp}/household_livestock.dta", replace
