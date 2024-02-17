/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso urban model 1, all cov as dum
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal
**# Run lasso regresion, save results chosen lambda

lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 1 & sample == 1, rseed(124578)
estimates store urban1
cvplot
graph save "${swdResults}/graphs/cvplot_urban1", replace
lassocoef urban1
lassogof urban1, over(sample) postselection

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1

* run ols with selected covariates and pop weights

reg lpcexp logsize yadr alfa_french i.region a_living a_dining a_bed a_singlemat ///
			a_cupboard a_iron a_charcoaliron a_gastank a_foodprocessor a_fruitpress ///
			a_fridge a_freezer a_fan a_radio a_tv a_satellite a_vacuum a_ac ///
			a_lawnmower a_car a_moped a_hifisystem a_homephone a_tablet a_computer ///
			a_printer a_land ad_fan_b ar_axe_pickaxe ar_harrow ar_scale ///
			ar_drinker_fee ar_mower ar_incubator ar_no_motor_can ar_others ///
			i.c_typehousing c_numberofrooms_c i.c_housingocup i.c_walls i.c_roof ///
			i.c_floor c_connectowater i.c_water_rainy i.c_ligthing c_connectedtoint ///
			i.c_internettype c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet ///
			l_bovines l_sheep l_horses l_pigs l_chickens l_other_poultry ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban1_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda CV")
estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 1" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 1" "FALSE"
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda CV"

**## Lambda 0.025
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.025
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize yadr alfa_french i.region a_living a_dining a_bed a_cupboard ///
			a_iron a_charcoaliron a_gastank a_fruitpress a_fridge a_freezer a_fan ///
			a_tv a_satellite a_ac a_lawnmower a_car a_moped a_tablet a_computer ///
			a_land ad_fan_b ar_incubator ar_no_motor_can i.c_walls i.c_roof ///
			i.c_floor c_connectowater i.c_ligthing c_connectedtoint i.c_internettype ///
			i.c_fuelfirst_r i.c_garbage i.c_toilet l_horses ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r
	
estimates store urban1_lam_025_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.025")
estiaccu_measures
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.025"

**## Lambda 0.05
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.05
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize yadr a_living a_dining a_cupboard a_charcoaliron a_gastank ///
			a_fruitpress a_fridge a_freezer a_fan a_tv a_ac a_car a_tablet ///
			a_computer a_land i.c_walls i.c_roof i.c_floor c_connectowater ///
			i.c_ligthing c_connectedtoint i.c_fuelfirst_r i.c_garbage ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r
	
estimates store urban1_lam_05_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols urban1_lam_05_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.05")
estiaccu_measures
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.05"

**## Lambda 0.08
capture drop yhat qhat qreal
estimates restore urban1
lassoselect lambda = 0.08
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize yadr a_living a_cupboard a_fridge a_freezer a_fan a_tv a_ac ///
			a_car a_computer a_land i.c_roof i.c_floor c_connectowater i.c_ligthing ///
			c_connectedtoint i.c_fuelfirst_r i.c_garbage ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r
	
estimates store urban1_lam_08_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols urban1_lam_025_ols urban1_lam_05_ols urban1_lam_08_ols if milieu == 1, over(sample) postselection

outreg2 using "${swdResults}/urban_coefficients.xls", append ctitle("Lasso 1-lambda 0.08")
estiaccu_measures
save_lambdmeasu "accuracies_urban1.xlsx" "Lambda 0.08"
