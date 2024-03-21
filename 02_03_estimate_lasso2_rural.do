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
lasso linear lpcexp  (i.region) $cov_set2 if milieu == 2 & sample == 1, rseed(124578)
estimates store rural2
*cvplot
*graph save "${swdResults}/graphs/*cvplot_rural2", replace
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
	[aw=hhweight] if milieu == 2 & sample==1, r //  & sample == 1 
predict yhat if milieu == 2, xb 

reg `list' ///
	[aw=hhweight] if milieu == 2, r //  & sample == 1 
estimates store rural2_ols
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda CV") label
local list ""


quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols if milieu == 2, over(sample) postselection

*estiaccu_measures
*estiaccu_measures_ch
*save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 2" "TRUE"
*save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 2" "TRUE"
*save_lambdmeasu "accuracies_rural2.xlsx" "Lambda CV"

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed rate") ("Cross-validation selected lambda") 

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

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed line") ("Cross-validation selected lambda") 

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

**# Lambda -10 steps --
capture drop yhat qhat qreal
estimates restore rural2
local id_opt=e(ID_sel)-10
lassoselect id=`id_opt' // a model 10 steps early than the previous one
*cvplot
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
[aw=hhweight] if milieu == 2 & sample==1, r // & sample == 1
predict yhat  if milieu == 2, xb 

reg `list' ///
[aw=hhweight] if milieu == 2, r // & sample == 1

estimates store rural2_lam02_ols
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda -10 steps") label
local list ""
	

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols if milieu == 2, over(sample) postselection

*estiaccu_measures
*estiaccu_measures_ch
*save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 1"

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed rate") ("lambda -10 steps") 

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

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed line") ("lambda -10 steps") 

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
estimates restore rural2
local id_opt=`id_opt'-10
lassoselect id=`id_opt' // a model 10 steps early than the previous one
*cvplot
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
	[aw=hhweight] if milieu == 2 & sample==1, r // & sample == 1
predict yhat  if milieu == 2, xb 

reg `list' ///
	[aw=hhweight] if milieu == 2, r // & sample == 1
estimates store rural2_lam03_ols
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda -20 steps") label
local list ""

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols if milieu == 2, over(sample) postselection

*estiaccu_measures
*estiaccu_measures_ch
*save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 2"

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed rate") ("lambda -20 steps") 

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

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed line") ("lambda -20 steps") 

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

**# Lambda -25 steps
capture drop yhat qhat qreal
estimates restore rural2
local id_opt=`id_opt'-5
lassoselect id=`id_opt' // a model 10 steps early than the previous one
*cvplot
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
		[aw=hhweight] if milieu == 2 & sample==1, r // & sample == 1
predict yhat  if milieu == 2, xb 


reg `list' ///
		[aw=hhweight] if milieu == 2, r // & sample == 1
estimates store rural2_lam05_ols
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("Lasso 2-lambda -25 steps") label
	

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural2 rural2_ols rural2_lam02_ols rural2_lam03_ols rural2_lam05_ols if milieu == 2, over(sample) postselection
local list ""

*estiaccu_measures
*estiaccu_measures_ch
*save_lambdmeasu "accuracies_rural2.xlsx" "Lambda 3"

**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed rate") ("lambda -25 steps") 

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

local common (ncovariates) ("Lasso") ("2") ("Rural") ("Fixed line") ("lambda -25 steps") 

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