/* ------------------------------------------------------------------------------			
*			
*	This .do file is run inside 02_estimate_models.do to export the accuracy measures of urban
*	of the new PMT 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 23 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */


putexcel set "${swdResults}/accuracy2015vs2021.xlsx", modify sheet("Accuracy Lasso 1")

*total accuracy
local col "H I J K L"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'4 = mean_correct_`t'*100, nformat("#.00")
	local ++i
}


*poverty accuracy
local col "H I J K L"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'5 = mean_poverty_`t'*100, nformat("#.00")
	local ++i
}

*non-poverty accuracy
local col "H I J K L"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'6 = mean_non_poverty_`t'*100, nformat("#.00")
	local ++i
}

*undercoverage
local col "H I J K L"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'7 = mean_undercoverage_`t'*100, nformat("#.00")
	local ++i
}

*leakeage
local col "H I J K L"
local i = 1
foreach t in 20 25 30 50 75{
	local l: word `i' of `col'
	putexcel `l'8 = mean_leakeage_`t'*100, nformat("#.00")
	local ++i
}


putexcel save
