
**## Lasso 1 urban, assets as dummy ------------------
capture drop yhat qhat qreal

lasso linear lpcexp $demo $asset_dum $asset_rur_dum $dwell $livest_all_dum if milieu == 1 & sample == 1
estimates store urban1
cvplot
graph save "${swdResults}/graphs/cvplot_urban1", replace
lassocoef urban1
lassogof urban1, over(sample) postselection

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

* run ols with selected covariates and pop weights

reg lpcexp logsize yadr alfa_french i.region a_living a_bed a_singlemat ///
	a_cupboard a_iron a_charcoaliron a_stove a_gastank a_hotplate ///
	a_foodprocessor a_fruitpress a_fridge a_freezer a_fan a_radio a_tv ///
	a_satellite a_washer a_ac a_car a_moped a_hifisystem a_homephone a_computer ///
	a_printer a_boat a_land ad_fan_b ar_tiller ar_axe_pickaxe ar_harrow ///
	ar_plou_anima ar_drinker_fee ar_mower ar_incubator ar_gill_net ar_others ///
	i.c_typehousing i.c_numberofrooms_c i.c_housingocup i.c_walls i.c_roof i.c_floor ///
	i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_ligthing ///
	i.c_connectedtoint i.c_internettype i.c_connectedtotv i.c_fuelfirst_r i.c_garbage ///
	i.c_toilet l_bovines l_sheep l_horses l_pigs l_rabbits ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban1_ols

predict yhat if milieu == 1, xb 

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)
lassogof urban1 urban1_ols, over(sample) postselection

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 1" "FALSE"

**## Lasso 2 urban, assets and livestock as number --------------
capture drop yhat qhat qreal

lasso linear lpcexp $demo $asset_num $asset_rur_num $dwell $livest_all_num if milieu == 1 & sample == 1
estimates store urban2
cvplot
graph save "${swdResults}/graphs/cvplot_urban2", replace
lassocoef urban1 urban2
lassogof urban1 urban2, over(sample) postselection

*Show selected covariates
dis e(post_sel_vars) /*This doesn't show if the variable is categorical or not. 
						For now I'll do it by hand but if it can be done programatically better*/

* run ols with selected covariates and pop weights

reg lpcexp logsize yadr alfa_french i.region a_cupboard_n a_carpet_n a_iron_n ///
		a_charcoaliron_n a_stove_n a_gastank_n a_hotplate_n a_fireplace_n ///
		a_foodprocessor_n a_fruitpress_n a_fridge_n a_freezer_n a_fan_n ///
		a_radio_n a_tv_n a_satellite_n a_washer_n a_ac_n a_car_n a_hifisystem_n ///
		a_cellphone_n a_tablet_n a_computer_n a_printer_n a_boat_n a_land_n ///
		ad_hotwater ad_fan_b ar_tiller_n ar_incubator_n ar_no_motor_can_n ///
		ar_others_n i.c_typehousing i.c_housingocup i.c_walls i.c_roof i.c_floor ///
		i.c_connectowater i.c_water_dry i.c_water_rainy i.c_connectoelec i.c_ligthing ///
		i.c_landline i.c_connectedtoint i.c_internettype i.c_connectedtotv ///
		i.c_fuelfirst_r i.c_garbage i.c_toilet l_sheep_n l_donkeys_n l_pigs_n l_chickens_n ///
	[aw=hhweight*hhsize] if milieu == 1 & sample == 1, r

estimates store urban2_ols


lassogof urban2 urban2_ols, over(sample) postselection


predict yhat if milieu == 1, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)

quantiles lpcexp [aw=hhweight*hhsize] if milieu == 1, gen(qreal) n(100)

estiaccu_measures
save_measures "accuracy2015vs2021.xlsx" "Accuracy Lasso 2" "FALSE"

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

* TODO: ugly way to count covariates, how to program this?? urgent!!
estimates restore rural1_ols
dis e(cmdline)

**# Export ols using lasso with the same covariates
estimates restore rural3_ols
outreg2 using  "${swdResults}/LassoResultsRural.xls", replace label

estimates restore urban3_ols
outreg2 using "${swdResults}/LassoResultsUrban.xls", replace label