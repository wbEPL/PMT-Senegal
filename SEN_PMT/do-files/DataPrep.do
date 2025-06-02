****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Data Preparation											   *
* Danielle Aron - March 2025								   *
****************************************************************
clear all 


global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"


capture log close
log using "$log/SEN_PMT_DataPrep.log", replace 

****************************************************************
* code/recode RNU 2024 data 
****************************************************************
use "$rawdata/RNU_DATA_INDIVIDU_TRAITE.dta", clear

gen dem_heduc_1 = . 
replace dem_heduc_1 = 1 if i15==0 | i15==2
replace dem_heduc_1 = 0 if dem_heduc_1!=1 & i15!=.

gen dem_branch_1 =. 
replace dem_branch_1=1 if i18==1
replace dem_branch_1=0 if dem_branch_1!=1 & i18!=.

gen adult = 0
replace adult = 1 if i6>=15 & i6<=64
gen emp = . 
replace emp = 0 if i17==0 | i17==1
replace emp = 1 if i17!=0 & i17!=.
replace emp = . if adult==0
bysort ext_tracf: egen adult_emp_count = sum(emp)
bysort ext_tracf: egen adult_count = sum(adult)
gen dem_emp_rate = adult_emp_count / adult_count 

gen head = 0 
replace head = 1 if i1==1

drop if head!=1

gen dem_hage = ln(i6)

merge 1:1 ext_tracf using "$rawdata/RNU_DATA_MENAGE_TRAITE.dta"

clonevar hhsize = Taille_men
gen dem_logsize = ln(Taille_men)
gen hhweight = 1
gen popweight = hhweight*Taille_men

clonevar hhid = ext_tracf

clonevar milieu = ext_milieu
clonevar a_ac = pmt_m11c
clonevar a_car = pmt_m11i
clonevar a_carpet = pmt_m11m
clonevar a_iron = pmt_m11f
clonevar a_charcoaliron = pmt_m11g
clonevar a_computer = pmt_m11a
clonevar a_cupboard = pmt_m11j
clonevar a_fan = pmt_m11b
clonevar a_fridge = pmt_m11h
clonevar a_gastank = pmt_m11n
clonevar a_living = pmt_m11e
clonevar a_moped = pmt_m11o
clonevar a_tv = pmt_m11d
clonevar a_satellite = pmt_m13_3
clonevar a_stove = pmt_m11k
clonevar ar_tractor = m12d
	recode ar_tractor (2=0)
clonevar c_connectedtoint = pmt_m13_1
clonevar c_connectedtotv = pmt_m13_3
clonevar c_connectoelec_1 = pmt_bin_m13b_4
clonevar c_connectowater = pmt_m13_2
clonevar c_floor_1 = pmt_bin_m5_3
clonevar c_floor_2 = pmt_bin_m5_4
clonevar c_floor_3 = pmt_bin_m5_2
clonevar c_fuelfirst_3 = pmt_bin_m8_3
clonevar c_fuelfirst_5 = pmt_bin_m8_1
clonevar c_lighting_1 = pmt_bin_m7_6
clonevar c_numberofrooms_c = pmt_rec_m3
clonevar c_roof_1 = pmt_bin_m4_5
clonevar c_roof_2 = pmt_bin_m4_3
clonevar c_roof_3 = pmt_bin_m4_2
clonevar c_roof_4 = pmt_bin_m4_1
clonevar c_walls_1 = pmt_bin_m6_4 
clonevar c_walls_2 = pmt_bin_m6_3
clonevar c_walls_3 = pmt_bin_m6_2
clonevar c_typehousing_1 = pmt_bin_m1_2
clonevar c_typehousing_2 = pmt_bin_m1_3
clonevar c_typehousing_3 = pmt_bin_m1_1
clonevar c_typehousing_4 = pmt_bin_m1_4
clonevar dem_alfa_french = i16_1
clonevar region_1 = pmt_bin_region_1
clonevar region_2 = pmt_bin_region_2
clonevar region_3 = pmt_bin_region_3
clonevar region_4 = pmt_bin_region_4
clonevar region_5 = pmt_bin_region_5
clonevar region_6 = pmt_bin_region_6
clonevar region_7 = pmt_bin_region_7
clonevar region_8 = pmt_bin_region_8
clonevar region_9 = pmt_bin_region_9
clonevar region_10 = pmt_bin_region_10
clonevar region_11 = pmt_bin_region_11
clonevar region_12 = pmt_bin_region_12
clonevar region_13 = pmt_bin_region_13
clonevar region_14 = pmt_bin_region_14

gen c_housingocup_1 = m2==2
gen c_housingocup_3 = m2==3 

clonevar m16c_copy = m16c
recode m16c_copy (.=0)
gen l_sheep = 0
replace l_sheep = 1 if m16c_copy>=1

save "$data/RNU_2024_clean.dta", replace 

****************************************************************
* code/recode extra variables in data4model_2021
****************************************************************
use "$data/data4model_2021.dta", clear

gen ar_canoe=0
replace ar_canoe=1 if ar_motor_canoe==1 | ar_no_motor_can==1

recode dem_hactiv12m (2=0)
label define dem_hactiv12m_new 0 "Non occupe" 1 "Occupe/ TF"
label values dem_hactiv12m dem_hactiv12m_new

gen dem_hmale=0
replace dem_hmale=1 if dem_hgender==1

tab dem_heduc, gen(dem_heduc_)
tab dem_branch, gen(dem_branch_)
tab region, gen(region_)
tab c_typehousing, gen(c_typehousing_)
tab c_housingocup, gen(c_housingocup_)
tab c_roof, gen(c_roof_)
tab c_floor, gen(c_floor_)
tab c_walls, gen(c_walls_)
tab c_lighting, gen(c_lighting_)
tab c_fuelfirst, gen(c_fuelfirst_)
tab c_toilet, gen(c_toilet_)
tab c_connectoelec, gen(c_connectoelec_)

sum pcexp, d
return list

_pctile pcexp [aw=popweight] , p(40)
g b40value = r(r1)
g b40 = (pcexp <= b40value)

save "$data/data4model_2021_2.dta", replace

****************************************************************
cap log close
