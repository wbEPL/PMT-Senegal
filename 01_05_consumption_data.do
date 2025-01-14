use "${swdDataraw}/Menage/s07b_me_sen_2021.dta", clear 

gen hhid=grappe*100+menage 

keep hhid s07bq01 s07bq02
recode s07bq02 (2 = 0) (1 = 1)
label define s07bq02 0 "No" 1 "Yes", replace

drop if s07bq01==.
 			 
**## Reshape so column is an asset -----
reshape wide s07bq02, i(hhid) j(s07bq01) 

mvencode s07bq021-s07bq02180, mv(0) override

egen cereal1=rowtotal(s07bq021-s07bq0226)
gen cereal = (cereal1>0)

egen meat1=rowtotal(s07bq0227-s07bq0239)
gen meat = (meat1>0)

egen fish1=rowtotal(s07bq0240-s07bq0251)
gen fish = (fish1>0)

egen milk1=rowtotal(s07bq0252-s07bq0260)
gen milk = (milk1>0)

egen oil1=rowtotal(s07bq0261-s07bq0270)
gen oil = (oil1>0)

egen fruits1=rowtotal(s07bq0271-s07bq0287)
gen fruit = (fruits1>0)

egen vegetable1=rowtotal(s07bq0288-s07bq02108)
gen vegetable = (vegetable1>0)

egen legume1=rowtotal(s07bq02109-s07bq02133)
gen legume = (legume1>0)

egen sugar1=rowtotal(s07bq02134-s07bq02138)
gen sugar = (sugar1>0)

keep hhid cereal meat fish milk oil fruit vegetable legume sugar

label var cereal "consumed cereal"
label var meat "consumed meat"
label var fish "consumed fish"
label var milk "consumed milk"
label var oil "consumed oil"
label var fruit "consumed fruit"
label var vegetable "consumed vegetable"
label var legume "consumed legume"
label var sugar "consumed sugar"

save "${swdTemp}/consumption.dta", replace

