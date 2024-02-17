/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 3, all cov as NUM
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

**## Lasso 3 rural, same covariates as OLS 2015 ------------------
capture drop yhat qhat qreal

lasso linear lpcexp logsize oadr yadr ///
			i.c_floor i.c_water_dry i.c_ligthing i.c_walls i.c_toilet ///
			a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge  ///
			l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n ///
			i.region if milieu == 2 & sample == 1
estimates store rural3
cvplot
graph save "${swdResults}/graphs/cvplot_rural3", replace
lassocoef rural3
lassogof rural3, over(sample) postselection


*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

* run ols with selected covariates and pop weights

reg lpcexp logsize yadr i.c_floor i.c_water_dry i.c_ligthing i.c_walls i.c_toilet ///
	a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_computer a_ac ///
	a_fridge l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n i.region ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1,r 

estimates store rural3_ols

predict yhat if milieu == 2, xb 
lassogof rural3 rural3_ols, over(sample) postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 3" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 3" "TRUE"

**## Lasso 3 urban, same covariates as OLS 2015 ------------------
capture drop yhat qhat qreal

lasso linear lpcexp logsize yadr alfa_french ///
			i.c_floor i.c_ligthing i.c_toilet i.c_walls ///
			a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor a_iron ///
			l_donkeys_n l_horses_n l_pigs_n ///
			i.region if milieu == 1 & sample == 1
estimates store urban3
cvplot
graph save "${swdResults}/graphs/cvplot_urban3", replace
lassocoef urban3
lassogof urban3, over(sample) postselection


*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

* run ols with selected covariates and pop weights

reg lpcexp logsize alfa_french yadr i.c_floor i.c_ligthing i.c_toilet i.c_walls a_car a_computer ///
	a_fridge a_stove a_fan a_tv a_radio a_homephone a_iron l_horses_n i.region ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban3_ols

predict yhat if milieu == 1, xb 
lassogof urban3 urban3_ols, over(sample) postselection

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 3" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 3" "FALSE"
