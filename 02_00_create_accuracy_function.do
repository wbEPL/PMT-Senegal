/* ------------------------------------------------------------------------------			
*			
*	This .do file defines program accuracy_measures
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 31 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */
capture program drop accuracy_measures
program define accuracy_measures
	 
	foreach t in 20 25 30 50 75 {
		capture drop poor_real_`t' poor_hat_`t' correct_`t' undercovered_`t' leaked_`t'

		* identify poor people in data and in model
		gen poor_real_`t' = qreal < `t' 
		
		mean lpcexp [aw=hhweight*hhsize] if qreal == `t' 
		scalar mean_lpcexp =  el(r(table),1,1)
		gen poor_hat_`t' = yhat < mean_lpcexp
		
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
		mean leaked_`t' [aw=hhweight*hhsize]  if  poor_hat_`t' == 1
		scalar mean_leakeage_`t' =  el(r(table),1,1)
	}

end
	
