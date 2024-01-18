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

Notes: 
Dwellings: 
less variance in soil (from 5 to 4)
Water: neighbor faucet
Electricity: lap solaire tag as lamp Rechargeable
			  Gas lamp and storm lamp ommitted
			  Candle and wood/lumber needs to be combined here
Walls:  Soil comes with other (Banco alu, vitres)
		Straw joined with clod of earth
		-Aluminium, recycled materials , stones are new categories difficiault to match to missing categories such as wood and stalk 
Toilet: 
  Simple latrines ( Latrines dallées simplement) are classified as covered non coverede or improved ventilated. It is not a trivial questions since these three categories exist already in the survey and they represent 17 percent of obs
		-Latrines VIP (dallées, ventillées)     6.32     
        6  Latrines ECOSAN (dallées, couvertes)   7.71   
        7  Latrines SANPLAT (dallées, non couvertes) 4.19
  No difference between interior and exterior W.C. nor manual vs flush (Which not sure if people can identify)
  Base category is in nature, the opposite to other variables where the base are good and categories with more observations
- Not sure about the difference between Chasse d'eau avec egout ou fosse septique
 and Chasse d'eau avec egout in the original PMT and how to match it with the new info of W.C




Livestock 

- Problems with the raw data so access to harmonize variables 
	*Large ruminants:  Combine horses and cows 
	*Small ruminants:  Combine sheeps and goats
	* We have poultry
	* Two additional type of animals not very relevant (Rabbits and porks) 
*/	 		
*-------------------------------------------------------------------------------	

	
use "${swdDataraw}/Menage/s11_me_sen_2021.dta", clear

********************************************************
** Dewelling charactersitics 11 -------------
********************************************************

*----## floor --------------
	fre s11q20
	recode s11q20 (2=1 "Cement (Ciment)") ///
				   (1=2 "Tiles (Carreux)") ///
				   (3=3 "Clay soil and sand (Terre battue/Sable)") ///
				   (4 5 =4  "Other (Bouse d'animaux)"), ///
	gen (c_floor)
	label var c_floor "Floor material (rec of s11q20) "
	*looks good for model
	
*----## walls ----------------
	fre s11q18
	recode s11q18 ///
		(1 2 =1 "Cement and bricks (ciment, beton , pierres, briques cuites)") ///
		(4 = 2 "Clay Soil (Banco amélioré/ semi-dur)") ///
		(3 5 7 = 3 "Straw, Recycled (Paille, planches, toles)")  ///
		(6 8 9 = 4 "Other (stones, not protected)"),  ///
	gen (c_walls)
	label var c_walls "Wall material (rec of s11q18)"

*----## water ------------
	tab s11q21 // Is the household connected to a running water network?
	tab s11q26a
	tab s11q26a s11q21
	*the question on running water and on main source of water are not entirely related, will use on source to keep same PMT
	compare s11q26a s11q26b //*not sure what is the difference between s11q26a and s11q26b	
	
	recode s11q26a ///
		(1 2 =1 "court or dwelling faucet (Robinet ... loge, cour, voisin)") ///
		(3 4 = 2 "Pub Faucet (voisin and public)")  ///
		(7 8 = 3 "Protected well (Puits couvert)")  ///
		(6 5 = 4 "Unprotected well (Puits ouvert)") ///
		(9 10 = 5 "Drilling (Forage)") ///
		(14 16 17 = 6 "Mineral water (schet, bouteille, vendeur)") ///
		(11 12 13 = 7 "Fluvial, source developed (Spring)") ///
		(18= 8 "Other"), ///
	gen (c_water)
	label var c_water "Water source (rec of s11q26a)"
	
*----## electricity -------
	fre s11q37
	recode 	s11q37 ///
		(1 2  =1  "Network and generator (Electricité réseau)") ///
		(3 	  = 2 "Solar (solaire)")  ///
		(4    = 3 "Petrol lamp (Lampe petrol)")  ///
		(5    = 4 "Rechargeable lamp(pile solaire)") ///
		(6    = 5 "Wood others (Paraffine, bois, planche)") ///
		(7    = 6 "Other"), ///
	gen (c_ligthing)
	label var c_ligthing "Lightning (rec of s11q37)"
	
*----## toilet -------
	fre s11q54
	recode 	s11q54 ///
		(11 =1  "In nauture (Aucune toilette (dans la nature)") ///
		(1 2 3 4 = 2  "Solar (solaire)")  ///
		(6 8 = 3 "Covered latrines (ECOSAN,: dalles, couvertes)")  ///
		(7 = 4 "Uncovered latrines (SANPLAT,: dalles, non couvertes)") ///
		(5 = 5 "Improved ventilated latrine (VIP: dalles, ventillees)") ///
		(9 10 12 = 6 "Other"), ///
	gen (c_toilet)
	label var c_toilet "Toilet (rec of s11q54)"

**## landline --------
	tab s11q42
	tab s11q42, nol
	recode s11q42 (2=0)
	tab s11q42
	tab s11q42, nol
	label var s11q42 "Landline"

*----## storing -------

	keep grappe menage vague c_* s11q18 s11q20 s11q26a s11q26b s11q37 s11q42 
	save "${swdTemp}/section_11_temp.dta", replace
	
********************************************************
** Assets  -------------
********************************************************

use "${swdDataraw}/Menage/s12_me_sen_2021.dta", clear

	gen hhid=grappe*100+menage 
	sort hhid s12q01
	
	gen tv=s12q01==20 & s12q02==1
	gen fer=s12q01==7 & s12q02==1
	gen frigo=(s12q01==16 | s12q01==17) & (s12q02==1)
	gen cuisin=s12q01==9 & s12q02==1
	gen ordin=s12q01==37 & s12q02==1
	gen decod=s12q01==22 & s12q02==1
	gen car=s12q01==28 & s12q02==1
	
	gen moto =s12q01==29 & s12q02==1
	gen radio=s12q01==19 & s12q02==1
	gen fan=s12q01==18 & s12q02==1
	gen landline=s12q01==34 & s12q02==1
	gen mobile=s12q01==35 & s12q02==1
	gen boat=s12q01==40 & s12q02==1
	gen aircond=s12q01==25 & s12q02==1
	
	
	
	keep  hhid car tv ordin frigo  fer  cuisin  decod  moto radio fan landline mobile boat aircond  	// fer: electric iron 
	local vars_assets "car tv ordin frigo  fer  cuisin  decod  moto radio fan landline mobile boat aircond"
	collapse (sum) `vars_assets', by (hhid)
	
	lab var tv 		"Menage a TV"
	lab var fer 	"Menage a fer electrique"
	lab var frigo 	"Menage a frigo/congel"
	lab var cuisin 	"Menage a cuisiniere elec/gaz"
	lab var ordin 	"Menage a ordinateur"
	lab var decod 	"Menage a decodeur/antenne"
	lab var car 	"Menage a voiture"
	
	lab var moto 	"Menage a moto"
	lab var radio 	"Menage a radio"
	lab var fan 	"Menage a fan"
	lab var landline "Menage a landline"
	lab var mobile 	"Menage a mobile"
	lab var boat 	"Menage a boat"
	lab var aircond "Menage a aircond"
	
	
save "${swdTemp}/household_assets1.dta", replace


use "${swdDataraw}/Menage/s19_me_sen_2021.dta", clear

gen hhid=grappe*100+menage 
	sort hhid s19q02
	
	gen tractor=s19q02==101 & s19q03==1
	gen wagon=s19q02==114 & s19q03==1
	
	collapse (sum) tractor wagon, by (hhid)
	
	lab var tractor "Menage a tractor"
	lab var wagon "Menage a wagon"
	
	
save "${swdTemp}/household_assets2.dta", replace


use "${swdDataraw}/Menage/s11_me_sen_2021.dta", clear

gen hhid=grappe*100+menage 
	sort hhid 
	
	gen aircond_b=s11q03__1==1
	gen hotwater=s11q03__2==1
	gen fan_b=s11q03__3==1
	
	local vars_assets "aircond_b hotwater fan_b"
	collapse (sum) `vars_assets', by (hhid)
	
	lab var aircond_b "Menage a aircond_b (mod 11)"
	lab var hotwater  "Menage a hotwater (mod 11)"
	lab var fan_b 	  "Menage a fan_b (mod 11)"
	
	
save "${swdTemp}/household_assets3.dta", replace


********************************************************
** Livestock  -------------
********************************************************

use "${swdDatain}/ehcvm_menage_SEN_2021.dta", clear

	ren grosrum  c_largerum 
	ren petitrum c_smallrum 
	ren volail 	 c_poultry
	
	label var c_poultry   "# Poultry"
	label var c_largerum  "# large ruminants(horses, bovine)"
	label var c_smallrum  "# small ruminants(goats, sheep)"
	
save "${swdTemp}/household_temp2.dta", replace


**# Welfare data ---------------------------

use "${swdDatain}/ehcvm_welfare_SEN_2021.dta", clear

apoverty pcexp [aw = hhweight*hhsize], varpl(zref)

keep hhid grappe menage vague hhweight hhsize pcexp zref region milieu

gen logzise = ln(hhsize)

save "${swdTemp}/welfare_temp.dta", replace

********************************************************
** Demographics  -------------
********************************************************

**## literacy in french ------
use "${swdDataraw}/Menage/s02_me_sen_2021.dta", clear
	
	gen hhid=grappe*100+menage 
	gen french_lit=s02q01__1==1 & s02q02__1==1
	keep if s01q00a == 1
	keep hhid french_lit
	
save "${swdTemp}/french_temp.dta", replace
	
**## education ------
use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

	keep if lien == 1 /*Keep only head of hh*/
	keep hhid alfa alfa2
	save "${swdTemp}/educ_temp.dta", replace

**## dependency ratios ------
use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

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
merge 1:1 hhid using "${swdTemp}/household_assets1.dta", nogen 

merge 1:1 hhid using "${swdTemp}/household_assets2.dta", nogen 

merge 1:1 hhid using "${swdTemp}/household_assets3.dta", nogen 

merge 1:1 hhid using "${swdTemp}/household_temp2.dta", nogen 

merge 1:1 hhid using "${swdTemp}/welfare_temp.dta", nogen 

merge 1:1 hhid using "${swdTemp}/educ_temp.dta", nogen 

merge 1:1 hhid using "${swdTemp}/french_temp.dta", nogen // 839 households withouth info, needs to fix some issues with id variable 


save "${swdFinal}/data4model_2021.dta", replace

