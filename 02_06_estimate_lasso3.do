/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 3, all cov as NUM
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

**## Lasso 3 rural, same covariates as OLS 2015 ------------------

preserve 
keep if milieu == 2
capture drop yhat qhat qreal

lasso linear lpcexp (i.region) ///
			logsize oadr yadr c_rooms_pc ///
			i.c_floor i.c_water_dry i.c_lighting i.c_walls i.c_toilet /// 
			a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge  ///
			l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n ///
			if milieu == 2 & sample == 1,  rseed(124578)

lassoselect id=26 // a model 5 steps early than the 
scalar ncovariates = wordcount(e(post_sel_vars))-1
			
estimates store rural3
cvplot
graph save "${swdResults}/graphs/cvplot_rural3", replace
lassocoef rural3
lassogof rural3, over(sample) postselection

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
	[aw=hhweight] if milieu == 2 , r 
local list ""
estimates store rural3_ols

predict yhat if milieu == 2, xb 
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 3") label


lassogof rural3 rural3_ols, over(sample) postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 3" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 3" "TRUE"
restore 
**## Lasso 3 urban, same covariates as OLS 2015 ------------------

preserve 
keep if milieu == 1
capture drop yhat qhat qreal

lasso linear lpcexp (i.region) ///
			logsize yadr alfa_french c_rooms_pc ///
			i.c_floor i.c_lighting i.c_toilet i.c_roof ///
			a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor a_iron ///
			l_donkeys_n l_horses_n l_pigs_n ///
			if milieu == 1 & sample == 1,  rseed(124578)

lassoselect id=18 // a model 5 steps early than the 
scalar ncovariates = wordcount(e(post_sel_vars))-1
						
estimates store urban3
cvplot
graph save "${swdResults}/graphs/cvplot_urban3", replace
lassocoef urban3
lassogof urban3, over(sample) postselection


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
	[aw=hhweight] if milieu == 1 , r
outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 3") label

local list ""
estimates store urban3_ols

predict yhat if milieu == 1, xb 
lassogof urban3 urban3_ols, over(sample) postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 3" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 3" "FALSE"

restore 