/* ------------------------------------------------------------------------------			
*			
*	This .do file estimates Senegal PMT. 
*	The input files are: 
*		- data4model_2021.dta
*	The following result files are created:
*		- TBD
*	Open points that need to be addressed:
* 		- TBD
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 23 January 2024
*	Reviewer: TBD
*	Last Reviewed: TBD

*------------------------------------------------------------------------------- */


**# INIT ----------------------------

use "${swdFinal}/data4model_2021.dta", clear
gen lpcexp=ln(pcexp)

**## Rural -----
reg lpcexp logzise oadr yadr ///
			i.c_floor  i.c_water  i.c_ligthing i.c_walls i.c_toilet ///
			moto radio car fan tv hotwater mobile  boat landline ordin aircond wagon frigo  ///
			horses goats sheep poultry bovines ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 2, r

predict yhat, xb

*quantiles yhat [aw=hhweight*hhsize] if milieu == 2 , gen(qhat) n(100)
egen qhat=xtile(yhat)  if milieu == 2 , n(100) weights(hhweight*hhsize)

*quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
egen qreal=xtile(lpcexp)  if milieu == 2 , n(100) weights(hhweight*hhsize)

do "$scripts/02_01_accuracy_rural.do"

**## Urban -----

use "${swdFinal}/data4model_2021.dta", clear
gen lpcexp=ln(pcexp)

reg lpcexp logzise yadr ///
			i.c_floor i.c_ligthing i.c_toilet i.c_walls ///
			car ordin frigo cuisin fan tv radio landline tractor fer ///
			donkey horses pigs ///
			i.region ///
			[aweight = hhweight*hhsize] if milieu == 1, r
predict yhat, xb
			
*quantiles yhat [aw=hhweight*hhsize] if milieu == 1 , gen(qhat) n(100)
egen qhat=xtile(yhat)  if milieu == 1 , n(100) weights(hhweight*hhsize)

*quantiles lpcexp [aw=hhweight*hhsize] if milieu == 2, gen(qreal) n(100)
egen qreal=xtile(lpcexp)  if milieu == 2 , n(100) weights(hhweight*hhsize)

run "$scripts/02_02_accuracy_urban.do"
