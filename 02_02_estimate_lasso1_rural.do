/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso rural model 1, all cov as dum
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal

 
/* Rural model */


keep if milieu == 2
**# Run lasso regresion, save results chosen lambda
lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 2 & sample == 1, rseed(124578)
estimates store rural1
cvplot
graph save "${swdResults}/graphs/cvplot_rural1", replace
*show selected coefs
lassocoef rural1
*show model goodness of fit
lassogof rural1 if milieu == 2, over(sample) postselection

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
local list "" // being sure to clear the local list 

estimates store rural1_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

lassogof rural1 rural1_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 1-lambda CV") label
estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 1" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 1" "TRUE"
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda CV"

**## Lambda 0.01
capture drop yhat qhat qreal
estimates restore rural1
lassoselect lambda = 0.01
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)


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
	[aw=hhweight] if milieu == 2 & sample == 1, r
local list "" 	
estimates store rural1_lam01_ols

	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.01") label
estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.01"

**## Lambda 0.03
capture drop yhat qhat qreal
estimates restore rural1
lassoselect lambda = 0.03
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
estimates store rural1_lam03_ols

	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols rural1_lam03_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.03") label
estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.03"

**## Lambda 0.05
capture drop yhat qhat qreal
estimates restore rural1
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
estimates store rural1_lam05_ols

/* @gabriel, I have few different covariates here. We need to check here why with your code. 
reg lpcexp logsize yadr i.region a_living a_cupboard a_carpet a_charcoaliron ///
			a_gastank a_fridge a_freezer a_fan a_tv a_satellite a_car i.c_walls ///
			i.c_roof c_connectoelec i.c_lighting c_connectedtoint c_connectedtotv ///
			i.c_fuelfirst_r c_toilet ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r
*/
	 
	
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.05") label
estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.05"

esttab rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols