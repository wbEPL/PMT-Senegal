/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso rural model 2, vars as num
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */



capture drop yhat qhat qreal
keep if milieu == 2
**# Run lasso regresion, save results chosen lambda

lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 2 & sample == 1, rseed(124578)
estimates store rural2
cvplot
graph save "${swdResults}/graphs/cvplot_rural2", replace
lassocoef rural1 rural2
lassogof rural1 rural2 if milieu == 2, over(sample) postselection


*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/
scalar ncovariates = wordcount(e(post_sel_vars))-1

* run ols with selected covariates and pop weights
* writing categorical variables
local list "`e(post_sel_vars)'"
dis "`list'"

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list = subinstr("`list'", "`c'", "i.`c'", 1)
}

local test_y =substr("`list'", 1, 6) // eliminating the 
assert  "`test_y'" == "lpcexp"



reg `list' ///
	[aw=hhweight] if milieu == 2 & sample == 1, r // I see the logic for indicators being a weighted average by population but much less standard the regression *hhsize
local list ""
/* @gabriel a_cupboard_n was missing here, was a typo or something more structural. Notice I tried using the same weights, may be the fact I am loading again the same dataset? we need to try with your codes in you local computer  
reg lpcexp logsize yadr alfa_french i.region a_dining_n a_bed_n a_carpet_n ///
			a_iron_n a_charcoaliron_n a_gastank_n a_foodprocessor_n a_fridge_n ///
			a_freezer_n a_fan_n a_radio_n a_tv_n a_satellite_n a_generator_n ///
			a_car_n a_moped_n a_bike_n a_cellphone_n a_tablet_n ar_sprayer_n ///
			ar_tiller_n ar_axe_pickaxe_n ar_machete_n ar_beehives_n ar_scale_n ///
			ar_straw_chop_n ar_drinker_fee_n ar_mower_n ar_mill_n i.c_typehousing ///
			c_numberofrooms_c i.c_housingocup c_businessindwe i.c_walls i.c_roof ///
			i.c_floor c_connectowater i.c_water_rainy c_connectoelec i.c_lighting ///
			c_landline c_connectedtoint c_connectedtotv i.c_fuelfirst_r i.c_garbage ///
			i.c_toilet l_sheep_n l_goats_n l_chickens_n l_guinea_fowl_n ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r
*/
estimates store rural2_ols
local list "" // being sure to clear the local list 

predict yhat if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda CV") label
*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 2" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 2" "TRUE"
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda CV"


**## Lambda 0.02
capture drop yhat qhat qreal
estimates restore rural2
lassoselect lambda = 0.02
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)


* writing categorical variables
local list "`e(post_sel_vars)'"
dis "`list'"

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list = subinstr("`list'", "`c'", "i.`c'", 1)
}

local test_y =substr("`list'", 1, 6) // eliminating the 
assert  "`test_y'" == "lpcexp"


reg `list' ///
[aw=hhweight] if milieu == 2 & sample == 1, r
local list ""

estimates store rural2_lam02_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.02") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 0.02"

**## Lambda 0.035
capture drop yhat qhat qreal
estimates restore rural2
lassoselect lambda = 0.035
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)


* writing categorical variables
local list "`e(post_sel_vars)'"
dis "`list'"

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list = subinstr("`list'", "`c'", "i.`c'", 1)
}

local test_y =substr("`list'", 1, 6) // eliminating the 
assert  "`test_y'" == "lpcexp"


reg `list' ///
	[aw=hhweight] if milieu == 2 & sample == 1, r

estimates store rural2_lam03_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.035") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 0.035"

**## Lambda 0.05
capture drop yhat qhat qreal
estimates restore rural2
lassoselect lambda = 0.05
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

* writing categorical variables
local list "`e(post_sel_vars)'"
dis "`list'"

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list = subinstr("`list'", "`c'", "i.`c'", 1)
}

local test_y =substr("`list'", 1, 6) // eliminating the 
assert  "`test_y'" == "lpcexp"


reg `list' ///
		[aw=hhweight] if milieu == 2 & sample == 1, r
local list ""

estimates store rural2_lam05_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols rural2_lam05_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.05") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 0.05"