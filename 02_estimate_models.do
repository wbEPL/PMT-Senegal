* ------------------------------------------------------------------------------			
/*			
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
			
*/	 		
*-------------------------------------------------------------------------------	


**# INIT ----------------------------

use "${swdFinal}/data4model_2021.dta", clear

**## Rural -----

keep if milieu == 2

local xvars "i.region  volail lapin porc petitrum grosrum frigo fer ordin tv car toilet eva_toi eva_eau eauboi_ss  eauboi_sp sol toit mur yadr oadr logzise" 
*TODO: bovins is not in data, there is big and small rumiants
*TODO: several assets not included, shouuld we include agicultural surface?

reg pcexp `xvars' [aweight = hhweight*hhsize]

**## Urban -----

keep if milieu == 1

local xvars "i.region  volail lapin porc petitrum grosrum frigo fer ordin tv car toilet eva_toi eva_eau eauboi_ss  eauboi_sp sol toit mur yadr oadr logzise" 
*TODO: bovins is not in data, there is big and small rumiants
*TODO: several assets not included, shouyld we include agicultural surface?

reg pcexp `xvars'