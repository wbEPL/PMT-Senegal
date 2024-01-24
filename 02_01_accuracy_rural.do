/* ------------------------------------------------------------------------------			
*			
*	This .do file is run inside 02_estimate_models.do to export the accuracy measures of rural
*	of the new PMT 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 23 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */



foreach t in 20 25 30 50 75 {
	* identify poor people in data and in model
	gen poor_real_`t' = qreal < `t' 
	gen poor_hat_`t' = qhat < `t'
	
	* total accuracy: Correctly predicted
	gen correct_`t' = (poor_real_`t' == poor_hat_`t')
	qui mean correct_`t'
	scalar mean_correct_`t' =  el(r(table),1,1)
	
	* Poverty accuracy: poor correct prediction among poor
	gen poverty_`t' = correct_`t' if poor_real_`t' == 1
	qui mean poverty_`t'
	scalar mean_poverty_`t' =  el(r(table),1,1)
	
	* Non-povery accuracy: non-poor correct prediction among non-poor
	gen non_poverty_`t' = correct_`t' if poor_real_`t' == 0
	qui mean non_poverty_`t'
	scalar mean_non_poverty_`t' =  el(r(table),1,1)
	
	* exclusion error, poor that identified as non-poor
	gen undercoverage_`t' = qreal<`t' if qhat>`t'
	qui mean undercoverage_`t'
	scalar mean_undercoverage_`t' =  el(r(table),1,1)
	
	* inclusion error, non-poor that identified as poor
	gen leakeage_`t' = qreal>`t' if qhat<`t'
	qui mean leakeage_`t'
	scalar mean_leakeage_`t' =  el(r(table),1,1)
	
}

putexcel set "${swdResults}/accuracy2015vs2021.xlsx", modify sheet("Accuracy")

*total accuracy
local col "T U V W X"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'4 = mean_correct_`t'*100, nformat("#.00")
	local ++i
}


*poverty accuracy
local col "T U V W X"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'5 = mean_poverty_`t'*100, nformat("#.00")
	local ++i
}

*non-poverty accuracy
local col "T U V W X"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'6 = mean_non_poverty_`t'*100, nformat("#.00")
	local ++i
}

*undercoverage
local col "T U V W X"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'7 = mean_undercoverage_`t'*100, nformat("#.00")
	local ++i
}

*leakeage
local col "T U V W X"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'8 = mean_leakeage_`t'*100, nformat("#.00")
	local ++i
}


putexcel save
