/* Rural model */
**p = 0.05
capture drop yhat qhat qreal
keep if milieu == 1

local list "$cov_set1"
dis "`list'"

foreach l in `list' {
	su `l'  [w = hhweight] /*if  append==0 */
	if (r(max)==1 & (r(mean)<0.05 | r(mean)>0.95)) local drop `drop' `l'
	if r(mean)==0 local drop `drop' `l'
	}

local list: list list - local drop

gl cov_set1_mod2 "`list'" 
dis "$cov_set1_mod2"
/*----------------------------**----------------------------
SWIFT urban model using P-values = 0.05
**----------------------------**----------------------------*/

if "`light_version'"=="no" {


	* Stepwise 
	local pe = `SWIFT_l1'
	local pr = `pe' + .0000001	
	
	stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1_mod2 [pw=popweight] if sample == 1 
	matrix X=e(b)
	matrix X = X[1,1..`e(df_m)']
	global xvar2: colnames X
	local list2 $xvar2
	dis "`list2'"
	
	scalar ncovariates = wordcount("`list2'")-1
	
	foreach c in $categorical_v { // categorical_v is variables that are categorical 
		local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
	}
	
	
	reg lpcexp `list3' [aw=hhweight] if milieu == 1  & sample == 1, r 
	
	predict yhat if milieu == 1, xb 
	
	reg lpcexp `list3' [aw=hhweight] if milieu == 1, r 
	estimates store urban1_swift
	outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("SWIFT1") label
		
	quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)
	
	quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
	
	
	**## estimate_accuracy fixed rate ---
	estimate_accuracy "rate"
	
	**### save accuracies ----
	tempfile tf_postfile1 
	tempname tn1
	postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace
	
	local common (ncovariates) ("SWIFT") ("1") ("Urban") ("Fixed rate") ("P=`SWIFT_l1'") 
	
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
	postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure lambda sample) double value using `tf_postfile1', replace
	
	local common (ncovariates) ("SWIFT") ("1") ("Urban") ("Fixed line") ("P=`SWIFT_l1'") 
	
	foreach t in 20 25 30 50 75 {
		post `tn1' ("Total accuracy")  ("`t'") `common' ("Full")  (mean_correct_`t')
		post `tn1' ("Poverty accuracy")  ("`t'") `common' ("Full")  (mean_poverty_`t')
		post `tn1' ("Non-poverty accuracy")  ("`t'") `common' ("Full")  (mean_non_poverty_`t')
		post `tn1' ("Exclusion error (undercoverage)")  ("`t'") `common' ("Full")  (mean_undercoverage_`t')
		post `tn1' ("Inclusion error (leakeage)")  ("`t'") `common' ("Full")  (mean_leakeage_`t')
		post `tn1' ("Total accuracy")  ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
		post `tn1' ("Poverty accuracy")  ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
		post `tn1' ("Non-poverty accuracy")  ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
		post `tn1' ("Exclusion error (undercoverage)")  ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
		post `tn1' ("Inclusion error (leakeage)")  ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
	}
	
	postclose `tn1' 
	preserve
	use `tf_postfile1', clear
	append using "${swdResults}\accuracies.dta"
	duplicates report
	save "${swdResults}\accuracies.dta", replace
	restore 
	
}

/*----------------------------**----------------------------
SWIFT urban model using P-values = 0.000001
**----------------------------**----------------------------*/

		
**p = 0.000001
capture drop yhat qhat qreal
keep if milieu == 1

* Stepwise 
local pe = `SWIFT_l2' 
local pr = `pe' + .0000001	

stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1_mod2 [pw=popweight] if sample == 1 
matrix X=e(b)
matrix X = X[1,1..`e(df_m)']
global xvar2: colnames X
local list2 $xvar2
dis "`list2'"

scalar ncovariates = wordcount("`list2'")-1

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
}


reg lpcexp `list3' [aw=hhweight] if milieu == 1  & sample == 1, r 

predict yhat if milieu == 1, xb //

reg lpcexp `list3' [aw=hhweight] if milieu == 1, r 
estimates store urban2_swift
outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("SWIFT2") label
	
quantiles yhat [aw=hhweight*hhsize] if milieu == 1, gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)


**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("SWIFT") ("2") ("Urban") ("Fixed rate") ("P=`SWIFT_l2'") 

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
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure lambda sample) double value using `tf_postfile1', replace

local common (ncovariates) ("SWIFT") ("2") ("Urban") ("Fixed line") ("P=`SWIFT_l2'") 

foreach t in 20 25 30 50 75 {
	post `tn1' ("Total accuracy")  ("`t'") `common' ("Full")  (mean_correct_`t')
	post `tn1' ("Poverty accuracy")  ("`t'") `common' ("Full")  (mean_poverty_`t')
	post `tn1' ("Non-poverty accuracy")  ("`t'") `common' ("Full")  (mean_non_poverty_`t')
	post `tn1' ("Exclusion error (undercoverage)")  ("`t'") `common' ("Full")  (mean_undercoverage_`t')
	post `tn1' ("Inclusion error (leakeage)")  ("`t'") `common' ("Full")  (mean_leakeage_`t')
	post `tn1' ("Total accuracy")  ("`t'") `common' ("Testing")  (mean_correct_`t'_te)
	post `tn1' ("Poverty accuracy")  ("`t'") `common' ("Testing")  (mean_poverty_`t'_te)
	post `tn1' ("Non-poverty accuracy")  ("`t'") `common' ("Testing")  (mean_non_poverty_`t'_te)
	post `tn1' ("Exclusion error (undercoverage)")  ("`t'")  `common' ("Testing")  (mean_undercoverage_`t'_te)
	post `tn1' ("Inclusion error (leakeage)")  ("`t'") `common' ("Testing")  (mean_leakeage_`t'_te)
}

postclose `tn1' 
preserve
use `tf_postfile1', clear
append using "${swdResults}\accuracies.dta"
duplicates report
save "${swdResults}\accuracies.dta", replace
restore 
