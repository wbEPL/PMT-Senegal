* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data on demographics and welfare to estimate Senegal PMT. 
*	It is called by 01_createData.do
*	The input files are: 
*		- Menage/s02_me_sen_2021.dta
*	The following data is created:
*		- household_livestock.dta
*	Open points that need to be addressed:
*		- I can't identify in the raw data who is hh head, how was lien created
*			in ehcvm_individu_SEN_2021
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 30 January 2024
* 	Version 2.0 created by Daniel Valderrama 
* 	Version 3.0 by Gabriel N. Camargo-Toledo
*	Reviewer: TBD
*	Last Reviewed: TBD
* ----------------------------------------------------------------------- */


********************************************************
**# Household demographics ---------------------------------------
********************************************************

use "${swdDatain}/ehcvm_welfare_SEN_2021.dta", clear 

apoverty pcexp [aw = hhweight*hhsize], varpl(zref)

gen dem_logsize = ln(hhsize)

ren halfa   dem_halfa
ren halfa2  dem_halfa2
ren hgender dem_hgender

recode hage (16/35=1 "<=30 yr old") (35/50=2 "age in (35-50)") (51/65=3 "age in (51-65)") (66/120=4 "age >65"), gen(dem_hage)

recode hmstat (2=1 "Marié(e) monogame ") (5=2 "Veuf(ve)") (3 4 =4 "Marié(e) polygame &  Union libre") (1 6 7 =3 "Other: Célibataire, Divorcé(e), Séparé(e)") , gen(dem_hmstat)

*hreligion 95% is musulman
rename hethnie dem_hethnie // mix the etnicities requires country knowledge 

recode heduc (1 2 =1 "Aucun/Maternelle") (3=2 "Primaire") (4 5 6 7=3 "Second. gl 1/ gl 2/ tech. 1/ tech. 2") (8 9 =4 " Postsecondaire/Superior") , gen(dem_heduc)

ren hhandig dem_hhandig
*hdiploma much more variance in educ reached than diploma, incentive about lying because do not have the documentation

recode hactiv7j (1 2 3 =1 " Occupe/ TF cherchant emploi or pas") (4 5 = 2 "Chomeur/ Inactif"), gen (dem_hactiv7j)

recode hactiv12m (1 2=1 " Occupe/ TF ") ( 3 = 2 " Non occupe"), gen (dem_hactiv12m)


replace hbranch=999 if hbranch==. | hactiv12m==3 | hbranch==34 // sectors 502 & 930 were not weel assigned to Manufacturing 
recode hbranch (1 =1 " Agriculture") (2=2 "Livestock, forestry and fishing") (3 4 5  502 930= 3 "Mining, Manufacturing, Electricity and  Construction") (6=4 "Retail and Wholesale") (7 8 9 10 11=5 "Rest of services (Transport, communication, education, health") (999=6 "Missing info"), gen(dem_branch)

recode hcsp (1 2  10 =1 " Cadre supérieur, Cadre moyen/agent de maîtrise, Patron") (3 4 5 =2 "Ouvrier, Manœuvre, aide ménagère") (9=3 "Travailleur pour compte propre")(6 7 8=4 " Stagiaire ou Apprenti,Travailleur Familial ") (missing =5 " Missing info"), gen (dem_hcsp)


foreach v in dem_hage dem_hmstat dem_heduc dem_hactiv7j dem_hactiv12m dem_branch  dem_hcsp {
	local vlab : variable label `v'
	
	local vlab= subinstr("`vlab'", "RECODE of", "",.)
	
	label var `v' "`vlab'"

}

label var dem_logsize "lof of household size"

keep hhid grappe menage vague hhweight hhsize pcexp zref region milieu dem_*

save "${swdTemp}/hhead_dta.dta", replace



*******************************************************
**# Literacy in french --------------------------------
*******************************************************

use grappe menage s01q00a s01q02 using  "${swdDataraw}/Menage/s01_me_sen_2021.dta", clear 

	merge 1:1 grappe menage s01q00a using "${swdDataraw}/Menage/s02_me_sen_2021.dta", nogen  keep(matched)
	gen hhid=grappe*100+menage 
	
	gen dem_alfa_french=s02q01__1==1 & s02q02__1==1
	keep if s01q02 == 1 /*Now is the hh head!*/
	keep hhid dem_alfa_french
	label var dem_alfa_french "read and write french"

save "${swdTemp}/french_temp.dta", replace


*******************************************************
**# dependency ratios ---------------------------------
*******************************************************

use "${swdDatain}/ehcvm_individu_SEN_2021.dta", clear

	* Generate a variable for oldage group
	gen oldgroup =  age < 64 if age!=.
	gen dem_working_age= age >=15 & age <= 64 
	gen young= age >15 if age!=.
	
	gen dem_oadr=oldgroup
	gen dem_yadr=young
	
	*Employed
	gen ocu=activ12m==1 if age>=15 & age<=65
	bysort hhid grappe menage: egen dem_emp_rate=mean(ocu)
	replace dem_emp_rate=0 if  dem_emp_rate==.
	
	*Gender
	gen adult_female=sexe==2 if age>=15 & age<=65
	bysort hhid grappe menage: egen dem_gender_rate=mean(adult_female)
	replace dem_gender_rate=0 if dem_gender_rate==. 
	
	*Adults 
	bysort hhid grappe menage: egen adults=total(dem_working_age)
	gen dem_logadults = ln(adults+1)
	
	
	*Prep data to merge at hh level 
	collapse (mean) dem_oadr dem_yadr dem_working_age dem_emp_rate dem_gender_rate dem_logadults (sd) sd1dem_logadults=dem_logadults sdgender_adults=dem_gender_rate, by(hhid)
	
	assert sd1dem_logadults<0.01 | sd1dem_logadults==.
	assert sdgender_adults<0.01  | sdgender_adults==.
	drop sdgender_adults sd1dem_logadults
	
	
	
	label var dem_oadr          "share of members <64"
	label var dem_yadr          "share of members >15"
	label var dem_working_age   "share of adult members (15-64)"
	label var dem_emp_rate      "share of employed adults (15-64)"
	label var dem_gender_rate   "share of female adults (15-64)"
	label var dem_logadults		"Log (adults +1)"
	
	
	
	
save "${swdTemp}/individual_temp.dta", replace
