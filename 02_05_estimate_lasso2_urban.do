/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 2, all cov as NUM
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal
keep if milieu == 1
**# Run lasso regresion, save results chosen lambda

lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 1 & sample == 1
estimates store urban2
cvplot
graph save "${swdResults}/graphs/cvplot_urban2", replace
lassocoef urban1 urban2
lassogof urban1 urban2, over(sample) postselection

*Show selected covariates
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/


						
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
estimates store urban2_ols


lassogof urban2 urban2_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda CV")
*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 2" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 2" "FALSE"
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda CV"

**## Lambda 0.04
capture drop yhat qhat qreal
estimates restore urban2
lassoselect lambda = 0.04
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates			
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
estimates store urban2_lam04_ols


lassogof urban2 urban2_ols urban2_lam04_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.04")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 1"

**## Lambda 0.06
capture drop yhat qhat qreal
estimates restore urban2
lassoselect lambda = 0.06
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates			
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
estimates store urban2_lam06_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.06")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 2"

**## Lambda 0.08
capture drop yhat qhat qreal
estimates restore urban2
lassoselect lambda = 0.08
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
				dis "amount of covariates is: " 
dis ncovariates			
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

estimates store urban2_lam08_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols urban2_lam08_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.08")
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 3"