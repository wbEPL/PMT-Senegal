****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Urban Model Creation										   *
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
log using "$log/SEN_PMT_Model_Urban.log", replace 

use "$data/data4model_2021_2.dta", clear
cap svyset, clear
keep if milieu==1 // (milieu: 1=urban, 2=rural)

****************************************************************

global weight popweight
global lnwelfare lpcexp
global welfare pcexp

****************************************************************
*Set globals for variables available for selection in stepwise 
****************************************************************
global headdem 	dem_hage dem_hhandig dem_hmale /*dem_heduc_**/ dem_alfa_french dem_hactiv12m dem_branch_*
global demo 	region_* dem_logsize dem_emp_rate dem_gender_rate
global house 	c_housingocup_* c_numberofrooms_c c_roof_* c_walls_* c_lighting_* /*c_fuelfirst_* */ c_toilet_* c_connectedtoint c_connectedtotv c_connectowater c_connectoelec_* c_fuelfirst_3 /*c_floor_1*/ c_floor_2 c_floor_3 /*c_typehousing_1*/ c_typehousing_2 c_typehousing_3 c_typehousing_4
global assets 	a_computer a_fan /*a_ac*/ a_tv /*a_living*/ /*a_iron*/ a_charcoaliron a_fridge /*a_car*/ /*a_stove*/ a_carpet a_gastank a_moped a_satellite a_cupboard
global production  ar_carts ar_plou_anima /*ar_tractor*/ ar_mill a_camera ar_motor_pump
global livestock 	l_bovines l_goats l_sheep l_poultry l_pigs l_horses l_donkeys l_camels

global startingvars $headdem $demo $house $assets $production $livestock			

****************************************************************
*Run stepwise regression
****************************************************************
svyset [pw=$weight], strata(region)

stepwise, pr(0.000101) pe(0.0001): reg $lnwelfare $startingvars [pw=$weight]

matrix X = e(b)
matrix X = X[1,1..`e(df_m)']
global xvar: colnames X
fsum $xvar [aw=$weight], label
fsum dem_logsize hhsize, label

			
capture log close

