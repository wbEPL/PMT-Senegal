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
include "$scripts/02_00_create_accuracy_function.do"


**## split sample

splitsample, generate(sample) split(0.7 0.3)
label define sample 1 "Training" 2 "Testing"
label values sample sample


**# OLS same as 2015 covariates ---
include "$scripts/02_01_estimate_ols.do"

**# Lassos ------------------------
**### globals of variables livestock as dummy
global demo "logsize oadr yadr alfa_french i.region"

global asset_dum "a_living a_dining a_bed a_singlemat a_cupboard a_carpet a_iron a_charcoaliron a_stove a_gastank a_hotplate a_oven a_fireplace a_foodprocessor a_fruitpress a_fridge a_freezer a_fan a_radio a_tv a_dvd a_satellite a_washer a_vacuum a_ac a_lawnmower a_generator a_car a_moped a_bike a_camera a_camcorder a_hifisystem a_homephone a_cellphone a_tablet a_computer a_printer a_videocam a_boat a_shotgun a_guitar a_piano a_building a_land ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_dum "ar_tractor ar_sprayer ar_tiller ar_multicultiva ar_plough ar_axe_pickaxe ar_hoe_daba_hill ar_machete ar_asinine_hoe ar_seed_drill ar_harrow ar_plou_anima ar_carts ar_beehives ar_rice_husker ar_corn_sheller ar_thresher ar_motor_pump ar_hand_pump ar_scale ar_bund_mach ar_straw_chop ar_drinker_fee ar_mower ar_mill ar_fertili_spre ar_milk_machi ar_incubator ar_motor_canoe ar_no_motor_can ar_gill_net ar_seine ar_sparrowhawk ar_hook_longli ar_harpoon ar_others"

global dwell "i.c_typehousing c_numberofrooms_c i.c_housingocup i.c_businessindwe i.c_walls i.c_roof i.c_floor i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_ligthing i.c_landline i.c_connectedtoint i.c_internettype i.c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet"

global livest_all_dum "l_bovines l_sheep l_goats l_camels l_horses l_donkeys l_pigs l_rabbits l_chickens l_guinea_fowl l_other_poultry"


**### globals of variables assets and livestock as number
global asset_num "a_living_n a_dining_n a_bed_n a_singlemat_n a_cupboard_n a_carpet_n a_iron_n a_charcoaliron_n a_stove_n a_gastank_n a_hotplate_n a_oven_n a_fireplace_n a_foodprocessor_n a_fruitpress_n a_fridge_n a_freezer_n a_fan_n a_radio_n a_tv_n a_dvd_n a_satellite_n a_washer_n a_vacuum_n a_ac_n a_lawnmower_n a_generator_n a_car_n a_moped_n a_bike_n a_camera_n a_camcorder_n a_hifisystem_n a_homephone_n a_cellphone_n a_tablet_n a_computer_n a_printer_n a_videocam_n a_boat_n a_shotgun_n a_guitar_n a_piano_n a_building_n a_land_n ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_num "ar_tractor_n ar_sprayer_n ar_tiller_n ar_multicultiva_n ar_plough_n ar_axe_pickaxe_n ar_hoe_daba_hill_n ar_machete_n ar_asinine_hoe_n ar_seed_drill_n ar_harrow_n ar_plou_anima_n ar_carts_n ar_beehives_n ar_rice_husker_n ar_corn_sheller_n ar_thresher_n ar_motor_pump_n ar_hand_pump_n ar_scale_n ar_bund_mach_n ar_straw_chop_n ar_drinker_fee_n ar_mower_n ar_mill_n ar_fertili_spre_n ar_milk_machi_n ar_incubator_n ar_motor_canoe_n ar_no_motor_can_n ar_gill_net_n ar_seine_n ar_sparrowhawk_n ar_hook_longli_n ar_harpoon_n ar_others_n"

global livest_all_num "l_bovines_n l_sheep_n l_goats_n l_camels_n l_horses_n l_donkeys_n l_pigs_n l_rabbits_n l_chickens_n l_guinea_fowl_n l_other_poultry_n"


**## Lasso 1 rural, assets and livestock as dummy, include all livestock separately --------------
include "$scripts/02_02_estimate_lasso1_rural.do"

**## Lasso 2 rural, assets and livestock as number --------------
include "$scripts/02_03_estimate_lasso2_rural.do"

**## Lasso 1 urban, assets as dummy ------------------
include "$scripts/02_04_estimate_lasso1_urban.do"

**## Lasso 2 urban, assets and livestock as number --------------
include "$scripts/02_05_estimate_lasso2_urban.do"

**## Lasso 3 urban and rural, start same covariates 2015, do not move lambdas--------------
include "$scripts/02_06_estimate_lasso3.do"

**# Goodness of fit rural
qui putexcel set "$swdResults/goodness.xlsx", replace sheet("Rural")
lassogof ols_rural /// ols 2021
		rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols /// model 1
		rural2_ols rural2_lam02_ols rural2_lam03_ols rural2_lam05_ols /// model2
		rural3_ols if milieu == 2, over(sample)

matrix list r(table)
qui putexcel B2 = matrix(r(table))

qui putexcel A1 = "Model", bold
qui putexcel B1 = "MSE", bold
qui putexcel C1 = "R-squared", bold
qui putexcel D1 = "N-obs", bold

forvalues i = 2(2)20 {
	local j = `i' + 1
    qui putexcel (A`i':A`j'), merge hcenter vcenter
}

local row = 2
qui putexcel A`row' = "Ols as 2015"

foreach l in 1 2 {
    local row = `row' + 2
    qui putexcel A`row' = "Lasso `l', lambda CV"
    foreach lambda in 0.01 0.03 0.05 {
        local row = `row' + 2
        qui putexcel A`row' = "Lasso `l', lambda `lambda'"
    }
}

local row = `row' + 2
qui putexcel A`row' = "Lasso 3, lambda CV"



putexcel save