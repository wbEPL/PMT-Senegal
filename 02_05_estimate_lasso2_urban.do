/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 2, all cov as NUM
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal
**# Run lasso regresion, save results chosen lambda

lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 1 & sample == 1
estimates store urban2
cvplot
graph save "${swdResults}/graphs/cvplot_urban2", replace
lassocoef urban1 urban2
lassogof urban1 urban2, over(sample) postselection

*Show selected covariates
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/


						
* run ols with selected covariates and pop weights

reg lpcexp  logsize yadr alfa_french i.region a_dining_n a_cupboard_n a_carpet_n ///
			a_charcoaliron_n a_stove_n a_gastank_n a_fireplace_n a_foodprocessor_n ///
			a_fruitpress_n a_fridge_n a_freezer_n a_fan_n a_radio_n a_tv_n a_dvd_n ///
			a_satellite_n a_vacuum_n a_ac_n a_lawnmower_n a_generator_n a_car_n ///
			a_hifisystem_n a_homephone_n a_cellphone_n a_computer_n a_printer_n ///
			a_land_n ad_hotwater ad_fan_b ar_scale_n ar_straw_chop_n ar_mower_n ///
			ar_incubator_n ar_no_motor_can_n ar_gill_net_n ar_others_n ///
			i.c_housingocup i.c_walls i.c_roof i.c_floor c_connectowater ///
			i.c_water_rainy i.c_ligthing c_connectedtoint i.c_internettype ///
			c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet l_bovines_n ///
			l_horses_n l_pigs_n l_chickens_n l_other_poultry_n ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban2_ols


lassogof urban2 urban2_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda CV")
estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 2" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 2" "FALSE"
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda CV"

**## Lambda 0.04
capture drop yhat qhat qreal
estimates restore urban2
lassoselect lambda = 0.04
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates			
* run ols with selected covariates and pop weights

reg lpcexp logsize yadr alfa_french a_cupboard_n a_charcoaliron_n a_stove_n ///
			a_gastank_n a_fridge_n a_freezer_n a_fan_n a_tv_n a_ac_n a_lawnmower_n ///
			a_car_n a_homephone_n a_computer_n ad_fan_b i.c_walls i.c_roof i.c_floor ///
			c_connectowater i.c_ligthing c_connectedtoint c_connectedtotv ///
			i.c_fuelfirst_r i.c_garbage ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban2_lam04_ols


lassogof urban2 urban2_ols urban2_lam04_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.04")
estiaccu_measures
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 0.04"

**## Lambda 0.06
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.06
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates			
* run ols with selected covariates and pop weights

reg lpcexp logsize yadr a_living a_dining a_cupboard a_gastank a_fridge a_freezer ///
		a_fan a_tv a_ac a_car a_computer a_land i.c_walls i.c_roof i.c_floor ///
		c_connectowater i.c_ligthing c_connectedtoint i.c_fuelfirst_r c_garbage ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban2_lam06_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.06")
estiaccu_measures
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 0.06"

**## Lambda 0.08
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.08
cvplot

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
				dis "amount of covariates is: " 
dis ncovariates			
* run ols with selected covariates and pop weights

reg lpcexp logsize yadr a_living a_cupboard a_fridge a_freezer a_fan a_tv a_ac ///
			a_car a_computer a_land i.c_roof i.c_floor c_connectowater i.c_ligthing ///
			c_connectedtoint i.c_fuelfirst_r i.c_garbage ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban2_lam08_ols


lassogof urban2 urban2_ols urban2_lam04_ols urban2_lam06_ols urban2_lam08_ols if milieu == 1, over(sample) postselection

predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 2-lambda 0.08")
estiaccu_measures
save_lambdmeasu "accuracies_urban2.xlsx" "Lambda 0.08"