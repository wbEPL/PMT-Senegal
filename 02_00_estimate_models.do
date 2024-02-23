/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates Senegal PMT. 
*	The input files are: 
*		- data4model_2021.dta
*	The following result files are created:
*		- TBD
*	Open points that need to be addressed:
* 		- is there a way to automate the inclusion of selected lasso vars  in ols?
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

**# INIT ----------------------
use "${swdFinal}/data4model_2021.dta", clear

**## Add accurate measure function
include "$scripts/02_00a_create_accuracy_function.do"


**## split sample

splitsample, generate(sample) split(0.7 0.3)
label define sample 1 "Training" 2 "Testing"
label values sample sample

**# OLS same as 2015 covariates ---
include "$scripts/02_01_estimate_ols.do"



**# Lassos ------------------------
**### globals of categorical variables 
global categorical_v "region c_typehousing c_numberofrooms_c c_housingocup c_businessindwe c_walls c_roof c_floor c_connectowater c_water_dry c_water_rainy c_connectoelec c_lighting c_landline c_connectedtoint c_internettype c_connectedtotv c_fuelfirst_r c_garbage c_toilet"


**### globals of variables livestock as dummy
global demo "logsize oadr yadr c_rooms_pc alfa_french i.region"

global asset_dum "a_living a_dining a_bed a_singlemat a_cupboard a_carpet a_iron a_charcoaliron a_stove a_gastank a_hotplate a_oven a_fireplace a_foodprocessor a_fruitpress a_fridge a_freezer a_fan a_radio a_tv a_dvd a_satellite a_washer a_vacuum a_ac a_lawnmower a_generator a_car a_moped a_bike a_camera a_camcorder a_hifisystem a_homephone a_cellphone a_tablet a_computer a_printer a_videocam a_boat a_shotgun a_guitar a_piano a_building a_land ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_dum "ar_tractor ar_sprayer ar_tiller ar_multicultiva ar_plough ar_axe_pickaxe ar_hoe_daba_hill ar_machete ar_asinine_hoe ar_seed_drill ar_harrow ar_plou_anima ar_carts ar_beehives ar_rice_husker ar_corn_sheller ar_thresher ar_motor_pump ar_hand_pump ar_scale ar_bund_mach ar_straw_chop ar_drinker_fee ar_mower ar_mill ar_fertili_spre ar_milk_machi ar_incubator ar_motor_canoe ar_no_motor_can ar_gill_net ar_seine ar_sparrowhawk ar_hook_longli ar_harpoon ar_others"

global dwell "i.c_typehousing c_numberofrooms_c i.c_housingocup i.c_businessindwe i.c_walls i.c_roof i.c_floor i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_lighting i.c_landline i.c_connectedtoint i.c_internettype i.c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet"

global livest_all_dum "l_bovines l_sheep l_goats l_camels l_horses l_donkeys l_pigs l_rabbits l_chickens l_guinea_fowl l_other_poultry"


**### globals of variables assets and livestock as number
global asset_num "a_living_n a_dining_n a_bed_n a_singlemat_n a_cupboard_n a_carpet_n a_iron_n a_charcoaliron_n a_stove_n a_gastank_n a_hotplate_n a_oven_n a_fireplace_n a_foodprocessor_n a_fruitpress_n a_fridge_n a_freezer_n a_fan_n a_radio_n a_tv_n a_dvd_n a_satellite_n a_washer_n a_vacuum_n a_ac_n a_lawnmower_n a_generator_n a_car_n a_moped_n a_bike_n a_camera_n a_camcorder_n a_hifisystem_n a_homephone_n a_cellphone_n a_tablet_n a_computer_n a_printer_n a_videocam_n a_boat_n a_shotgun_n a_guitar_n a_piano_n a_building_n a_land_n ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_num "ar_tractor_n ar_sprayer_n ar_tiller_n ar_multicultiva_n ar_plough_n ar_axe_pickaxe_n ar_hoe_daba_hill_n ar_machete_n ar_asinine_hoe_n ar_seed_drill_n ar_harrow_n ar_plou_anima_n ar_carts_n ar_beehives_n ar_rice_husker_n ar_corn_sheller_n ar_thresher_n ar_motor_pump_n ar_hand_pump_n ar_scale_n ar_bund_mach_n ar_straw_chop_n ar_drinker_fee_n ar_mower_n ar_mill_n ar_fertili_spre_n ar_milk_machi_n ar_incubator_n ar_motor_canoe_n ar_no_motor_can_n ar_gill_net_n ar_seine_n ar_sparrowhawk_n ar_hook_longli_n ar_harpoon_n ar_others_n"

global livest_all_num "l_bovines_n l_sheep_n l_goats_n l_camels_n l_horses_n l_donkeys_n l_pigs_n l_rabbits_n l_chickens_n l_guinea_fowl_n l_other_poultry_n"


tempfile cleaned_dataset
save `cleaned_dataset', replace 


**## Lasso 1 rural, assets and livestock as dummy, include all livestock separately --------------
include "$scripts/02_02_estimate_lasso1_rural.do"

**## Lasso 2 rural, assets and livestock as number --------------
use `cleaned_dataset', replace
include "$scripts/02_03_estimate_lasso2_rural.do"

**## Lasso 1 urban, assets as dummy ------------------
use `cleaned_dataset', replace
include "$scripts/02_04_estimate_lasso1_urban.do"

**## Lasso 2 urban, assets and livestock as number --------------
use `cleaned_dataset', replace
include "$scripts/02_05_estimate_lasso2_urban.do"

**## Lasso 3 urban and rural, start same covariates 2015, do not move lambdas--------------
use `cleaned_dataset', replace
include "$scripts/02_06_estimate_lasso3.do"


**# Goodness of fit rural
use `cleaned_dataset', replace
include "$scripts/02_07_goodness_fit.do"

/* to delete after testing 02_07 
qui putexcel set "$swdResults/goodness.xlsx", modify sheet("Rural")
lassogof ols_rural /// ols 2021
		rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols /// model 1
		rural2_ols rural2_lam02_ols rural2_lam03_ols rural2_lam05_ols /// model 2
		rural3_ols if milieu == 2, over(sample)

matrix list r(table)
qui putexcel C2 = matrix(r(table))

qui putexcel A1 = "Model", bold
qui putexcel B1 = "Sample", bold
qui putexcel C1 = "MSE", bold
qui putexcel D1 = "R-squared", bold
qui putexcel E1 = "N-obs", bold

local row = 2
forvalues i = 1/10 {
    qui putexcel B`row' = "Training"
    local row = `row' + 1
    qui putexcel B`row' = "Testing"
    local row = `row' + 1
}

forvalues i = 2(2)20 {
	local j = `i' + 1
    qui putexcel (A`i':A`j'), merge hcenter vcenter
}

qui putexcel A2 = "Ols as 2015"
qui putexcel A4 = "Lasso 1, lambda CV"
qui putexcel A6 = "Lasso 1, lambda 0.01"
qui putexcel A8 = "Lasso 1, lambda 0.03"
qui putexcel A10 = "Lasso 1, lambda 0.05"
qui putexcel A12 = "Lasso 2, lambda CV"
qui putexcel A14 = "Lasso 2, lambda 0.02"
qui putexcel A16 = "Lasso 2, lambda 0.035"
qui putexcel A18 = "Lasso 2, lambda 0.05"
qui putexcel A20 = "Lasso 3, lambda CV"

putexcel save

**# Goodness of fit urban
qui putexcel set "$swdResults/goodness.xlsx", modify sheet("Urban")
lassogof ols_urban /// ols 2021
		urban1_ols urban1_lam_025_ols urban1_lam_05_ols urban1_lam_08_ols /// model 1
		urban2_ols urban2_lam04_ols urban2_lam06_ols urban2_lam08_ols /// model 2
		urban3_ols if milieu == 1, over(sample)

matrix list r(table)
qui putexcel C2 = matrix(r(table))

qui putexcel A1 = "Model", bold
qui putexcel B1 = "Sample", bold
qui putexcel C1 = "MSE", bold
qui putexcel D1 = "R-squared", bold
qui putexcel E1 = "N-obs", bold

local row = 2
forvalues i = 1/10 {
    qui putexcel B`row' = "Training"
    local row = `row' + 1
    qui putexcel B`row' = "Testing"
    local row = `row' + 1
}

forvalues i = 2(2)20 {
	local j = `i' + 1
    qui putexcel (A`i':A`j'), merge hcenter vcenter
}

qui putexcel A2 = "Ols as 2015"
qui putexcel A4 = "Lasso 1, lambda CV"
qui putexcel A6 = "Lasso 1, lambda 0.01"
qui putexcel A8 = "Lasso 1, lambda 0.03"
qui putexcel A10 = "Lasso 1, lambda 0.05"
qui putexcel A12 = "Lasso 2, lambda CV"
qui putexcel A14 = "Lasso 2, lambda 0.02"
qui putexcel A16 = "Lasso 2, lambda 0.035"
qui putexcel A18 = "Lasso 2, lambda 0.05"
qui putexcel A20 = "Lasso 3, lambda CV"

putexcel save

*/