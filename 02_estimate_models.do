/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates Senegal PMT. 
*	The input files are: 
*		- TBD
*	The following data is created:
*		- TBD
*	Open points that need to be addressed:
* 		- TBD
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 1 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*-------------------------------------------------------------------------------	*/


**# INIT ----------------------------

use "${swdFinal}/data4model_2021.dta", clear

**## Rural -----

local xvars  
*TODO: bovins is not in data, there is big and small rumiants
*TODO: several assets not included, shouuld we include agicultural surface?
gen lpcexp=ln(pcexp)
reg lpcexp  logzise oadr yadr ///
			i.c_floor  i.c_water  i.c_ligthing i.c_walls i.c_toilet ///
			 moto radio car fan tv hotwater mobile  boat landline ordin aircond wagon frigo  ///
			 horses goats sheep poultry bovines /// 
			  i.region [aweight = hhweight*hhsize] if milieu == 2, r

predict yhat, xb

quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
 
quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)


foreach t in 20 25 30 50 75 {
	gen leakeage_`t'=qreal>`t' if qhat<`t'
}



**## Urban -----

keep if milieu == 1
local xvars "i.region  volail lapin porc petitrum grosrum frigo fer ordin tv car toilet eva_toi eva_eau eauboi_ss  eauboi_sp sol toit mur yadr oadr logzise" 

reg pcexp `xvars'