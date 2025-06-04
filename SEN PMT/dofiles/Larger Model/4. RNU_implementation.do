****************************************************************
* Senegal PMT Stepwise					 				 	   *
* RNU implementation - larger model							   *
* Danielle Aron - March 2025								   *
****************************************************************
clear all 

global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"

capture log close
log using "$log/SEN_PMT_RNU_implementation_largermodel.log", replace 

global weight popweight
global lnwelfare lpcexp 

****************************************************************
* Load and append data
****************************************************************
use "$data/data4model_2021_2.dta", clear

* Append registry data (target data)
append using "$data/RNU_2024_clean.dta", gen(append) force
gen survey = 0 
replace survey = 1 if append==1 
label define survey 0 "HBS 2021" 1 "RNU 2024"
label value survey survey
drop append

****************************************************************
* Impute household expenditure in registry data
****************************************************************
preserve

** Urban *****
keep if milieu==1 // (milieu: 1=urban, 2=rural)

global xvar	c_connectowater c_typehousing_2 c_connectedtoint dem_alfa_french c_walls_2 a_gastank a_computer c_lighting_1 c_numberofrooms_c a_cupboard region_1 a_carpet c_housingocup_3 c_floor_2 a_fan region_6 a_satellite region_8 a_fridge c_connectedtotv region_11 region_12 c_roof_1 dem_logsize dem_emp_rate

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

fsum $xvar [aw=$weight] if survey==1 
tempfile urban_RNU_pred
save `urban_RNU_pred', replace emptyok

restore

** Rural *****
keep if milieu==2 // (milieu: 1=urban, 2=rural)

global xvar dem_hage a_fridge c_fuelfirst_3 dem_alfa_french a_moped a_fan region_2 region_3 a_tv c_lighting_1 region_6 region_7 l_sheep c_floor_2 c_walls_2 region_11 a_carpet region_13 dem_logsize c_floor_1 a_cupboard c_numberofrooms_c c_roof_1 a_charcoaliron a_gastank

reg $lnwelfare $xvar [pw=$weight]
predict lpcexp_pred
gen pcexp_pred=exp(lpcexp_pred)

fsum $xvar [aw=$weight] if survey==1  
append using `urban_RNU_pred'


****************************************************************
* Create cutoffs
****************************************************************
local list "15 18 20 30 37 40" //this local list used here and in next section

foreach t of numlist `list' {
	_pctile lpcexp_pred [aw=$weight] if survey==0, p(`t')
	g targetpop_`t'=r(r1)
}

* Add cutoff values into registry data 
foreach t of numlist `list' {
	egen cutoff_`t' = max(targetpop_`t')
}

****************************************************************
* Calculate coverage in registry data 
****************************************************************
foreach t of numlist `list' {
	g pmt_include_`t' = lpcexp_pred <= cutoff_`t'
}

display "included population portion in HBS"
fsum pmt_include_* [aw=$weight] if survey==0 // HBS, to check that cutoffs are set correctly 

display "included population portion in RNU"
fsum pmt_include_* [aw=$weight] if survey==1 // RNU All

display "included population portion in RNU, Urban population"
fsum pmt_include_* [aw=$weight] if survey==1 & milieu==1 // RNU Urban

display "included population portion in RNU, Rural population"
fsum pmt_include_* [aw=$weight] if survey==1 & milieu==2 // RNU Rural

su cutoff_20
global cutoff=r(mean)
twoway kdensity lpcexp_pred if survey==0 [aw=$weight] || kdensity lpcexp_pred if survey==1 [aw=$weight], legend(on order(1 "HBS" 2 "RNU")) title("Distribution of predicted log expenditure (PMT scores)") saving("$results\SEN_RNU_pred_distribution_LM", replace) xline($cutoff)

capture log close

