****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Estimation & Data Merge - larger model					   *
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
log using "$log/SEN_PMT_HBSestimates_largermodel.log", replace 

global weight popweight
global lnwelfare lpcexp
global welfare pcexp

****************URBAN*****************************
use "$data/data4model_2021_2.dta", clear
keep if milieu==1 // (milieu: 1=urban, 2=rural)

global xvar	c_connectowater c_typehousing_2 c_connectedtoint dem_alfa_french c_walls_2 a_gastank a_computer c_lighting_1 c_numberofrooms_c a_cupboard region_1 a_carpet c_housingocup_3 c_floor_2 a_fan region_6 a_satellite region_8 a_fridge c_connectedtotv region_11 region_12 c_roof_1 dem_logsize dem_emp_rate

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

tempfile urban_pred
save `urban_pred', replace emptyok

****************RURAL*****************************
use "$data/data4model_2021_2.dta", clear
keep if milieu==2 // (milieu: 1=urban, 2=rural)

global xvar dem_hage a_fridge c_fuelfirst_3 dem_alfa_french a_moped a_fan region_2 region_3 a_tv c_lighting_1 region_6 region_7 l_sheep c_floor_2 c_walls_2 region_11 a_carpet region_13 dem_logsize c_floor_1 a_cupboard c_numberofrooms_c c_roof_1 a_charcoaliron a_gastank

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

append using `urban_pred'

save "$data/data4model_2021_IMPUTED_largermodel.dta", replace

capture log close
