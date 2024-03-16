/* ------------------------------------------------------------------------------			
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

lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 1 & sample == 1, rseed(124578)
local id_opt=`e(ID_sel)'
estimates store urban2
cvplot
graph save "${swdResults}/graphs/cvplot_urban2", replace
lassocoef urban1 urban2
lassogof urban1 urban2 if milieu == 1, over(sample) postselection

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
	[aw=hhweight] if milieu == 1 , r // & sample == 1 because the overfitting problem is for model selection not coefficient estimation 
local list ""
estimates store urban2_ols

lassogof urban2 urban2_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda CV")

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed rate") ("Cross-validation selected lambda") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

	
postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed line") ("Cross-validation selected lambda") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

**# Lambda -10 steps
capture drop yhat qhat qreal
estimates restore urban2

local id_opt=e(ID_sel)-10
lassoselect id=`id_opt'
*lassoselect lambda = 0.04
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
	[aw=hhweight] if milieu == 1 , r
local list ""
estimates store urban2_lam04_ols


lassogof urban2 urban2_ols urban2_lam04_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda -10 steps")

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed rate") ("lambda -10 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

	
postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed line") ("lambda -10 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 


**# Lambda -20 steps
capture drop yhat qhat qreal
estimates restore urban2

local id_opt=`id_opt'-10
lassoselect id=`id_opt'
*lassoselect lambda = 0.06
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
	[aw=hhweight] if milieu == 1, r // // & sample == 1 because the overfitting problem is for model selection not coefficient estimation
local list ""
estimates store urban2_lam06_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda -20 steps")

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed rate") ("lambda -20 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

	
postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed line") ("lambda -20 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 



**# Lambda -30 steps
capture drop yhat qhat qreal
estimates restore urban2

local id_opt=`id_opt'-10
lassoselect id=`id_opt'
*lassoselect lambda = 0.08
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
	[aw=hhweight] if milieu == 1, r  // & sample == 1 because the overfitting problem is for model selection not coefficient estimation
local list ""

estimates store urban2_lam08_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols urban2_lam08_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda -30 steps")

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed rate") ("lambda -30 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

	
postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates)  ("Lasso") ("2") ("Urban") ("Fixed line") ("lambda -30 steps") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 

