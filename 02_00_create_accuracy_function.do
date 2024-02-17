/* ------------------------------------------------------------------------------			
*			
*	This .do file defines functions estiaccu_measures and save_measures 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

**# FN to estimate accuracy measures for 20, 25, 30, 50 and 75 percentiles poverty line
* Arg: No arguments
* Input: quantiles called qhat and qreal to have been estimated. 
*       - qhat from a predicted income 
*		- qreal from actual income 
* Generates variables:
*		- poor_real_*: individual actually poor for * line
*		- poor_hat_*: individual predicted as poor for * line
*		- correct_*: correctly predicted individual for * line
*		- undercovered_*: undercovered individual for * line
*		- leaked_*: leaked individual for * line
* Generates scalars:
*		- mean_lpcexp: mean income
*		- mean_correct_*: percentage of correctly identified individuals (total accuracy) for * line
*		- mean_poverty_*: percentage of correctly identified poor individuals (poverty accuracy) for * line
*		- mean_non_poverty_*: percentage of correctly identified non-poor individuals (non-poverty accuracy) for * line
*		- mean_undercovered_*: percentage of undercovered individuals (exclusion error) for * line
*		- mean_leaked_*: percentage of leaked individuals (inclusion error) for * line


capture program drop estiaccu_measures
program define estiaccu_measures
	 
	foreach t in 20 25 30 50 75 {
		capture drop poor_real_`t' poor_hat_`t' correct_`t' undercovered_`t' leaked_`t'

		* identify poor people in data and in model
		gen poor_real_`t' = qreal < `t' 
		
		qui mean lpcexp [aw=hhweight*hhsize] if qreal == `t' 
		scalar mean_lpcexp =  el(r(table),1,1)
		gen poor_hat_`t' = yhat < mean_lpcexp /*TODO: Think if this is the best way? This is where we estimate poors*/
		
		* identify accurate individual
		gen correct_`t' = poor_real_`t' == poor_hat_`t'
		
		* identify undercovered individual
		gen undercovered_`t' = 0
		replace undercovered_`t' = 1 if poor_real_`t' == 1 & poor_hat_`t' == 0
		
		* identify leaked individual
		gen leaked_`t' = 0
		replace leaked_`t' = 1 if poor_real_`t' == 0 & poor_hat_`t' == 1
		
		* total accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] 
		scalar mean_correct_`t' =  el(r(table),1,1)
		
		* Poverty accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] if poor_real_`t' == 1
		scalar mean_poverty_`t' =  el(r(table),1,1)

		* Non-poverty accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] if poor_real_`t' == 0
		scalar mean_non_poverty_`t' =  el(r(table),1,1)
		
		* exclusion error
		qui mean undercovered_`t' [aw=hhweight*hhsize] if poor_real_`t' == 1 
		scalar mean_undercoverage_`t' =  el(r(table),1,1)

		* inclusion error
		qui mean leaked_`t' [aw=hhweight*hhsize]  if  poor_hat_`t' == 1
		scalar mean_leakeage_`t' =  el(r(table),1,1)
		
		* measures on testing data -----
		* total accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] if sample == 2
		scalar mean_correct_`t'_te =  el(r(table),1,1)
		
		* Poverty accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] if poor_real_`t' == 1 & sample == 2
		scalar mean_poverty_`t'_te =  el(r(table),1,1)

		* Non-poverty accuracy
		qui mean correct_`t' [aw=hhweight*hhsize] if poor_real_`t' == 0 & sample == 2
		scalar mean_non_poverty_`t'_te =  el(r(table),1,1)
		
		* exclusion error
		qui mean undercovered_`t' [aw=hhweight*hhsize] if poor_real_`t' == 1 & sample == 2
		scalar mean_undercoverage_`t'_te =  el(r(table),1,1)

		* inclusion error
		qui mean leaked_`t' [aw=hhweight*hhsize]  if  poor_hat_`t' == 1 & sample == 2
		scalar mean_leakeage_`t'_te =  el(r(table),1,1)
	}
	
	

end
	
**# FN to save accuracy measures to excel
* Args: 
*		- file_name: text of file name including .xlsx, it will always export them on folder of swdResults
*		- sheet_name: sheet name on where to save the data
*		- rural: "TRUE" will export results to columns T U V W X, 
*			false will export them to H I J K L
* Input scalars:
*		- mean_correct_*: percentage of correctly identified individuals (total accuracy) for * line
*		- mean_poverty_*: percentage of correctly identified poor individuals (poverty accuracy) for * line
*		- mean_non_poverty_*: percentage of correctly identified non-poor individuals (non-poverty accuracy) for * line
*		- mean_undercovered_*: percentage of undercovered individuals (exclusion error) for * line
*		- mean_leaked_*: percentage of leaked individuals (inclusion error) for * line
*		- ncovariates: number of selected covariates by lasso
	
capture program drop save_measures
program define save_measures
	args file_name sheet_name rural

	
	if "`rural'" == "TRUE" {
		local col "T U V W X"
	}
	else {
		local col "H I J K L"
	}
	
	local file_path "${swdResults}/`file_name'"
	qui putexcel set "`file_path'", modify sheet("`sheet_name'")
	dis "file saved on `file_path'"
	
	*total accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'4 = mean_correct_`t'*100, nformat("#.00")
		local ++i
	}

	*poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'5 = mean_poverty_`t'*100, nformat("#.00")
		local ++i
	}

	*non-poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'6 = mean_non_poverty_`t'*100, nformat("#.00")
		local ++i
	}

	*undercoverage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'7 = mean_undercoverage_`t'*100, nformat("#.00")
		local ++i
	}

	*leakeage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui mean_leakeage_`t'
		qui putexcel `l'8 = mean_leakeage_`t'*100, nformat("#.00")
		local ++i
	}

	qui putexcel save
end


**# FN to save accuracy measures on testing data to excel
* Args: 
*		- file_name: text of file name including .xlsx, it will always export them on folder of swdResults
*		- sheet_name: sheet name on where to save the data
*		- rural: "TRUE" will export results to columns T U V W X, 
*			false will export them to H I J K L
* Input scalars:
*		- mean_correct_*: percentage of correctly identified individuals (total accuracy) for * line
*		- mean_poverty_*: percentage of correctly identified poor individuals (poverty accuracy) for * line
*		- mean_non_poverty_*: percentage of correctly identified non-poor individuals (non-poverty accuracy) for * line
*		- mean_undercovered_*: percentage of undercovered individuals (exclusion error) for * line
*		- mean_leaked_*: percentage of leaked individuals (inclusion error) for * line
*		- ncovariates: number of selected covariates by lasso
	
capture program drop save_measures_test
program define save_measures_test
	args file_name sheet_name rural

	
	if "`rural'" == "TRUE" {
		local col "T U V W X"
	}
	else {
		local col "H I J K L"
	}
	
	local file_path "${swdResults}/`file_name'"
	qui putexcel set "`file_path'", modify sheet("`sheet_name'")
	dis "file saved on `file_path'"
	
	*total accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'4 = mean_correct_`t'_te*100, nformat("#.00")
		local ++i
	}

	*poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'5 = mean_poverty_`t'_te*100, nformat("#.00")
		local ++i
	}

	*non-poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'6 = mean_non_poverty_`t'_te*100, nformat("#.00")
		local ++i
	}

	*undercoverage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'7 = mean_undercoverage_`t'_te*100, nformat("#.00")
		local ++i
	}

	*leakeage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui mean_leakeage_`t'
		qui putexcel `l'8 = mean_leakeage_`t'_te*100, nformat("#.00")
		local ++i
	}

	qui putexcel save
end


**# FN to save accuracy measures to excel
* Args: 
*		- file_name: text of file name including .xlsx, it will always export them on folder of swdResults
*		- sheet_name: sheet name on where to save the data
* Input scalars:
*		- mean_correct_*_te: percentage of correctly identified individuals (total accuracy) for * line for testing sample
*		- mean_poverty_*_te: percentage of correctly identified poor individuals (poverty accuracy) for * line for testing sample
*		- mean_non_poverty_*_te: percentage of correctly identified non-poor individuals (non-poverty accuracy) for * line for testing sample
*		- mean_undercovered_*_te: percentage of undercovered individuals (exclusion error) for * line for testing sample
*		- mean_leaked_*_te: percentage of leaked individuals (inclusion error) for * line for testing sample
*		- ncovariates: number of selected covariates by lasso
	
capture program drop save_lambdmeasu
program define save_lambdmeasu
	args file_name sheet_name 

	
	local col "B C D E F"
	
	local file_path "${swdResults}/`file_name'"
	qui putexcel set "`file_path'", modify sheet("`sheet_name'")
	dis "file saved on `file_path'"
	*label rows
	qui putexcel A2 = "Total Accuracy", bold italic
	qui putexcel A3 = "Poverty Accuracy", bold italic
	qui putexcel A4 = "Non-poverty Accuracy", bold italic
	qui putexcel A5 = "Undercoverage", bold italic
	qui putexcel A6 = "Leakeage", bold italic
	qui putexcel A7 = "Num. covariates", bold italic
	
	*label cols
	qui putexcel A1 = "Measure", bold
	qui putexcel B1 = "20", bold
	qui putexcel C1 = "25", bold
	qui putexcel D1 = "30", bold
	qui putexcel E1 = "50", bold
	qui putexcel F1 = "75", bold
	
	*Num covariates
	qui putexcel B7 = ncovariates

	*total accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'2 = mean_correct_`t'_te*100, nformat("#.00")
		local ++i
	}

	*poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'3 = mean_poverty_`t'_te*100, nformat("#.00")
		local ++i
	}

	*non-poverty accuracy
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'4 = mean_non_poverty_`t'_te*100, nformat("#.00")
		local ++i
	}

	*undercoverage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'5 = mean_undercoverage_`t'_te*100, nformat("#.00")
		local ++i
	}

	*leakeage
	local i = 1
	foreach t in 20 25 30 50 75{
		local l: word `i' of `col'
		qui putexcel `l'6 = mean_leakeage_`t'_te*100, nformat("#.00")
		local ++i
	}
	
	qui putexcel set "`file_path'", modify sheet("Summary 25")
	
	*label rows
	qui putexcel A2 = "Total Accuracy", bold italic
	qui putexcel A3 = "Poverty Accuracy", bold italic
	qui putexcel A4 = "Non-poverty Accuracy", bold italic
	qui putexcel A5 = "Undercoverage", bold italic
	qui putexcel A6 = "Leakeage", bold italic
	qui putexcel A7 = "Num. covariates", bold italic
	
	qui putexcel save
end