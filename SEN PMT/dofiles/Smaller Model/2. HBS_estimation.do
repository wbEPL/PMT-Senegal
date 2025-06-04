****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Estimation & Data Merge									   *
* Jeremy Schneider - May 2025								   *
****************************************************************
* Calculate predicted expenditure and merge urban & rural together

clear all 
version 17
cap ssc install xtable

global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"

capture log close
log using "$log/SEN_PMT_HBSestimates.log", replace 

global weight popweight
global lnwelfare lpcexp
global welfare pcexp

****************URBAN*****************************
use "$data/data4model_2021_2.dta", clear
keep if milieu==1 // (milieu: 1=urban, 2=rural)

global xvar	a_fridge a_computer c_walls_2 dem_alfa_french c_connectedtoint c_numberofrooms_c c_lighting_1 c_connectedtotv dem_logsize a_satellite region_2 c_floor_2 c_connectowater c_typehousing_2 a_cupboard region_9 a_gastank dem_emp_rate

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

tempfile urban_pred
save `urban_pred', replace emptyok



****************RURAL*****************************
use "$data/data4model_2021_2.dta", clear
keep if milieu==2 // (milieu: 1=urban, 2=rural)

global xvar a_tv a_fridge a_charcoaliron c_roof_1 a_moped dem_logsize c_walls_1 c_numberofrooms_c a_fan a_carpet region_11 c_lighting_1 l_sheep a_cupboard

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

append using `urban_pred'

save "$data/data4model_2021_IMPUTED.dta", replace


****************ALT NATIONAL*****************************
use "$data/data4model_2021_2.dta", clear

global xvar c_connectedtotv c_lighting_1 c_connectowater dem_alfa_french a_satellite region_1 c_walls_1 a_fan dem_logsize dem_emp_rate a_cupboard c_numberofrooms_c c_roof_1 a_fridge c_floor_2

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)


save "$data/data4model_2021_IMPUTED_altnational.dta", replace

capture log close


