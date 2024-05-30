/* Rural model */
**p = 0.05
capture drop yhat qhat qreal
keep if milieu == 2

svyset [pw=popweight], strata(region) //@Kazusa I changed the survey strata to regions. Technically is the combination of region-milieu but here we kept milieu==2 
set seed 0123456

* Stepwise 
local pe = 0.05
local pr = `pe' + .0000001	

stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
matrix X=e(b)
matrix X = X[1,1..`e(df_m)']
global xvar2: colnames X
local list2 $xvar2
dis "`list2'"

scalar ncovariates = wordcount("`list2'")-1

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
}


reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 

predict yhat3 if milieu == 2, xb 

reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
estimates store rural1_swift
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT1") label
	
quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)


**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("SWIFT") ("1") ("Rural") ("Fixed rate") ("P=0.05") 

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

local common (ncovariates) ("SWIFT") ("1") ("Rural") ("Fixed line") ("P=0.05") 

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

/*
		**p = 0.01
		capture drop yhat qhat qreal
		estimates restore rural1_swift
		keep if milieu == 2
		splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
		label define sample 1 "Training" 2 "Testing"
		label values sample sample
		
		gen popweight = hhsize*hhweight
		gen pauvre = (pcexp <= zref)
		svyset [pw=popweight], strata(region)
		set seed 0123456
		
		* Stepwise 
		local pe = 0.01
		local pr = `pe' + .0000001	
		
		stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
		matrix X=e(b)
		matrix X = X[1,1..`e(df_m)']
		global xvar2: colnames X
		local list2 $xvar2
		dis "`list2'"
		
		scalar ncovariates = wordcount("`list2'")-1
		
		foreach c in $categorical_v { // categorical_v is variables that are categorical 
			local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
		}
		
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 
		
		predict yhat3 if milieu == 2, xb 
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
		estimates store rural1_swift
		outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT2") label
			
		quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
		
		quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
		
		
		**## estimate_accuracy fixed rate ---
		estimate_accuracy "rate"
		
		**### save accuracies ----
		tempfile tf_postfile1 
		tempname tn1
		postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace
		
		local common (ncovariates) ("SWIFT") ("2") ("Rural") ("Fixed rate") ("P=0.01") 
		
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
		
		local common (ncovariates) ("SWIFT") ("2") ("Rural") ("Fixed line") ("P=0.01") 
		
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

		**p = 0.001
		capture drop yhat qhat qreal
		estimates restore rural1_swift
		keep if milieu == 2
		splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
		label define sample 1 "Training" 2 "Testing"
		label values sample sample
		
		gen popweight = hhsize*hhweight
		gen pauvre = (pcexp <= zref)
		svyset [pw=popweight], strata(region)
		set seed 0123456
		
		* Stepwise 
		local pe = 0.001
		local pr = `pe' + .0000001	
		
		stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
		matrix X=e(b)
		matrix X = X[1,1..`e(df_m)']
		global xvar2: colnames X
		local list2 $xvar2
		dis "`list2'"
		
		scalar ncovariates = wordcount("`list2'")-1
		
		foreach c in $categorical_v { // categorical_v is variables that are categorical 
			local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
		}
		
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 
		
		predict yhat3 if milieu == 2, xb 
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
		estimates store rural1_swift
		outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT3") label
			
		quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
		
		quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
		
		
		**## estimate_accuracy fixed rate ---
		estimate_accuracy "rate"
		
		**### save accuracies ----
		tempfile tf_postfile1 
		tempname tn1
		postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace
		
		local common (ncovariates) ("SWIFT") ("3") ("Rural") ("Fixed rate") ("P=0.001") 
		
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
		
		local common (ncovariates) ("SWIFT") ("3") ("Rural") ("Fixed line") ("P=0.001") 
		
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
		
		**p = 0.0001
		capture drop yhat qhat qreal
		estimates restore rural1_swift
		keep if milieu == 2
		splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
		label define sample 1 "Training" 2 "Testing"
		label values sample sample
		
		gen popweight = hhsize*hhweight
		gen pauvre = (pcexp <= zref)
		svyset [pw=popweight], strata(region)
		set seed 0123456
		
		* Stepwise 
		local pe = 0.0001
		local pr = `pe' + .0000001	
		
		stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
		matrix X=e(b)
		matrix X = X[1,1..`e(df_m)']
		global xvar2: colnames X
		local list2 $xvar2
		dis "`list2'"
		
		scalar ncovariates = wordcount("`list2'")-1
		
		foreach c in $categorical_v { // categorical_v is variables that are categorical 
			local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
		}
		
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 
		
		predict yhat3 if milieu == 2, xb 
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
		estimates store rural1_swift
		outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT4") label
			
		quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
		
		quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
		
		
		**## estimate_accuracy fixed rate ---
		estimate_accuracy "rate"
		
		**### save accuracies ----
		tempfile tf_postfile1 
		tempname tn1
		postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace
		
		local common (ncovariates) ("SWIFT") ("4") ("Rural") ("Fixed rate") ("P=0.0001") 
		
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
		
		local common (ncovariates) ("SWIFT") ("4") ("Rural") ("Fixed line") ("P=0.0001") 
		
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
		
		**p = 0.00001
		capture drop yhat qhat qreal
		estimates restore rural1_swift
		keep if milieu == 2
		splitsample, generate(sample) split(0.8 0.2)  rseed(12345)  
		label define sample 1 "Training" 2 "Testing"
		label values sample sample
		
		gen popweight = hhsize*hhweight
		gen pauvre = (pcexp <= zref)
		svyset [pw=popweight], strata(region)
		set seed 0123456
		
		* Stepwise 
		local pe = 0.00001
		local pr = `pe' + .0000001	
		
		stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
		matrix X=e(b)
		matrix X = X[1,1..`e(df_m)']
		global xvar2: colnames X
		local list2 $xvar2
		dis "`list2'"
		
		scalar ncovariates = wordcount("`list2'")-1
		
		foreach c in $categorical_v { // categorical_v is variables that are categorical 
			local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
		}
		
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 
		
		predict yhat3 if milieu == 2, xb 
		
		reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
		estimates store rural1_swift
		outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT5") label
			
		quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
		
		quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
		
		
		**## estimate_accuracy fixed rate ---
		estimate_accuracy "rate"
		
		**### save accuracies ----
		tempfile tf_postfile1 
		tempname tn1
		postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace
		
		local common (ncovariates) ("SWIFT") ("5") ("Rural") ("Fixed rate") ("P=0.00001") 
		
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
		
		local common (ncovariates) ("SWIFT") ("5") ("Rural") ("Fixed line") ("P=0.00001") 
		
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
*/
		
**p = 0.000001
capture drop yhat qhat qreal
estimates restore rural1_swift
keep if milieu == 2

* Stepwise 
local pe = 0.000001
local pr = `pe' + .0000001	

stepwise, pr(`pr') pe(`pe'): reg lpcexp  (i.region) $cov_set1 [pw=popweight] if sample == 1 
matrix X=e(b)
matrix X = X[1,1..`e(df_m)']
global xvar2: colnames X
local list2 $xvar2
dis "`list2'"

scalar ncovariates = wordcount("`list2'")-1

foreach c in $categorical_v { // categorical_v is variables that are categorical 
	local list3 = subinstr("`list2'", "`c'", "i.`c'", 1)
}


reg lpcexp `list3' [aw=hhweight] if milieu == 2  & sample == 1, r 

predict yhat3 if milieu == 2, xb 

reg lpcexp `list3' [aw=hhweight] if milieu == 2, r 
estimates store rural2_swift
outreg2 using "${swdResults}/rural_coefficients.xls", append ctitle("SWIFT2") label
	
quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)


**## estimate_accuracy fixed rate ---
estimate_accuracy "rate"

**### save accuracies ----
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(Measure Quantile) float Number_of_vars str50(Model Version Place Poverty_measure  lambda sample)  double value using `tf_postfile1', replace

local common (ncovariates) ("SWIFT") ("6") ("Rural") ("Fixed rate") ("P=0.000001") 

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

local common (ncovariates) ("SWIFT") ("6") ("Rural") ("Fixed line") ("P=0.000001") 

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


