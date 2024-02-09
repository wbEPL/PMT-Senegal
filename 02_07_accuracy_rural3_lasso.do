/* ------------------------------------------------------------------------------			
*			
*	This .do file is run inside 02_estimate_models.do to export the accuracy measures of rural lasso 2
*	of the new PMT 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 31 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

putexcel set "${swdResults}/accuracy2015vs2021.xlsx", modify sheet("Accuracy Lasso 3")

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
