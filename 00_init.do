* ------------------------------------------------------------------
*	Authors:  Daniel Valderrama dvalderramagonza@worldbank.org
*			  Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*			  Kazusa Yoshimura <kyoshimura1@worldbank.org> 
*	Last edited: 20 May 2024
* 	Version 2.0 created by Daniel VAlderrama 
*-------------------------------------------------------------------
 
clear all
set more off
set maxvar 32000
set seed 10051990 
set sortseed 10051990 


* Define username
global suser = c(username)

*Gabriel create globals for folders
else if (inlist("${suser}","wb545737")) {
	//@Gabriel please update your paths following the logic I outlined below. There are three main folder that are not necessary together. 
		global gitrepo "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/scripts/scripts_gc/gitrepo" 
		global project "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/"
		
		global data_library = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - EHCVM/" 
		
	
}
*Daniel
else if (inlist("${suser}","wb419055")) {

	global gitrepo "C:/Users/wb419055/OneDrive - WBG/West Africa/Senegal/5_Projects/03_PMT/scripts/git_PMT-Senegal"
	global project "C:/Users/wb419055/OneDrive - WBG/West Africa/Senegal/5_Projects/03_PMT"
	global data_library  "C:/Users/wb419055/OneDrive - WBG/West Africa/Senegal/1_data/EHCVM" 
}

*folder from data library
global swdDataraw   "${data_library}/EHCVM_2021/Datain" 
global swdDatain	"${data_library}/EHCVM_2021/Dataout"
 
*folder from project 
global scripts 		"$gitrepo"
global swdTemp		"$project/data/temp"
global swdFinal		"$project/data/final"
global swdResults	"$project/results"

* Making sure fre gtools and egenmor packages are installed, if not install them
local commands = "fre gtools quantiles outreg2"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc!=0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

* Add created functions for workplace
run "$gitrepo/ado/functions.do"


*-----------------------------------------------------------------*
**### 	A. List of variables 
*-----------------------------------------------------------------*


**### globals of categorical variables 

global categorical_v "region c_typehousing c_numberofrooms_c c_housingocup c_businessindwe c_walls c_roof c_floor c_connectowater c_water_dry c_water_rainy c_connectoelec c_lighting c_landline c_connectedtoint c_internettype c_connectedtotv c_fuelfirst_r c_garbage c_toilet dem_hgender dem_hethnie dem_halfa  dem_hhandig  dem_hage dem_hmstat dem_heduc dem_hactiv7j dem_hactiv12m"

global demo "dem_alfa_french dem_oadr dem_yadr dem_working_age dem_emp_rate dem_gender_rate dem_logadults i.dem_hgender i.dem_hethnie i.dem_halfa i.dem_hhandig dem_logsize i.dem_hage i.dem_hmstat i.dem_heduc i.dem_hactiv7j i.dem_hactiv12m dem_branch dem_hcsp" // 

global dwell "c_rooms_pc i.c_typehousing c_numberofrooms_c i.c_housingocup i.c_businessindwe i.c_walls i.c_roof i.c_floor i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_lighting i.c_landline i.c_connectedtoint i.c_internettype i.c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet"

**### Consumption 
global consumption "cereal meat fish milk oil fruit vegetable legume sugar"

**### Shock 
global shock "illness_accident death divorce flood_drought agriculture food_price theft conflict"

**### 	List of variable for which we have a detailed and aggregated version   ###**

	**### Farm assets 
	global asset_rur_dum "ar_tractor ar_sprayer ar_tiller ar_multicultiva ar_plough ar_axe_pickaxe ar_hoe_daba_hill ar_machete ar_asinine_hoe ar_seed_drill ar_harrow ar_plou_anima ar_carts ar_beehives ar_rice_husker ar_corn_sheller ar_thresher ar_motor_pump ar_hand_pump ar_scale ar_bund_mach ar_straw_chop ar_drinker_fee ar_mower ar_mill ar_fertili_spre ar_milk_machi ar_incubator ar_motor_canoe ar_no_motor_can ar_gill_net ar_seine ar_sparrowhawk ar_hook_longli ar_harpoon ar_others"
	
	
	global asset_rur_num "ar_tractor_n ar_sprayer_n ar_tiller_n ar_multicultiva_n ar_plough_n ar_axe_pickaxe_n ar_hoe_daba_hill_n ar_machete_n ar_asinine_hoe_n ar_seed_drill_n ar_harrow_n ar_plou_anima_n ar_carts_n ar_beehives_n ar_rice_husker_n ar_corn_sheller_n ar_thresher_n ar_motor_pump_n ar_hand_pump_n ar_scale_n ar_bund_mach_n ar_straw_chop_n ar_drinker_fee_n ar_mower_n ar_mill_n ar_fertili_spre_n ar_milk_machi_n ar_incubator_n ar_motor_canoe_n ar_no_motor_can_n ar_gill_net_n ar_seine_n ar_sparrowhawk_n ar_hook_longli_n ar_harpoon_n ar_others_n"
	
	**### Home assets 
	global asset_num "a_living_n a_dining_n a_bed_n a_singlemat_n a_cupboard_n a_carpet_n a_iron_n a_charcoaliron_n a_stove_n a_gastank_n a_hotplate_n a_oven_n a_fireplace_n a_foodprocessor_n a_fruitpress_n a_fridge_n a_freezer_n a_fan_n a_radio_n a_tv_n a_dvd_n a_satellite_n a_washer_n a_vacuum_n a_ac_n a_lawnmower_n a_generator_n a_car_n a_moped_n a_bike_n a_camera_n a_camcorder_n a_hifisystem_n a_homephone_n a_cellphone_n a_tablet_n a_computer_n a_printer_n a_videocam_n a_boat_n a_shotgun_n a_guitar_n a_piano_n a_building_n a_land_n ad_aircond_b ad_hotwater ad_fan_b"
	
	global asset_dum "a_living a_dining a_bed a_singlemat a_cupboard a_carpet a_iron a_charcoaliron a_stove a_gastank a_hotplate a_oven a_fireplace a_foodprocessor a_fruitpress a_fridge a_freezer a_fan a_radio a_tv a_dvd a_satellite a_washer a_vacuum a_ac a_lawnmower a_generator a_car a_moped a_bike a_camera a_camcorder a_hifisystem a_homephone a_cellphone a_tablet a_computer a_printer a_videocam a_boat a_shotgun a_guitar a_piano a_building a_land ad_aircond_b ad_hotwater ad_fan_b"
	
	
	**### Livestock 
	global livest_all_dum "l_bovines l_sheep l_goats l_camels l_horses l_donkeys l_pigs l_rabbits l_chickens l_guinea_fowl l_other_poultry"
	
	global livest_all_num "l_bovines_n l_sheep_n l_goats_n l_camels_n l_horses_n l_donkeys_n l_pigs_n l_rabbits_n l_chickens_n l_guinea_fowl_n l_other_poultry_n"
	

*-----------------------------------------------------------------*
**### B. Model parameters:  LASSO models & SWIFT p-values 
*-----------------------------------------------------------------*

local step1_lasso 10
local step2_lasso 20
local step3_lasso 25

**### Levels of SWIFT models 

local SWIFT_l1 "0.05"
local SWIFT_l2 "0.000001"
local light_version "yes" // Options: yes = it will run selected models OLS, LASSO1 and SWIwill run just few models, no will run everything  



*-----------------------------------------------------------------*
**### C. Sets of specifications 
*-----------------------------------------------------------------*

**### Model specifications 

// Original PMT models specifications (also used in the models we defined as LASSO 3)
global PMT_rural "dem_logsize dem_oadr dem_yadr c_rooms_pc i.c_floor i.c_water_dry i.c_lighting i.c_walls i.c_toilet 	a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n 	i.region "

global PMT_urban "dem_logsize dem_yadr dem_alfa_french c_rooms_pc i.c_floor i.c_lighting i.c_toilet i.c_roof a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor  a_iron  l_donkeys_n l_horses_n l_pigs_n "

// LASSO 1-2 & SWIFT models 
global cov_set1 "$demo $dwell $asset_dum $asset_rur_dum  $livest_all_dum" // LASSO1  & SWIFT
global cov_set2 "$demo $dwell $asset_num $asset_rur_num  $livest_all_num" // LASSO 2 
global cov_set3 "$demo $dwell $asset_dum $asset_rur_dum  $livest_all_dum $consumption" // Swift plus
global cov_set4 "$demo $dwell $asset_dum $asset_rur_dum  $livest_all_dum $shock" // LASSO1 with shocks
*-----------------------------------------------------------------*
**### D. Project trunks 
*-----------------------------------------------------------------*

// Cleaning dataset on assets, dwelling characteristics and other (only once)
	*include "$scripts/01_00_createData.do"

// Running models 
	include "$scripts/02_00_estimate_models.do"



