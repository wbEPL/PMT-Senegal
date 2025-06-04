****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Performance Checks - larger model							   *
* Jeremy Schneider - May 2025								   *
****************************************************************
* Calculate Leakage & Under Coverage Rates

clear all 
version 17
cap ssc install xtable

global path "/Users/jeremyschneider/Desktop/SEN PMT"
global data "$path/data"
global results "$path/results"
global log "$path/log"

capture log close
log using "$log/SEN_PMT_Model_Performance_largermodel.log", replace 

use "$data/data4model_2021_IMPUTED_largermodel.dta", clear

global weight popweight
global lnwelfare lpcexp
global welfare pcexp

twoway kdensity lpcexp_pred [aw=$weight] || kdensity lpcexp_pred if b40==1 [aw=$weight], legend(on order(1 "All HBS" 2 "Bottom 40% HBS")) title("National HBS (Larger Urb-Rur Models): Distribution of Predicted Log Expenditure (PMT scores)", size(small)) 
gr save "$results/HBS_pmtscore_distribution_largermodels.gph",  replace

gen samplesize = _N
xtile decile = $lnwelfare [aw=$weight], nq(10)

gen actual = pcexp
gen pmt = pcexp_pred

local list "15 18 20 30 37 40"

* Set cutoffs at specified percentiles in list above
foreach t of numlist `list' {
	foreach x of varlist actual pmt {
		_pctile `x' [aw=$weight] , p(`t') // here we calculate the percentile value of actual and pmt
		cap drop cut_`x'_`t'  poor_`x'_`t' 
		g cut_`x'_`t'=r(r1)  // here we define the cutoffs 
		g poor_`x'_`t'= (`x'<=cut_`x'_`t')  // here we define everyone who has a score below the cutoff as poor
	}
}


foreach truepoor in poor_actual_20 poor_actual_37 {
	
	preserve

	foreach t of numlist `list' {
	
		qui cap drop poor_pmtpoor_`t' nonpoor_pmtpoor_`t' poor_pmtnonpoor_`t' nonpoor_pmtnonpoor_`t'
			
		qui g fpoor_pmtpoor_`t'		=	`truepoor' == 1 & poor_pmt_`t'==1 // Household is actually poor and pmt predicted poor
		qui g fnonpoor_pmtpoor_`t'	=	`truepoor' == 0 & poor_pmt_`t'==1 // Household is not poor but pmt predicted poor
		qui g fpoor_pmtnonpoor_`t'	=	`truepoor' == 1 & poor_pmt_`t'==0 // Household is actually poor but pmt predicted not poor
		qui g fnonpoor_pmtnonpoor_`t'=	`truepoor' == 0 & poor_pmt_`t'==0 // Household is not poor and pmt predicted not poor
		
		qui g ftotalaccuracy`t' = ((fpoor_pmtpoor_`t'+fnonpoor_pmtnonpoor_`t')/(fpoor_pmtpoor_`t'+fpoor_pmtnonpoor_`t'+fnonpoor_pmtpoor_`t'+fnonpoor_pmtnonpoor_`t')) // (correctly predicted poor + correctly pred nonpoor)/ Total sample size
		qui g fpovertyaccuracy`t'  = (fpoor_pmtpoor_`t'/(fpoor_pmtpoor_`t'+fpoor_pmtnonpoor_`t')) // (correctly predicted poor) / (all poor)
		qui g fnpovertyaccuracy`t' = (fnonpoor_pmtnonpoor_`t'/(fnonpoor_pmtpoor_`t'+fnonpoor_pmtnonpoor_`t')) // (correctly predicted not poor) / (all non poor)
		qui g fundercoverage`t'    = (fpoor_pmtnonpoor_`t'/(fpoor_pmtpoor_`t'+fpoor_pmtnonpoor_`t'))  // (poor but predicted not poor PMT) / (all true poor)
		qui g finclusionerror`t'   = (fnonpoor_pmtpoor_`t'/(fpoor_pmtpoor_`t'+fnonpoor_pmtpoor_`t')) // (not poor but PMT predicted poor) / (all PMT pred poor)
		
	}

	fsum ftotalaccuracy* fpovertyaccuracy* fnpovertyaccuracy* fundercoverage* finclusionerror*  [aw=$weight] 
	
	keep fundercoverage* finclusionerror*  $weight
	collapse (mean) fundercoverage* finclusionerror*   [pw=$weight] 

	save "$results/SEN2021_SWIFTPMT_targeting_natl_large_performance_`truepoor'.dta",replace


	restore
}

cap log close
