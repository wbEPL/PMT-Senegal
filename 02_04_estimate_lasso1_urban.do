/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 1, all cov as dum
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal
keep if milieu == 1
**# Run lasso regresion, save results chosen lambda

lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 1 & sample == 1, rseed(124578)
estimates store urban1
cvplot
graph save "${swdResults}/graphs/cvplot_urban1", replace
lassocoef urban1
lassogof urban1, over(sample) postselection

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
	[aw=hhweight] if milieu == 1 & sample == 1, r
local list ""

estimates store urban1_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda CV")
*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 1" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 1" "FALSE"
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda CV"

**## Lambda 0.025
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.025
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
	[aw=hhweight] if milieu == 1 & sample == 1, r
local list ""

estimates store urban1_lam_025_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.025")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.025"

**## Lambda 0.05
capture drop yhat qhat qreal
estimates restore urban1
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
	[aw=hhweight] if milieu == 1 & sample == 1, r
local list ""
	
estimates store urban1_lam_05_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols urban1_lam_05_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.05")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.05"

**## Lambda 0.08
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.08
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
	[aw=hhweight] if milieu == 1 & sample == 1, r
local list ""	
estimates store urban1_lam_08_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols urban1_lam_05_ols urban1_lam_08_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.08")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.08"
