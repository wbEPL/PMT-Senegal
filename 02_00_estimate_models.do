/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates Senegal PMT. 
*	The input files are: 
*		- data4model_2021.dta
*	The following result files are created:
*		- TBD
*	Open points that need to be addressed:
* 		- is there a way to automate the inclusion of selected lasso vars  in ols?
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 15 Ma2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*Number of models: 
1. OLS with PMT covariates
2. LASSO 1: all covs, categories simplified  (Diff lambdas)
3. LASSO 2: all covs  categories not simplified  (Diff lambdas)
4. LASSO 3: PMT covs, not simplified  (optimal lambda)
5. SWIFT: all covs with different p-values
6. SWIFT-PLUS: all covs + consumption dummies with different p=values

*------------------------------------------------------------------------------- */

**# INIT 

**## create vars description excel accuracies export 

clear
input str30 cols str50 description str100 values
"Measure" "Accuracy measure" "Total accuracy, Poverty accuracy, Non-poverty accuracy, Undercoverage (exclusion error), Leakage (inclusion error)"
"Quantile" "Quantile used to estimate the measure" "20 25 30 50 75"
"Model" "Model on which the accuracy is based" "OLS, Lasso"
"Version" "Version of the model" "2021, 1,2,3"
"Place" "Location of source data" "Urban, Rural"
"Poverty_measure" "Is it fixed poverty line or fixed poverty rate" "Fixed line, Fixed rate"
"Number_of_vars" "Number of survey questions needed to estimate the model" "Positive integer values"
"Lambda" "Lambda used for lasso model" "NA, cross-validation lamdba, other decimal values"
"Sample" "Sample used to estimate accuracy measure" "Full, Testing"
"Value" "Estimated accuracy measures" "Values"
end

export excel "${swdResults}/accuracies.xlsx",  sheet("vars", replace) firstrow(variables)

**## Data 

/*

**# OLS same as 2015 covariates ---
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_01_estimate_ols.do" // This will replace the accuracies.dta file, so if you run this you need to re run the other models to save the accuracies
*/
/*==================================================
					LASSO models
====================================================*/

/*
**## Lasso 1 rural, assets and livestock as dummy, include all livestock separately 
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_02_estimate_lasso1_rural.do"

**## Lasso 2 rural, assets and livestock as number 
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_03_estimate_lasso2_rural.do"

**## Lasso 1 urban, assets as dummy 
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_04_estimate_lasso1_urban.do"

**## Lasso 2 urban, assets and livestock as number
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_05_estimate_lasso2_urban.do"

**## Lasso 3 urban and rural, start same covariates 2015, do not move lambdas 
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_06_estimate_lasso3.do"

*/

/*==================================================
					SWIFT models
====================================================*/

**# Rural
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_08_estimate_SWIFT_rural.do"

**# Urban
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_10_estimate_SWIFT_urban.do"

/*==================================================
					SWIFT-Plus
====================================================*/

**# Rural
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_09_estimate_SWIFTPLUS_rural.do"

**# Urban
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_11_estimate_SWIFTPLUS_urban.do"

/*==================================================
					Exporting Data
====================================================*/

**# Accuracies 
use "${swdResults}\accuracies.dta", replace
replace value=100*value
export excel "${swdResults}/accuracies.xlsx", sheet("Results", replace) firstrow(variables)


**# Goodness of fit 
use "${swdFinal}/data4model_2021.dta", clear
include "$scripts/02_07_goodness_fit.do"
