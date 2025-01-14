/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates ols models with the same covariates of the orginal PMT
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	
*	Modified: 
*	Now the entire sample is limited 
*	Out of sample prediction MSE and R-squared and Maybe poverty accuracy or leakeage 50%

*------------------------------------------------------------------------------- */




**## Rural -----
keep if milieu == 2 

reg lpcexp i.region ${PMT_rural} [aweight = hhweight] if milieu == 2 & sample==1, r

predict yhat if milieu == 2, xb
local covariates = subinstr("`e(cmdline)'", "regress lpcexp", "", .)
local covariates = subinstr("`covariates'", "[aweight = hhweight] if milieu == 2 & sample==1, r", "", .)
scalar ncovariates = wordcount("`covariates'")
local covariates ""

reg lpcexp i.region ${PMT_rural} [aweight = hhweight] if milieu == 2, r

estimates store ols_rural
outreg2 using "${swdResults}/rural_coefficients.xls", replace ctitle("OLS") label

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)



**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Ols") ("2021") ("Rural") ("Fixed rate") (".") 

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
save "${swdResults}\accuracies.dta", replace
restore 

*save_measures "accuracy2015vs2021.xlsx" "Accuracy" "TRUE"
*save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "TRUE"
*save_lambdmeasu "accuracies_OLS.xlsx" "Rural"

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Ols") ("2021") ("Rural") ("Fixed line") (".") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy") ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy") ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy") ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy") ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)") ("`t'") `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)") ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}


	
postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 


**## Urban -----
use "${swdFinal}/data4model_2021.dta", clear

keep if milieu == 1

capture drop yhat qhat qreal
reg lpcexp i.region ${PMT_urban} [aweight = hhweight] if milieu == 1 & sample==1, r
predict yhat if milieu == 1, xb
local covariates = subinstr("`e(cmdline)'", "regress lpcexp", "", .)
local covariates = subinstr("`covariates'", "[aweight = hhweight] if milieu == 1 & sample==1, r", "", .)
scalar ncovariates = wordcount("`covariates'")

reg lpcexp i.region ${PMT_urban} [aweight = hhweight] if milieu == 1, r
estimates store ols_urban
outreg2 using "${swdResults}/urban_coefficients.xls", replace ctitle("Urban OLS") label

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)


**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Ols") ("2021") ("Urban") ("Fixed rate") (".") 

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

*save_measures "accuracy2015vs2021.xlsx" "Accuracy" "TRUE"
*save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "TRUE"
*save_lambdmeasu "accuracies_OLS.xlsx" "Rural"

**## estimate_accuracy fixed line ---
estimate_accuracy "line"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("Ols") ("2021") ("Urban") ("Fixed line") (".") 

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



