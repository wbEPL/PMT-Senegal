/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates Senegal PMT. 
*	The input files are: 
*		- data4model_2021.dta
*	The following result files are created:
*		- TBD
*	Open points that need to be addressed:
* 		- Should we use water source during dry or rainy season?
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 23 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

**# Add accurate measure function
include "$scripts/02_00_create_accuracy_function.do"

**# OLS ---
**## Rural -----

use "${swdFinal}/data4model_2021.dta", clear

reg lpcexp logsize oadr yadr ///
			i.c_floor i.c_water_dry i.c_ligthing i.c_walls i.c_toilet ///
			a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge  ///
			l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 2, r

predict yhat, xb
estimates store ols_rural

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_01_accuracy_rural.do"

**## Urban -----

use "${swdFinal}/data4model_2021.dta", clear

reg lpcexp logsize yadr ///
			i.c_floor i.c_ligthing i.c_toilet i.c_walls ///
			a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor a_iron ///
			l_donkeys_n l_equines_n l_pigs_n ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 1, r
predict yhat, xb
estimates store ols_urban

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_02_accuracy_urban.do"


**## Lasso 1 rural, assets and livestock as dummy, include all livestock separately --------------
use "${swdFinal}/data4model_2021.dta", clear

**### globals of variables
global demo "logsize oadr yadr alfa_french i.region"

global asset_dum "a_living a_dining a_bed a_singlemat a_cupboard a_carpet a_iron a_charcoaliron a_stove a_gastank a_hotplate a_oven a_fireplace a_foodprocessor a_fruitpress a_fridge a_freezer a_fan a_radio a_tv a_dvd a_satellite a_washer a_vacuum a_ac a_lawnmower a_generator a_car a_moped a_bike a_camera a_camcorder a_hifisystem a_homephone a_cellphone a_tablet a_computer a_printer a_videocam a_boat a_shotgun a_guitar a_piano a_building a_land ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_dum "ar_tractor ar_sprayer ar_tiller ar_multicultiva ar_plough ar_axe_pickaxe ar_hoe_daba_hill ar_machete ar_asinine_hoe ar_seed_drill ar_harrow ar_plou_anima ar_carts ar_beehives ar_rice_husker ar_corn_sheller ar_thresher ar_motor_pump ar_hand_pump ar_scale ar_bund_mach ar_straw_chop ar_drinker_fee ar_mower ar_mill ar_fertili_spre ar_milk_machi ar_incubator ar_motor_canoe ar_no_motor_can ar_gill_net ar_seine ar_sparrowhawk ar_hook_longli ar_harpoon ar_others"

global dwell "i.c_typehousing c_numberofrooms_c i.c_housingocup i.c_businessindwe i.c_walls i.c_roof i.c_floor i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_ligthing i.c_landline i.c_connectedtoint i.c_internettype i.c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet"

global livest_all_dum "l_bovines l_sheep l_goats l_camels l_horses l_donkeys l_pigs l_rabbits l_chickens l_guinea_fowl l_other_poultry"

**### split sample

splitsample, generate(sample) nsplit(2)
label define sample 1 "Training" 2 "Testing"
label values sample sample


lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 2 & sample == 1
estimates store rural1
cvplot
graph save "${swdResults}/graphs/cvplot_rural1", replace
lassocoef rural1
lassogof rural1, over(sample) postselection
predict yhat  if milieu == 2, xb postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_03_accuracy_rural1_lasso.do"

**## Lasso 2 rural, assets and livestock as number --------------

**### globals of variables
global asset_num "a_living_n a_dining_n a_bed_n a_singlemat_n a_cupboard_n a_carpet_n a_iron_n a_charcoaliron_n a_stove_n a_gastank_n a_hotplate_n a_oven_n a_fireplace_n a_foodprocessor_n a_fruitpress_n a_fridge_n a_freezer_n a_fan_n a_radio_n a_tv_n a_dvd_n a_satellite_n a_washer_n a_vacuum_n a_ac_n a_lawnmower_n a_generator_n a_car_n a_moped_n a_bike_n a_camera_n a_camcorder_n a_hifisystem_n a_homephone_n a_cellphone_n a_tablet_n a_computer_n a_printer_n a_videocam_n a_boat_n a_shotgun_n a_guitar_n a_piano_n a_building_n a_land_n ad_aircond_b ad_hotwater ad_fan_b"

global asset_rur_num "ar_tractor_n ar_sprayer_n ar_tiller_n ar_multicultiva_n ar_plough_n ar_axe_pickaxe_n ar_hoe_daba_hill_n ar_machete_n ar_asinine_hoe_n ar_seed_drill_n ar_harrow_n ar_plou_anima_n ar_carts_n ar_beehives_n ar_rice_husker_n ar_corn_sheller_n ar_thresher_n ar_motor_pump_n ar_hand_pump_n ar_scale_n ar_bund_mach_n ar_straw_chop_n ar_drinker_fee_n ar_mower_n ar_mill_n ar_fertili_spre_n ar_milk_machi_n ar_incubator_n ar_motor_canoe_n ar_no_motor_can_n ar_gill_net_n ar_seine_n ar_sparrowhawk_n ar_hook_longli_n ar_harpoon_n ar_others_n"

global livest_all_num "l_bovines_n l_sheep_n l_goats_n l_camels_n l_horses_n l_donkeys_n l_pigs_n l_rabbits_n l_chickens_n l_guinea_fowl_n l_other_poultry_n"


lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 2 & sample == 1
estimates store rural2
cvplot
graph save "${swdResults}/graphs/cvplot_rural2", replace
lassocoef rural1 rural2
lassogof rural1 rural2, over(sample) postselection
drop  yhat qhat qreal

predict yhat if milieu == 2, xb postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_04_accuracy_rural2_lasso.do"


**## Lasso 1 urban, assets as dummy ------------------

lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 1 & sample == 1
estimates store urban1
cvplot
graph save "${swdResults}/graphs/cvplot_urban1", replace
lassocoef urban1
lassogof urban1, over(sample) postselection
predict yhat if milieu == 1, xb postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_05_accuracy_urban1_lasso.do"

**## Lasso 2 urban, assets and livestock as number --------------


lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 1 & sample == 1
estimates store urban2
cvplot
graph save "${swdResults}/graphs/cvplot_urban2", replace
lassocoef urban1 urban2
lassogof urban1 urban2, over(sample) postselection
drop  yhat qhat qreal

predict yhat if milieu == 1, xb postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

accuracy_measures
run "$scripts/02_06_accuracy_urban2_lasso.do"