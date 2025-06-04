****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Reweight regions to be equal btwn HBS and RNU as test 	   *
* Jeremy Schneider - May 2025								   *
****************************************************************
clear all 
version 17
cap ssc install xtable

global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"

capture log close
log using "$log/SEN_PMT_reweight_RNUregions.log", replace 


//--------------------------------------
// 1a) In HBS data, create a region‐code

use "$data/data4model_2021_2.dta", clear
keep if b40 == 1

//--------------------------------------
// 1b) Collapse to get the total popweight by region
collapse (sum) popweight, by(region)
rename popweight canpop

save "$results/canonical_region_weights.dta", replace


//--------------------------------------
// 2a) Do it in HBS so you can check it reproduces your original summaries
use "$data/data4model_2021_2.dta", clear
keep if b40 == 1


// 2a.2) merge canonical
merge m:1 region using "$results/canonical_region_weights.dta"
assert _merge==3
drop _merge

// 3) compute actual and new weights
bysort region: egen actpop = total(popweight)
gen double multiplier = canpop/actpop
gen double newpw      = popweight * multiplier

tab region [aw = newpw]
tab region [aw = popweight]
sum a_fridge   [aw=newpw]
sum a_computer [aw=newpw]

use "$data/RNU_2024_clean.dta", clear
drop _merge
merge m:1 region using "$results/canonical_region_weights.dta"
assert _merge==3
drop _merge

bysort region: egen actpop = total(popweight)
gen double multiplier = canpop/actpop
gen double newpw      = popweight * multiplier


sum region* [aw = newpw]
sum region* [aw = popweight]


sum a_carpet a_charcoaliron a_computer a_cupboard a_fan a_fridge a_gastank a_moped a_satellite a_tv c_connectedtoint c_connectedtotv c_connectowater c_floor_2 c_lighting_1 c_numberofrooms_c c_roof_1 c_typehousing_2 c_walls_1 c_walls_2 dem_alfa_french dem_emp_rate dem_logsize l_sheep region_2 region_9 region_11  [aw = newpw]

sum hhsize [aw = newpw]

cap log close
