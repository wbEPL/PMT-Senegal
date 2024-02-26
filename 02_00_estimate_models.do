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
*	Last edited: 16 February2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*Number of models: 
1. OLS with PMT covariates
2. LASSO 1: all covs, categories simplified  (Diff lambdas)
3. LASSO 2: all covs  categories not simplified  (Diff lambdas)
4. LASSO 3: PMT covs, not simplified  (optimal lambda)

*------------------------------------------------------------------------------- */

**# INIT ----------------------
use "${swdFinal}/data4model_2021.dta", clear

**## split sample

splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
label define sample 1 "Training" 2 "Testing"
label values sample sample

tempfile cleaned_dataset
save `cleaned_dataset', replace 

**# OLS same as 2015 covariates ---
include "$scripts/02_01_estimate_ols.do"



**## Lasso 1 rural, assets and livestock as dummy, include all livestock separately --------------
use `cleaned_dataset', replace

include "$scripts/02_02_estimate_lasso1_rural.do"

**## Lasso 2 rural, assets and livestock as number --------------
use `cleaned_dataset', replace
include "$scripts/02_03_estimate_lasso2_rural.do"



	
	use "${swdFinal}/data4model_2021.dta", clear // temporal for development pourposes  
	
	splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
	label define sample 1 "Training" 2 "Testing"
	label values sample sample

	tempfile cleaned_dataset
	save `cleaned_dataset', replace 



**## Lasso 1 urban, assets as dummy ------------------
use `cleaned_dataset', replace
include "$scripts/02_04_estimate_lasso1_urban.do"

**## Lasso 2 urban, assets and livestock as number --------------
use `cleaned_dataset', replace
include "$scripts/02_05_estimate_lasso2_urban.do"

**## Lasso 3 urban and rural, start same covariates 2015, do not move lambdas--------------
use `cleaned_dataset', replace
include "$scripts/02_06_estimate_lasso3.do"


**# Goodness of fit rural
use `cleaned_dataset', replace
include "$scripts/02_07_goodness_fit.do"

