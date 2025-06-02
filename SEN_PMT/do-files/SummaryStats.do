****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Variable Comparison 										   *
* Danielle Aron - March 2025								   *
****************************************************************
clear all 

global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"

capture log close
*log using "$log\SEN_PMT_SummaryStats", replace 

* small model
global allmodel a_carpet a_charcoaliron a_computer a_cupboard a_fan a_fridge a_gastank a_moped a_satellite a_tv c_connectedtoint c_connectedtotv c_connectowater c_floor_2 c_lighting_1 c_numberofrooms_c c_roof_1 c_typehousing_2 c_walls_1 c_walls_2 dem_alfa_french dem_emp_rate dem_logsize l_sheep region_2 region_9 region_11

* large model
global allmodel_larger a_carpet a_charcoaliron a_computer a_cupboard a_fan a_fridge a_gastank a_moped a_satellite a_tv c_connectedtoint c_connectedtotv c_connectowater c_floor_1 c_floor_2 c_fuelfirst_3 c_housingocup_3 c_lighting_1 c_numberofrooms_c c_roof_1 c_typehousing_2 c_walls_2 dem_alfa_french dem_emp_rate dem_hage dem_logsize l_sheep region_1 region_2 region_3 region_6 region_7 region_8 region_11 region_12 region_13

****************************************************************
* HBS / training data - small model
****************************************************************
qui use "$data/data4model_2021_2.dta", clear

* Overall HBS summary stats
fsum $allmodel hhsize 
fsum $allmodel_larger [aw=popweight]

* summary stats of poorest 40% (bottom 40) in HBS
fsum $allmodel hhsize  if b40==1
fsum $allmodel_larger [aw=popweight] if b40==1

/*
* summary stats of poorest 50% in HBS
qui preserve
qui sum pcexp [aw=popweight], d
qui return list
qui drop if pcexp <= `r(p50)'
display "Performance Statistics for HBS bottom 50%"
fsum $allmodel [aw=popweight]
qui restore 

* summary stats of poorest 25% in HBS
qui preserve
qui sum pcexp [aw=popweight], d
qui return list
qui drop if pcexp <= `r(p25)' // limiting to poorest 25% households
display "Performance Statistics for HBS bottom 25%"
fsum $allmodel [aw=popweight]
qui restore 
*/
****************************************************************
* RNU - small model
****************************************************************
qui use "$data/RNU_2024_clean.dta", clear 

fsum $allmodel hhsize [aw=popweight]
fsum c_numberofrooms_c [aw=popweight]


*********************************************************************************


****************************************************************
* RNU - large model
****************************************************************
qui use "$data/RNU_2024_clean.dta", clear 

fsum $allmodel_larger [aw=popweight]



cap log close
