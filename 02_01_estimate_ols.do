/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates ols models with the same covariates of the orginal PMT
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 16 February 2024
*	
*	Modified: 
*	Now the entire sample is limited 
*	Out of sample prediction MSE and R-squared and Maybe poverty accuracy or leakeage 50%

*------------------------------------------------------------------------------- */


**## Rural -----
preserve 
keep if milieu == 2
reg lpcexp logsize oadr yadr c_rooms_pc ///
			i.c_floor i.c_water_dry i.c_lighting i.c_walls i.c_toilet ///
			a_moped a_radio a_car a_fan a_tv ad_hotwater a_cellphone a_boat a_homephone a_computer a_ac ar_carts a_fridge  ///
			l_horses_n l_goats_n l_sheep_n l_poultry_n l_bovines_n ///
			i.region ///
			[aweight = hhweight] if milieu == 2, r

predict yhat if milieu == 2, xb
local covariates = subinstr("`e(cmdline)'", "regress lpcexp", "", .)
local covariates = subinstr("`covariates'", "[aweight = hhweight] if milieu == 2, r", "", .)
scalar ncovariates = wordcount("`covariates'")
local covariates ""

estimates store ols_rural

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)

outreg2 using "${swdResults}/rural_coefficients.xls", replace ctitle("OLS") label

*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy" "TRUE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "TRUE"
save_lambdmeasu "accuracies_OLS.xlsx" "Rural"

restore 

**## Urban -----
preserve 
keep if milieu == 1

capture drop yhat qhat qreal
reg lpcexp logsize yadr alfa_french c_rooms_pc ///
			i.c_floor i.c_lighting i.c_toilet i.c_roof ///
			a_car a_computer a_fridge a_stove a_fan a_tv a_radio a_homephone ar_tractor a_iron ///
			l_donkeys_n l_horses_n l_pigs_n ///
			i.region ///
			[aweight = hhweight] if milieu == 1, r
predict yhat if milieu == 1, xb
local covariates = subinstr("`e(cmdline)'", "regress lpcexp", "", .)
local covariates = subinstr("`covariates'", "[aweight = hhweight] if milieu == 1, r", "", .)
scalar ncovariates = wordcount("`covariates'")
local covariates ""

estimates store ols_urban

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

outreg2 using "${swdResults}/urban_coefficients.xls", replace ctitle("Urban OLS") label
*estiaccu_measures
estiaccu_measures_ch
save_measures "accuracy2015vs2021.xlsx" "Accuracy" "FALSE"
save_measures_test "accuracy2015vs2021_testsample.xlsx" "Accuracy" "FALSE"
save_lambdmeasu "accuracies_OLS.xlsx" "Urban"

restore 
