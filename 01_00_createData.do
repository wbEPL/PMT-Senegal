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
* 	Version 2.0 created by Daniel VAlderrama 
*	Reviewer: TBD
*	Last Reviewed: TBD

Notes: 
Dwellings: 
less variance in soil (from 5 to 4)
Water: neighbor faucet
Electricity:  lap solaire tag as lamp Rechargeable
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

Dependency ratios
		-Over working age population or over household size 
*/	 		
*-------------------------------------------------------------------------------	

	
********************************************************
**# Dewelling charactersitics  -------------
********************************************************

run "$scripts/01_01_dwelling_data.do"
	
********************************************************
**# Assets  -------------
********************************************************

run "$scripts/01_02_assets_data.do"


********************************************************
** Livestock  -------------
********************************************************

run "$scripts/01_03_livestock_data.do"

********************************************************
** Consumption  -------------
********************************************************

run "$scripts/01_05_consumption_data.do"

********************************************************
** Demographics and welfare
********************************************************

include "$scripts/01_04_demog_welfare_data.do"

**# Merge data -----

merge 1:1 hhid using "${swdTemp}/household_assets1.dta", nogen 

merge 1:1 hhid using "${swdTemp}/household_assets_rural2.dta", nogen // 2972 households do not report rural assets

merge 1:1 hhid using "${swdTemp}/household_assets3.dta", nogen 

merge 1:1 hhid using "${swdTemp}/dwelling_temp.dta", nogen 

merge 1:1 hhid using "${swdTemp}/household_livestock.dta", nogen 


merge 1:1 hhid using "${swdTemp}/individual_temp.dta", nogen 
merge 1:1 hhid using "${swdTemp}/hhead_dta.dta", nogen 

merge 1:1 hhid using "${swdTemp}/french_temp.dta", nogen // 839 households withouth hh head info 

merge 1:1 hhid using "${swdTemp}/consumption.dta", nogen 

gen lpcexp=ln(pcexp)
replace c_rooms_pc=c_rooms_pc/hhsize

**## split sample 

splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
label define sample 1 "Training" 2 "Testing"
label values sample sample

gen popweight = hhsize*hhweight
gen pauvre = (pcexp <= zref)
svyset [pw=popweight], strata(region) 
set seed 0123456
save "${swdFinal}/data4model_2021.dta", replace

