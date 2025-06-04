****************************************************************
* Senegal PMT Stepwise					 				 	   *
* Performance Checks -- URBAN ONLY							   *
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
log using "$log/SEN_PMT_Performance_largermodel_urban.log", replace 

use "$data/data4model_2021_IMPUTED_largermodel.dta", clear
keep if milieu==1 // (milieu: 1=urban, 2=rural)

global weight popweight
global lnwelfare lpcexp
global welfare pcexp

twoway kdensity lpcexp_pred [aw=$weight] || kdensity lpcexp_pred if b40==1 [aw=$weight], legend(order(1 "All Urban HBS" 2 "Urban HBS in Bottom 40%") size(small)) title("Urban HBS (Larger Model): Distribution of Predicted Log Expenditure (PMT scores)", size(small)) 
gr save "$results/HBS_pmtscore_distribution_urban_large.gph",  replace

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

* Simpler format to calculate targeting perofrmance (if we dont need to calculate standard errors for example)
svyset, clear

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

	save "$results/SEN2021_SWIFTPMT_targeting_urban_large_performance_`truepoor'.dta",replace

	restore
}


/*
	preserve 
	keep if _n == 1 
	save "$results/SEN2021_SWIFTPMT_targeting_urban_large.dta",replace
	restore 


* PMT Coverage by decile -- LEAKAGE
preserve 
	foreach t in 15 18 20 30 37 40 {	
			
			qui: gen dist_`t' = .
			
			qui: tab decile [aw = $weight] if poor_pmt_`t' == 1, 	matcell(table) 		
			
			qui: matrix list table 		// cette partie du code est le seul moyen d'enregistrer les pourcentages de la commande "tab", et de sauter les déciles ayant 0 observations qui ne s'affiche pas dans le tableau créé par la commande
			local obs = r(N)			
			local cat = r(r)
			
			local i = 1
			local j = 0 
			qui: di `cat'
			
			 while `i' <= 10 & `j'  <= `cat' {
					
					*qui: di "Calculating decile `i' (which is value `j' out of `cat' in the table)"

					qui: count if poor_pmt_`t' == 1 & decile == `i'
					local decile_obs = r(N)


					if `decile_obs' != 0 {
						
							qui: replace dist_`t' = 100 * (table[`j'+1,1] / `obs') if decile == `i'
							local i = `i' + 1	
							local j = `j' + 1
							qui: di "i:`i', j: `j' "
					}
					
						
					else {
						qui: replace dist_`t' = 0 if decile == `i'
						local i = `i' + 1
						qui: di "i:`i', j: `j' "

			}
					
		}
			 
		 
}			
collapse (mean) dist_15 dist_18 dist_20 dist_30 dist_37 dist_40, by(decile)
save "$results/SEN2021_SWIFTPMT_leakage_urban_large.dta", replace 
restore 


* PMT Non-coverage by decile -- UNDERCOVERAGE 
preserve 

		foreach t in 15 18 20 30 37 40 {	
		
		qui: gen dist_`t' = .
		
		qui: tab decile [aw = $weight] if poor_pmt_`t' == 0, 	matcell(table) 		
		
		qui: matrix list table 		// cette partie du code est le seul moyen d'enregistrer les pourcentages de la commande "tab", et de sauter les déciles ayant 0 observations qui ne s'affiche pas dans le tableau créé par la commande
		local obs = r(N)			
		local cat = r(r)
		
		local i = 1
		local j = 0 
		qui: di `cat'
		
		 while `i' <= 10 & `j'  <= `cat' {
				
				*qui: di "Calculating decile `i' (which is value `j' out of `cat' in the table)"

				qui: count if poor_pmt_`t' == 0 & decile == `i'
				local decile_obs = r(N)


				if `decile_obs' != 0 {
					
						qui: replace dist_`t' = 100 * (table[`j'+1,1] / `obs') if decile == `i'
						local i = `i' + 1	
						local j = `j' + 1
						qui: di "i:`i', j: `j' "
				}
				
					
				else {
					qui: replace dist_`t' = 0 if decile == `i'
					local i = `i' + 1
					qui: di "i:`i', j: `j' "

		}
				
	}
		 
	 
}								
collapse (mean) dist_15 dist_18 dist_20 dist_30 dist_37 dist_40, by(decile)
save "$results/SEN2021_SWIFTPMT_undercoverage_urban_large.dta", replace 
restore							


* PMT Non-Coverage Decile Graph	
use "$results/SEN2021_SWIFTPMT_undercoverage_urban_large.dta", clear 
sort decile
gen dist_20_opp = 100 - dist_20
graph twoway   /// 		choosing poorest 20% as true poor population (dist_20)
	(bar dist_20_opp decile if decile <= 2, fcolor(maroon*0.6) lcolor(maroon*0.6)) ///
    (bar dist_20_opp decile if decile >= 3 & decile <= 5, fcolor(sand*0.6) lcolor(sand*0.6)) ///
    (bar dist_20_opp decile if decile >= 6,  fcolor(dkgreen*0.6) lcolor(dkgreen*0.6)), ///
	legend(off) ytitle("Percent of All Covered Households Urban", size(medsmall)) xtitle("Decile of True Consumption Level (true poor bottom 20%)", size(medsmall)) xlabel(1(1)10, labsize(small)) ylabel(84(3)100,labsize(small))
gr save "$results/SEN2021_undercoverage_truepoor20_urban_large.gph",  replace

gen dist_37_opp = 100 - dist_37
graph twoway   /// 		choosing poorest 37% as true poor population (dist_37)
	(bar dist_37_opp decile if decile <= 2, fcolor(maroon*0.6) lcolor(maroon*0.6)) ///
    (bar dist_37_opp decile if decile >= 3 & decile <= 5, fcolor(sand*0.6) lcolor(sand*0.6)) ///
    (bar dist_37_opp decile if decile >= 6,  fcolor(dkgreen*0.6) lcolor(dkgreen*0.6)), ///
	legend(off) ytitle("Percent of All Covered Households Urban", size(medsmall)) xtitle("Decile of True Consumption Level (true poor bottom 37%)", size(medsmall)) xlabel(1(1)10, labsize(small)) ylabel(84(3)100,labsize(small))
gr save "$results/SEN2021_undercoverage_truepoor37_urban_large.gph",  replace


* PMT Coverage Decile Graph									
use "$results/SEN2021_SWIFTPMT_leakage_urban_large.dta", clear 
sort decile
graph twoway   /// 		choosing poorest 20% as true poor population (dist_20)
	(bar dist_20 decile if decile <= 2, fcolor(dkgreen*0.6) lcolor(dkgreen*0.6)) ///
    (bar dist_20 decile if decile >= 3 & decile <= 5, fcolor(sand*0.6) lcolor(sand*0.6)) ///
    (bar dist_20 decile if decile >= 6,  fcolor(maroon*0.6) lcolor(maroon*0.6)), ///
	 legend(off)ytitle("Percent of All Covered Households", size(medsmall)) xtitle("Decile of True Consumption Level (true poor bottom 20%)", size(medsmall)) xlabel(1(1)10, labsize(small)) ylabel(,labsize(small))  title("Distribution of eligible population Urban")
gr save "$results/SEN2021_leakage_truepoor20_urban_large.gph",  replace

graph twoway   /// 		choosing poorest 20% as true poor population (dist_37)
	(bar dist_37 decile if decile <= 2, fcolor(dkgreen*0.6) lcolor(dkgreen*0.6)) ///
    (bar dist_37 decile if decile >= 3 & decile <= 5, fcolor(sand*0.6) lcolor(sand*0.6)) ///
    (bar dist_37 decile if decile >= 6,  fcolor(maroon*0.6) lcolor(maroon*0.6)), ///
	 legend(off)ytitle("Percent of All Covered Households", size(medsmall)) xtitle("Decile of True Consumption Level (true poor bottom 37%)", size(medsmall)) xlabel(1(1)10, labsize(small)) ylabel(,labsize(small))  title("Distribution of eligible population Urban")
gr save "$results/SEN2021_leakage_truepoor37_urban_large.gph",  replace

*/	
capture log close
