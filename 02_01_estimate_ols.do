/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates ols models with the same covariates 
*	ONLY works inside 02_estimate_models.do
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */


**## Rural -----

reg lpcexp logsize oadr yadr ///
			i.c_floor i.c_water_dry i.c_ligthing i.c_walls i.c_toilet ///
			a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge  ///
			l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 2, r

predict yhat, xb
scalar ncovariates = wordcount(e(cmdline))-10 /* THIS ONLY WORKS IF YOU DO NOT CHANGE THE SPACES AMONG THE DIFFERENT PARTS ON THE REG COMMAND, for example if you erase the space between aweight = that will change the count*/
estimates store ols_rural

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "TRUE"
save_lambdmeasu "accuracies_OLS.xlsx" "Rural"
outreg2 using "rural_coefficients.xls", replace ctitle("OLS") label

**## Urban -----
capture drop yhat qhat qreal
reg lpcexp logsize yadr alfa_french ///
			i.c_floor i.c_ligthing i.c_toilet i.c_walls ///
			a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor a_iron ///
			l_donkeys_n l_horses_n l_pigs_n ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 1, r
predict yhat, xb
estimates store ols_urban
scalar ncovariates = wordcount(e(cmdline))-10 /* THIS ONLY WORKS IF YOU DO NOT CHANGE THE SPACES AMONG THE DIFFERENT PARTS ON THE REG COMMAND, for example if you erase the space between aweight = that will change the count*/
quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)


estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "FALSE"
save_lambdmeasu "accuracies_OLS.xlsx" "Urban"
outreg2 using "urban_coefficients.xls", replace ctitle("Urban OLS") label
