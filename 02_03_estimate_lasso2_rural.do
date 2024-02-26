/* ------------------------------------------------------------------------------			
*	This .do file estimates lasso rural model 2, vars as num
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD
*------------------------------------------------------------------------------- */

/* Rural model */
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
	[aw=hhweight] if milieu == 2, r //  & sample == 1 
local list ""
estimates store rural2_ols

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
[aw=hhweight] if milieu == 2, r // & sample == 1
local list ""

estimates store rural2_lam02_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.02") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 1"

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
	[aw=hhweight] if milieu == 2, r // & sample == 1

estimates store rural2_lam03_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.035") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 2"

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
		[aw=hhweight] if milieu == 2, r // & sample == 1
local list ""

estimates store rural2_lam05_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols rural2_lam05_ols if milieu == 2, over(sample) postselection

outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda 0.05") label
*estiaccu_measures
estiaccu_measures_ch
save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 3"