/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates goodness of fit for both urban and rural models 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */


**# Goodness of fit rural
qui putexcel set "$swdResults/goodness_m.xlsx",  sheet("Rural", replace) modify


lassogof ols_rural /// ols 2021
		rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols /// model 1
		rural2_ols rural2_lam01_ols rural2_lam03_ols rural2_lam05_ols /// model 2
		rural3_ols rural1_swift rural2_swift rural1_swiftplus rural2_swiftplus if milieu == 2, over(sample)



matrix list r(table)
qui putexcel C2 = matrix(r(table))

qui putexcel A1 = "Model", bold
qui putexcel B1 = "Sample", bold
qui putexcel C1 = "MSE", bold
qui putexcel D1 = "R-squared", bold
qui putexcel E1 = "N-obs", bold

local row = 2
forvalues i = 1/14 {
    qui putexcel B`row' = "Training"
    local row = `row' + 1
    qui putexcel B`row' = "Testing"
    local row = `row' + 1
}

forvalues i = 2(2)28 {
	local j = `i' + 1
    qui putexcel (A`i':A`j'), merge hcenter vcenter
}

 putexcel A2 = "Ols as 2015"
 putexcel A4 = "Lasso 1, lambda CV"
 putexcel A6 = "Lasso 1, lambda 0.01"
 putexcel A8 = "Lasso 1, lambda 0.03"
 putexcel A10 = "Lasso 1, lambda 0.05"
 putexcel A12 = "Lasso 2, lambda CV"
 putexcel A14 = "Lasso 2, lambda 0.02"
 putexcel A16 = "Lasso 2, lambda 0.035"
 putexcel A18 = "Lasso 2, lambda 0.05"
 putexcel A20 = "Lasso 3, lambda CV"
 putexcel A22 = "SWIFT1 p = 0.05"
 putexcel A24 = "SWIFT2 p = 0.000001"
 putexcel A26 = "SWIFTPLUS1 p = 0.05"
 putexcel A28 = "SWIFTPLUS2 p = 0.000001"

putexcel save
pause



*-------------------------------------------
**# Goodness of fit urban
*-------------------------------------------

qui putexcel set "$swdResults/goodness_m.xlsx", modify sheet("Urban", replace)

lassogof ols_urban /// ols 2021
		urban1_ols urban1_lam01_ols urban1_lam03_ols urban1_lam05_ols /// model 1
		urban2_ols urban2_lam01_ols urban2_lam03_ols urban2_lam05_ols /// model 2
		urban3_ols urban1_swift urban2_swift urban1_swiftplus urban2_swiftplus if milieu == 1, over(sample)


matrix list r(table)
qui putexcel C2 = matrix(r(table))

qui putexcel A1 = "Model", bold
qui putexcel B1 = "Sample", bold
qui putexcel C1 = "MSE", bold
qui putexcel D1 = "R-squared", bold
qui putexcel E1 = "N-obs", bold

local row = 2
forvalues i = 1/14 {
    qui putexcel B`row' = "Training"
    local row = `row' + 1
    qui putexcel B`row' = "Testing"
    local row = `row' + 1
}

forvalues i = 2(2)28 {
	local j = `i' + 1
    qui putexcel (A`i':A`j'), merge hcenter vcenter
}

qui putexcel A2 = "Ols as 2015"
qui putexcel A4 = "Lasso 1, lambda CV"
qui putexcel A6 = "Lasso 1, lambda 0.025"
qui putexcel A8 = "Lasso 1, lambda 0.05"
qui putexcel A10 = "Lasso 1, lambda 0.08"
qui putexcel A12 = "Lasso 2, lambda CV"
qui putexcel A14 = "Lasso 2, lambda 0.04"
qui putexcel A16 = "Lasso 2, lambda 0.06"
qui putexcel A18 = "Lasso 2, lambda 0.08"
qui putexcel A20 = "Lasso 3, lambda CV"
qui putexcel A22 = "SWIFT1 p = 0.05"
qui putexcel A24 = "SWIFT2 p = 0.000001"
qui putexcel A26 = "SWIFTPLUS1 p = 0.05"
qui putexcel A28 = "SWIFTPLUS2 p = 0.000001"

putexcel save
