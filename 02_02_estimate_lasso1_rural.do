/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates lasso rural model 1, all cov as dum
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */

capture drop yhat qhat qreal
**# Run lasso regresion, save results chosen lambda
lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 2 & sample == 1, rseed(124578)
estimates store rural1
cvplot
graph save "${swdResults}/graphs/cvplot_rural1", replace
*show selected coefs
lassocoef rural1
*show model goodness of fit
lassogof rural1 if milieu == 2, over(sample) postselection

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

scalar ncovariates = wordcount(e(post_sel_vars))-1
* run ols with selected covariates and pop weights

reg lpcexp logsize oadr yadr alfa_french i.region a_living a_dining a_cupboard a_carpet ///
		a_iron a_charcoaliron a_gastank a_oven a_foodprocessor a_fridge a_freezer a_fan ///
		a_radio a_tv a_dvd a_satellite a_generator a_car a_moped a_bike a_tablet a_shotgun ///
		a_land ar_sprayer ar_axe_pickaxe ar_hoe_daba_hill ar_asinine_hoe ar_scale ///
		ar_straw_chop ar_drinker_fee ar_mower ar_mill i.c_typehousing c_numberofrooms_c ///
		i.c_housingocup c_businessindwe i.c_walls i.c_roof i.c_floor i.c_water_rainy ///
		c_connectoelec i.c_ligthing c_landline c_connectedtoint c_connectedtotv ///
		i.c_fuelfirst_r i.c_garbage i.c_toilet l_sheep l_donkeys l_pigs l_chickens ///
		l_other_poultry ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r


estimates store rural1_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols if milieu == 2, over(sample) postselection

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 1" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy Lasso 1" "TRUE"
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda CV"
outreg2 using "rural_coefficients.xls", append ctitle("Lasso 1-lambda CV") label

**## Lambda 0.01
capture drop yhat qhat qreal
estimates restore rural1
lassoselect lambda = 0.01
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize oadr yadr alfa_french i.region a_living a_dining a_cupboard a_carpet ///
	a_iron a_charcoaliron a_gastank a_oven a_fridge a_freezer a_fan a_radio a_tv ///
	a_dvd a_satellite a_car a_moped a_bike a_tablet a_shotgun a_land ar_sprayer ///
	ar_axe_pickaxe ar_scale ar_straw_chop ar_drinker_fee ar_mower ar_mill ///
	i.c_typehousing c_numberofrooms_c i.c_housingocup c_businessindwe i.c_walls ///
	i.c_roof i.c_water_rainy c_connectoelec i.c_ligthing c_landline c_connectedtoint ///
	c_connectedtotv i.c_fuelfirst_r i.c_garbage i.c_toilet l_sheep l_pigs l_chickens l_other_poultry ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r
	
estimates store rural1_lam01_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols if milieu == 2, over(sample) postselection

estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.01"
outreg2 using "rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.01") label

**## Lambda 0.03
capture drop yhat qhat qreal
estimates restore rural1
lassoselect lambda = 0.03
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize yadr i.region a_living a_cupboard a_carpet a_charcoaliron a_gastank ///
	 a_oven a_fridge a_freezer a_fan a_radio a_tv a_satellite a_car a_moped ///
	 ar_sprayer c_numberofrooms_c i.c_housingocup c_businessindwe i.c_walls ///
	 i.c_roof c_connectoelec i.c_ligthing c_connectedtoint c_connectedtotv ///
	 i.c_fuelfirst_r i.c_garbage i.c_toilet l_sheep ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r

estimates store rural1_lam03_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols rural1_lam03_ols if milieu == 2, over(sample) postselection
 
estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.03"
outreg2 using "rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.03") label

**## Lambda 0.05
capture drop yhat qhat qreal
estimates restore rural1
lassoselect lambda = 0.05
cvplot
scalar ncovariates = wordcount(e(post_sel_vars))-1
dis "amount of covariates is: " 
dis ncovariates
dis e(post_sel_vars)

reg lpcexp logsize yadr i.region a_living a_cupboard a_carpet a_charcoaliron ///
			a_gastank a_fridge a_freezer a_fan a_tv a_satellite a_car i.c_walls ///
			i.c_roof c_connectoelec i.c_ligthing c_connectedtoint c_connectedtotv ///
			i.c_fuelfirst_r c_toilet ///
	[aw=hhweight*hhsize] if milieu == 2 & sample == 1, r

	 
	
estimates store rural1_lam05_ols
	
predict yhat  if milieu == 2, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
lassogof rural1 rural1_ols rural1_lam01_ols rural1_lam03_ols rural1_lam05_ols if milieu == 2, over(sample) postselection

estiaccu_measures
save_lambdmeasu "accuracies_rural1.xlsx" "Lambda 0.05"
outreg2 using "rural_coefficients.xls", append ctitle("Lasso 1-lambda 0.05") label
