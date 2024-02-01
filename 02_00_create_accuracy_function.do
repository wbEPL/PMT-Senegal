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
		gen poor_hat_`t' = qhat < `t'
		
		* identify accurate individual
		gen correct_`t' = poor_real_`t' == poor_hat_`t'
		
		* identify undercovered individual
		gen undercovered_`t' = .
		replace undercovered_`t' = 1 if poor_real_`t' == 1 & poor_hat_`t' == 0
		replace undercovered_`t' = 0 if poor_real_`t' == 1 & poor_hat_`t' == 1
		
		* identify leaked individual
		gen leaked_`t' = .
		replace leaked_`t' = 1 if poor_real_`t' == 0 & poor_hat_`t' == 1
		replace leaked_`t' = 0 if poor_real_`t' == 0 & poor_hat_`t' == 0
		
		* total accuracy
		qui mean correct_`t'
		scalar mean_correct_`t' =  el(r(table),1,1)
		
		* Poverty accuracy
		qui mean correct_`t' if poor_real_`t' == 1
		scalar mean_poverty_`t' =  el(r(table),1,1)

		* Non-poverty accuracy
		qui mean correct_`t' if poor_real_`t' == 0
		scalar mean_non_poverty_`t' =  el(r(table),1,1)
		
		* exclusion error
		qui mean undercovered_`t' if poor_real_`t' == 1 
		scalar mean_undercoverage_`t' =  el(r(table),1,1)

		* inclusion error
		qui mean leaked_`t' if  poor_real_`t' == 0
		scalar mean_leakeage_`t' =  el(r(table),1,1)
	}

end
	