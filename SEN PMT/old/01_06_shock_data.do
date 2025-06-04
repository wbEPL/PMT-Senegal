use "${swdDataraw}/Menage/s14b_me_sen_2021.dta", clear 

gen hhid=grappe*100+menage 

keep hhid s14bq01 s14bq02
recode s14bq02 (2 = 0) (1 = 1)
label define s14bq02 0 "No" 1 "Yes", replace

drop if s14bq01==.
 			 
**## Reshape so column is an asset -----
reshape wide s14bq02, i(hhid) j(s14bq01) 

mvencode s14bq02101-s14bq02122, mv(0) override

gen illness_accident = (s14bq02101>0)

gen death = (s14bq02102>0)

gen divorce = (s14bq02103>0)

egen flood_drought1=rowtotal(s14bq02104-s14bq02105)
gen flood_drought = (flood_drought1>0)

egen disease1=rowtotal(s14bq02107-s14bq02108)
gen disease = (disease1>0)

egen agriculture1=rowtotal(s14bq02109-s14bq02110)
gen agriculture = (agriculture1>0)

gen food_price = (s14bq02111>0)

gen theft = (s14bq02117>0)

egen conflict1=rowtotal(s14bq02118-s14bq02119)
gen conflict = (conflict1>0)

keep hhid illness_accident death divorce flood_drought agriculture food_price theft conflict

label var illness_accident "serious illness or accident of the hh member"
label var death "death of the hh member"
label var divorce "seperation, divorce"
label var flood_drought "flood drought"
label var agriculture "low price of agricultural outputs or high price of inputs"
label var food_price "high food price"
label var theft "theft"
label var conflict "conflict"

save "${swdTemp}/shock.dta", replace

