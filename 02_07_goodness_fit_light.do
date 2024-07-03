/* ------------------------------------------------------------------------------			
*	This .do file estimates goodness of fit for both urban and rural models 
*	ONLY works inside 02_estimate_models.do
*	Last edited: 16 February 2024

*------------------------------------------------------------------------------- */


foreach zone in rural urban { 
	
	**# Defining sample to run the gof
	if "`zone'"=="rural" {
		local cond "milieu == 2"
	}
	else {
		local cond "milieu == 1"
	}
	
	**# Setting up the excel file 
	putexcel set "$swdResults/goodness_m_light.xlsx", sheet("`zone'", replace) modify
	
	**# Computing GOF
	lassogof ols_`zone' /// OLS of current PMT
			`zone'1_ols  `zone'1_lam05_ols  /// LASSO 1
			`zone'2_swift   ///  SWIFT 2 & SWIF-PLUS :`zone'2_swiftplus 
			 if `cond', over(sample) 


	matrix list r(table)
	qui putexcel C2 = matrix(r(table))
	
	qui putexcel A1 = "Model", bold
	qui putexcel B1 = "Sample", bold
	qui putexcel C1 = "MSE", bold
	qui putexcel D1 = "R-squared", bold
	qui putexcel E1 = "N-obs", bold
	
	local row = 2
	forvalues i = 1/4 {
		qui putexcel B`row' = "Training"
		local row = `row' + 1
		qui putexcel B`row' = "Testing"
		local row = `row' + 1
	}
	
	forvalues i = 2(2)8 {
		local j = `i' + 1
	    qui putexcel (A`i':A`j'), merge hcenter vcenter
	}
	
	
	putexcel A2 = 	"OLS original PMT"
	putexcel A4 = 	"Lasso 1, lambda CV"
	putexcel A6 = 	"Lasso 1, lambda - `step3_lasso'"
	putexcel A8 = 	"SWIFT1 p = 0.000001"
	
	putexcel save
	pause

}