* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data on assets to estimate Senegal PMT. 
*	It is called by 01_createData.do
*	The input files are: 
*		- Menage/s12_me_sen_2021.dta
*		- Menage/s19_me_sen_2021.dta
*		- Menage/s11_me_sen_2021.dta
*	The following data is created:
*		- household_assets1.dta
*		- household_assets2.dta
*		- household_assets3.dta
*	Open points that need to be addressed:
*		- a_ is for assets, ar_ is for rural equipemente, ad_ for assets from section 11
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 29 January 2024
* 	Version 2.0 created by Daniel Valderrama 
* 	Version 3.0 by Gabriel N. Camargo-Toledo
*	Reviewer: TBD
*	Last Reviewed: TBD
* ----------------------------------------------------------------------- */


**********************************************************
**# Assets from section 12 -------------------------------
**********************************************************
use "${swdDataraw}/Menage/s12_me_sen_2021.dta", clear

gen hhid=grappe*100+menage 

keep hhid grappe menage s12q01 s12q02 s12q03
recode s12q02 (2 = 0) (1 = 1)
label define s12q02 0 "No" 1 "Yes", replace

replace s12q03 = 0 if s12q02 == 0

**## Reshape so column is an asset -----
reshape wide s12q02 s12q03, i(hhid) j(s12q01) favor(speed)

**## Labels and rename dummy ---- 
label var s12q021 "Living room (armchairs and coffee table)"
label var s12q022 "Dining table (table + chairs)"
label var s12q023 "Bed"
label var s12q024 "Single mattress"
label var s12q025 "Cupboards and other furniture"
label var s12q026 "Carpet"
label var s12q027 "Electric iron"
label var s12q028 "Charcoal iron"
label var s12q029 "Gas or electric stove"
label var s12q0210 "Gas cylinder"
label var s12q0211 "Gas or electric hotplate"
label var s12q0212 "Microwave or electric oven"
label var s12q0213 "Improved fireplaces"
label var s12q0214 "Electric food processor (Moulinex)"
label var s12q0215 "Non-electric mixer/fruit press"
label var s12q0216 "Refrigerator"
label var s12q0217 "Freezer"
label var s12q0218 "Free-standing fan"
label var s12q0219 "Radio/Radio cassette"
label var s12q0220 "TV set"
label var s12q0221 "VCR/CD/DVD"
label var s12q0222 "Satellite dish/decoder"
label var s12q0223 "Washing machine, tumble dryer"
label var s12q0224 "Vacuum cleaner"
label var s12q0225 "Air conditioners/splits (not wall-mounted)"
label var s12q0226 "Lawnmowers and other gardening equipment"
label var s12q0227 "Generator"
label var s12q0228 "Personal car"
label var s12q0229 "Moped/moped, motorcycle"
label var s12q0230 "Bicycle, racing bike"
label var s12q0231 "Camera"
label var s12q0232 "Camcorder"
label var s12q0233 "Hi Fi system"
label var s12q0234 "Home phone"
label var s12q0235 "Cell phone"
label var s12q0236 "Tablet"
label var s12q0237 "Computer"
label var s12q0238 "Printer/Fax"
label var s12q0239 "Video camera"
label var s12q0240 "Pirogue and outboard (pleasure boats)"
label var s12q0241 "Shotguns"
label var s12q0242 "Guitar"
label var s12q0243 "Piano and other musical equipment"
label var s12q0244 "Building/House"
label var s12q0245 "Undeveloped land"

rename s12q021 a_living
rename s12q022 a_dining
rename s12q023 a_bed
rename s12q024 a_singlemat
rename s12q025 a_cupboard
rename s12q026 a_carpet
rename s12q027 a_iron
rename s12q028 a_charcoaliron
rename s12q029 a_stove
rename s12q0210 a_gastank
rename s12q0211 a_hotplate
rename s12q0212 a_oven
rename s12q0213 a_fireplace
rename s12q0214 a_foodprocessor
rename s12q0215 a_fruitpress
rename s12q0216 a_fridge
rename s12q0217 a_freezer
rename s12q0218 a_fan
rename s12q0219 a_radio
rename s12q0220 a_tv
rename s12q0221 a_dvd
rename s12q0222 a_satellite
rename s12q0223 a_washer
rename s12q0224 a_vacuum
rename s12q0225 a_ac
rename s12q0226 a_lawnmower
rename s12q0227 a_generator
rename s12q0228 a_car
rename s12q0229 a_moped
rename s12q0230 a_bike
rename s12q0231 a_camera
rename s12q0232 a_camcorder
rename s12q0233 a_hifisystem
rename s12q0234 a_homephone
rename s12q0235 a_cellphone
rename s12q0236 a_tablet
rename s12q0237 a_computer
rename s12q0238 a_printer
rename s12q0239 a_videocam
rename s12q0240 a_boat
rename s12q0241 a_shotgun
rename s12q0242 a_guitar
rename s12q0243 a_piano
rename s12q0244 a_building
rename s12q0245 a_land


**## Labels and rename number ---- 
label var s12q031 "Num. Living room"
label var s12q032 "Num. Dining table"
label var s12q033 "Num. Bed"
label var s12q034 "Num. Single mattress"
label var s12q035 "Num. Cupboards and other furniture"
label var s12q036 "Num. Carpet"
label var s12q037 "Num. Electric iron"
label var s12q038 "Num. Charcoal iron"
label var s12q039 "Num. Gas or electric stove"
label var s12q0310 "Num. Gas cylinder"
label var s12q0311 "Num. Gas or electric hotplate"
label var s12q0312 "Num. Microwave or electric oven"
label var s12q0313 "Num. Improved fireplaces"
label var s12q0314 "Num. Electric food processor (Moulinex)"
label var s12q0315 "Num. Non-electric mixer/fruit press"
label var s12q0316 "Num. Refrigerator"
label var s12q0317 "Num. Freezer"
label var s12q0318 "Num. Free-standing fan"
label var s12q0319 "Num. Radio/Radio cassette"
label var s12q0320 "Num. TV set"
label var s12q0321 "Num. VCR/CD/DVD"
label var s12q0322 "Num. Satellite dish/decoder"
label var s12q0323 "Num. Washing machine, tumble dryer"
label var s12q0324 "Num. Vacuum cleaner"
label var s12q0325 "Num. Air conditioners/splits (not wall-mounted)"
label var s12q0326 "Num. Lawnmowers and other gardening equipment"
label var s12q0327 "Num. Generator"
label var s12q0328 "Num. Personal car"
label var s12q0329 "Num. Moped/moped, motorcycle"
label var s12q0330 "Num. Bicycle, racing bike"
label var s12q0331 "Num. Camera"
label var s12q0332 "Num. Camcorder"
label var s12q0333 "Num. Hi Fi system"
label var s12q0334 "Num. Home phone"
label var s12q0335 "Num. Cell phone"
label var s12q0336 "Num. Tablet"
label var s12q0337 "Num. Computer"
label var s12q0338 "Num. Printer/Fax"
label var s12q0339 "Num. Video camera"
label var s12q0340 "Num. Pirogue and outboard (pleasure boats)"
label var s12q0341 "Num. Shotguns"
label var s12q0342 "Num. Guitar"
label var s12q0343 "Num. Piano and other musical equipment"
label var s12q0344 "Num. Building/House"
label var s12q0345 "Num. Undeveloped land"

rename s12q031 a_living_n
rename s12q032 a_dining_n
rename s12q033 a_bed_n
rename s12q034 a_singlemat_n
rename s12q035 a_cupboard_n
rename s12q036 a_carpet_n
rename s12q037 a_iron_n
rename s12q038 a_charcoaliron_n
rename s12q039 a_stove_n
rename s12q0310 a_gastank_n
rename s12q0311 a_hotplate_n
rename s12q0312 a_oven_n
rename s12q0313 a_fireplace_n
rename s12q0314 a_foodprocessor_n
rename s12q0315 a_fruitpress_n
rename s12q0316 a_fridge_n
rename s12q0317 a_freezer_n
rename s12q0318 a_fan_n
rename s12q0319 a_radio_n
rename s12q0320 a_tv_n
rename s12q0321 a_dvd_n
rename s12q0322 a_satellite_n
rename s12q0323 a_washer_n
rename s12q0324 a_vacuum_n
rename s12q0325 a_ac_n
rename s12q0326 a_lawnmower_n
rename s12q0327 a_generator_n
rename s12q0328 a_car_n
rename s12q0329 a_moped_n
rename s12q0330 a_bike_n
rename s12q0331 a_camera_n
rename s12q0332 a_camcorder_n
rename s12q0333 a_hifisystem_n
rename s12q0334 a_homephone_n
rename s12q0335 a_cellphone_n
rename s12q0336 a_tablet_n
rename s12q0337 a_computer_n
rename s12q0338 a_printer_n
rename s12q0339 a_videocam_n
rename s12q0340 a_boat_n
rename s12q0341 a_shotgun_n
rename s12q0342 a_guitar_n
rename s12q0343 a_piano_n
rename s12q0344 a_building_n
rename s12q0345 a_land_n

save "${swdTemp}/household_assets1.dta", replace

**********************************************************
**# Assets from section 19 for rural PMT -------------
**********************************************************

use "${swdDataraw}/Menage/s19_me_sen_2021.dta", clear

gen hhid=grappe*100+menage 
keep hhid grappe menage s19q00 s19q02 s19q03 s19q04 
keep if s19q00 == 1
recode s19q03 (2 = 0) (1 = 1)
label define s19q03 0 "No" 1 "Yes", replace

replace s19q04 = 0 if s19q03 == 0

**## Reshape so column is one asset --------------
reshape wide s19q03 s19q04, i(hhid) j(s19q02) favor(speed)

**## labels and names dummy --------------
label var s19q03101 "Tractor"
label var s19q03102 "Sprayer"
label var s19q03103 "Tiller"
label var s19q03104 "Multicultivator"
label var s19q03105 "Plough "
label var s19q03106 "Axe/pickaxe"
label var s19q03107 "Hoe/daba/hill"
label var s19q03108 "Machete"
label var s19q03110 "Asinine hoe"
label var s19q03111 "Seed drill"
label var s19q03112 "Harrow"
label var s19q03113 "Ploughing animals "
label var s19q03114 "Carts"
label var s19q03115 "Beehives"
label var s19q03117 "Rice husker"
label var s19q03118 "Corn sheller"
label var s19q03119 "Thresher"
label var s19q03121 "Motor pump unit"
label var s19q03122 "Hand pump"
label var s19q03123 "Scale"
label var s19q03124 "Bundling machine"
label var s19q03125 "Straw chopper"
label var s19q03126 "Drinker / Feeder"
label var s19q03128 "Mower"
label var s19q03129 "Mill"
label var s19q03130 "Fertilizer spreader"
label var s19q03131 "Milking machine"
label var s19q03132 "Incubator"
label var s19q03133 "Motorized canoe"
label var s19q03134 "Non-motorized canoe"
label var s19q03135 "Gill net"
label var s19q03136 "Seine"
label var s19q03137 "Sparrowhawk"
label var s19q03138 "Hook longline"
label var s19q03139 "Harpoon"
label var s19q03140 "Others"

rename s19q03101 ar_tractor
rename s19q03102 ar_sprayer
rename s19q03103 ar_tiller
rename s19q03104 ar_multicultiva
rename s19q03105 ar_plough 
rename s19q03106 ar_axe_pickaxe
rename s19q03107 ar_hoe_daba_hill
rename s19q03108 ar_machete
rename s19q03110 ar_asinine_hoe
rename s19q03111 ar_seed_drill
rename s19q03112 ar_harrow
rename s19q03113 ar_plou_anima
rename s19q03114 ar_carts
rename s19q03115 ar_beehives
rename s19q03117 ar_rice_husker
rename s19q03118 ar_corn_sheller
rename s19q03119 ar_thresher
rename s19q03121 ar_motor_pump
rename s19q03122 ar_hand_pump
rename s19q03123 ar_scale
rename s19q03124 ar_bund_mach
rename s19q03125 ar_straw_chop
rename s19q03126 ar_drinker_fee
rename s19q03128 ar_mower
rename s19q03129 ar_mill
rename s19q03130 ar_fertili_spre
rename s19q03131 ar_milk_machi
rename s19q03132 ar_incubator
rename s19q03133 ar_motor_canoe
rename s19q03134 ar_no_motor_can
rename s19q03135 ar_gill_net
rename s19q03136 ar_seine
rename s19q03137 ar_sparrowhawk
rename s19q03138 ar_hook_longli
rename s19q03139 ar_harpoon
rename s19q03140 ar_others

**## labels and names number --------------
label var s19q04101 "Num. Tractor"
label var s19q04102 "Num. Sprayer"
label var s19q04103 "Num. Tiller"
label var s19q04104 "Num. Multicultivator"
label var s19q04105 "Num. Plough "
label var s19q04106 "Num. Axe/pickaxe"
label var s19q04107 "Num. Hoe/daba/hill"
label var s19q04108 "Num. Machete"
label var s19q04110 "Num. Asinine hoe"
label var s19q04111 "Num. Seed drill"
label var s19q04112 "Num. Harrow"
label var s19q04113 "Num. Ploughing animals "
label var s19q04114 "Num. Carts"
label var s19q04115 "Num. Beehives"
label var s19q04117 "Num. Rice husker"
label var s19q04118 "Num. Corn sheller"
label var s19q04119 "Num. Thresher"
label var s19q04121 "Num. Motor pump unit"
label var s19q04122 "Num. Hand pump"
label var s19q04123 "Num. Scale"
label var s19q04124 "Num. Bundling machine"
label var s19q04125 "Num. Straw chopper"
label var s19q04126 "Num. Drinker/Feeder"
label var s19q04128 "Num. Mower"
label var s19q04129 "Num. Mill"
label var s19q04130 "Num. Fertilizer spreader"
label var s19q04131 "Num. Milking machine"
label var s19q04132 "Num. Incubator"
label var s19q04133 "Num. Motorized canoe"
label var s19q04134 "Num. Non-motorized canoe"
label var s19q04135 "Num. Gill net"
label var s19q04136 "Num. Seine"
label var s19q04137 "Num. Sparrowhawk"
label var s19q04138 "Num. Hook longline"
label var s19q04139 "Num. Harpoon"
label var s19q04140 "Num. Others"

rename s19q04101 ar_tractor_n
rename s19q04102 ar_sprayer_n
rename s19q04103 ar_tiller_n
rename s19q04104 ar_multicultiva_n
rename s19q04105 ar_plough_n
rename s19q04106 ar_axe_pickaxe_n
rename s19q04107 ar_hoe_daba_hill_n
rename s19q04108 ar_machete_n
rename s19q04110 ar_asinine_hoe_n
rename s19q04111 ar_seed_drill_n
rename s19q04112 ar_harrow_n
rename s19q04113 ar_plou_anima_n
rename s19q04114 ar_carts_n
rename s19q04115 ar_beehives_n
rename s19q04117 ar_rice_husker_n
rename s19q04118 ar_corn_sheller_n
rename s19q04119 ar_thresher_n
rename s19q04121 ar_motor_pump_n
rename s19q04122 ar_hand_pump_n
rename s19q04123 ar_scale_n
rename s19q04124 ar_bund_mach_n
rename s19q04125 ar_straw_chop_n
rename s19q04126 ar_drinker_fee_n
rename s19q04128 ar_mower_n
rename s19q04129 ar_mill_n
rename s19q04130 ar_fertili_spre_n
rename s19q04131 ar_milk_machi_n
rename s19q04132 ar_incubator_n
rename s19q04133 ar_motor_canoe_n
rename s19q04134 ar_no_motor_can_n
rename s19q04135 ar_gill_net_n
rename s19q04136 ar_seine_n
rename s19q04137 ar_sparrowhawk_n
rename s19q04138 ar_hook_longli_n
rename s19q04139 ar_harpoon_n
rename s19q04140 ar_others_n

save "${swdTemp}/household_assets_rural2.dta", replace

***********************************************************
**# Assets from section 11, not in dwelling characteristics
***********************************************************

use "${swdDataraw}/Menage/s11_me_sen_2021.dta", clear

gen hhid=grappe*100+menage 
	sort hhid 
	
	gen ad_aircond_b=s11q03__1==1
	gen ad_hotwater=s11q03__2==1
	gen ad_fan_b=s11q03__3==1
	
	local vars_assets "ad_aircond_b ad_hotwater ad_fan_b"
	collapse (sum) `vars_assets', by (hhid)
	
	lab var ad_aircond_b "has aircond_b (mod 11)"
	lab var ad_hotwater  "has hotwater (mod 11)"
	lab var ad_fan_b 	  "has fan_b (mod 11)"
	
	
save "${swdTemp}/household_assets3.dta", replace