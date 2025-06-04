* ------------------------------------------------------------------------------			
/*			
*	This .do file creates the data on dwelling to estimate Senegal PMT. 
*	It is called by 01_createData.do
*	The input files are: 
*		- Menage/s11_me_sen_2021.dta
*	The following data is created:
*		- dwelling_temp.dta
*	Open points that need to be addressed:
*		- Floor and wall material is not as different materials but already 
*			grouped for definitive materials yes or no
*		- Which water source should be used in model? dry or rainy season?
*	Author: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*	Last edited: 26 January 2024
* 	Version 2.0 created by Daniel Valderrama 
* 	Version 3.0 by Gabriel N. Camargo-Toledo
*	Reviewer: TBD
*	Last Reviewed: TBD
* ----------------------------------------------------------------------- */

use "${swdDataraw}/Menage/s11_me_sen_2021.dta", clear
gen hhid=grappe*100+menage 

**# type of housing --------------------
	fre s11q01
	recode s11q01  (3=1 "Low house (Maison Basse)") ///
				   (2=2 "Single-story house(Maison à Etage)") ///
				   (4 5=3 "Shack/Hut (Baraque/Case)") ///
				   (1=4 "Apartment (Appartement dans un immeuble)"), ///
		gen (c_typehousing)
	label var c_typehousing "Type of housing (rec of s11q01)"
	tab s11q01 c_typehousing
	
**# number of rooms ---------------------
	fre s11q02
	recode s11q02 (7/max = 7), gen (c_numberofrooms_c)
	label var c_numberofrooms "Number of rooms censored at 11 (rec of s11q02)"
	tab s11q02 c_numberofrooms
	
	
	gen c_rooms_pc= s11q02 
	label var c_rooms_pc "Number of rooms pc (rec of s11q02)" // since hhsize is not here it will be added
	
**# Housing ocupation status -------------
	fre s11q04
	recode s11q04 (1 3=1 "Owner or co-owner with title") ///
				   (2 4=2 "Owner or co-owner without title") ///
				   (5=3 "Renter") ///
				   (6 7 8=4 "Other (including lodgment for employment or free)"), ///
		gen (c_housingocup)
	label var c_housingocup "Ocupation status (rec of s11q04)"
	tab s11q04 c_housingocup
	
**# Business in dwelling ---------------
	fre s11q17
	recode s11q17 (1=1 "Yes") ///
					(2=0 "No"), ///
		gen(c_businessindwe)
	label var c_businessindwe "Own business in dwelling (s11q17)"
	tab s11q17 c_businessindwe
	
**# walls ----------------
	fre s11q18
	recode s11q18 ///
		(1 2 =1 "Cement and bricks (ciment, beton , pierres, briques cuites)") ///
		(4 = 2 "Clay Soil (Banco amélioré/ semi-dur)") ///
		(3 5 7 = 3 "Straw, Recycled (Paille, planches, toles)")  ///
		(6 8 9 = 4 "Other (stones, not protected)"),  ///
		gen (c_walls)
	label var c_walls "Wall material (rec of s11q18)"
	
**# roof ----------------
	fre s11q19
	recode s11q19 ///
		(1 = 1 "Cement slab (Dalle en ciment)") ///
		(2 = 2 "Tiles (Tuile)") ///
		(3 = 3 "Sheet metal (Toles)")  ///
		(4 = 4 "Straw (Paille)") ///
		(5 6 7 8 = 5 "Other (Banco, chaume, nattes, autre)"),  ///
		gen (c_roof)
	label var c_roof "Roof material (rec of s11q19)"
	tab s11q19 c_roof

**# floor ------------------------------
	fre s11q20
	recode s11q20 (2=1 "Cement (Ciment)") ///
				   (1=2 "Tiles (Carreux)") ///
				   (3=3 "Clay soil and sand (Terre battue/Sable)") ///
				   (4 5 =4  "Other (Bouse d'animaux)"), ///
		gen (c_floor)
	label var c_floor "Floor material (rec of s11q20)"
	

**# connected to water ------------------------------
	fre s11q21
	recode s11q21 (1=1 "Yes") ///
					(2=0 "No"), ///
		gen(c_connectowater)
	label var c_connectowater "Connected to water network (s11q21)"
	tab s11q21 c_connectowater
	
**# Water source during dry season ----------------
	fre s11q26a
	recode s11q26a ///
		(1 2 =1 "Court or dwelling faucet (Robinet ... loge, cour, voisin)") ///
		(3 4 = 2 "Pub Faucet (voisin and public)")  ///
		(7 8 = 3 "Protected well (Puits couvert)")  ///
		(6 5 = 4 "Unprotected well (Puits ouvert)") ///
		(9 10 = 5 "Drilling (Forage)") ///
		(14 16 17 = 6 "Mineral water (schet, bouteille, vendeur)") ///
		(11 12 13 = 7 "Fluvial, source developed (Spring)") ///
		(18= 8 "Other"), ///
	gen (c_water_dry)
	label var c_water_dry "Water source dry season (rec of s11q26a)"
	
	recode s11q26a ///
		(1 2 14 16 17 = 1 "Court, dwelling faucet Mineral water (schet, bouteille, vendeur)") ///
		(3 4 = 2 "Pub Faucet (voisin and public)")  ///
		(5 6 7 8 = 3 "Protected/Unprotected well (Puits couvert/ouvert)")  ///
		(9 10 11 12 13 18 = 4 "Drilling (Forage), Fluvial, source developed (Spring)"), ///
		gen (s_c_water_dry)
		
	label var s_c_water_dry "Water source dry season simplified  (rec of s11q26a)"
	
**# Water source during rainy season ----------------
	fre s11q26b
	recode s11q26b ///
		(1 2 =1  "Court or dwelling faucet (Robinet ... loge, cour, voisin)") ///
		(3 4 = 2 "Pub Faucet (voisin and public)")  ///
		(7 8 = 3 "Protected well (Puits couvert)")  ///
		(6 5 = 4 "Unprotected well (Puits ouvert)") ///
		(9 10 = 5 "Drilling (Forage)") ///
		(14 16 17 = 6 "Mineral water (schet, bouteille, vendeur)") ///
		(11 12 13 = 7 "Fluvial, source developed (Spring)") ///
		(18= 8 "Other"), ///
	gen (c_water_rainy)
	label var c_water_rainy "Water source rainy season (rec of s11q26b)"
	
	
	recode s11q26b ///
		(1 2 14 16 17=1 "Court, dwelling faucet (Robinet ... loge, cour, voisin), Mineral water (schet, bouteille, vendeur)") ///
		(3 4 = 2 "Pub Faucet (voisin and public)")  ///
		(6 5 7 8 = 3 "Protected/Unprotected well (Puits couvert/ouvert)")  ///
		(9 10 11 12 13 18 = 4 "Drilling (Forage), Fluvial, source developed (Spring)"), ///
		gen (s_c_water_rainy)
	label var s_c_water_rainy "Water source rainy season simplified (rec of s11q26b)"
	
	
	
**# connected to electricity -----------------
	fre s11q33
	recode s11q33 (1=1 "Yes, to the network") ///
				  (2=2 "Yes to neighbor") ///
				  (3=3 "Directly connected to pole") ///
				  (4=4 "Not connected"), ///
		gen(c_connectoelec)
	label var c_connectoelec "Connected to electricity (s11q33)"
	tab s11q33 c_connectoelec
	
	recode s11q33 (1=1 "Yes, to network") ///
				  (2 3=2 "Yes to neighbor, pole or other") ///
				  (4=3 "Not connected"), ///
		gen(s_c_connectoelec)
		
	label var s_c_connectoelec "Connected to electricity simplified  (s11q33)"
	tab s11q33 s_c_connectoelec
	
**# lighting -------------------------------
	fre s11q37
	recode 	s11q37 ///
		(1 2  =1  "Network and generator (Electricité réseau)") ///
		(3 	  = 2 "Solar (solaire)")  ///
		(4    = 3 "Petrol lamp (Lampe petrol)")  ///
		(5    = 4 "Rechargeable lamp(pile solaire)") ///
		(6    = 5 "Wood others (Paraffine, bois, planche)") ///
		(7    = 6 "Other") ///
		(missing =7 "Mising"), ///
	gen (c_lighting)
	label var c_lighting "lighting (rec of s11q37)"
	
	recode 	s11q37 ///
		(1 2  =1  "Network and generator (Electricité réseau)") ///
		(3 	  = 2 "Solar (solaire)")  ///
		(5    = 3 "Rechargeable lamp(pile solaire)") ///
		(4 6 7= 4 "Petrol lamp, Wood, Other (Lampe petrol, Paraffine, bois, planche)"),  ///
	gen (s_c_lighting)
	label var s_c_lighting "lighting simplified (rec of s11q37)"
	
	
	
	
	
**# landline ---------------------------
	fre s11q42
	recode s11q42 (1=1 "Yes") ///
					(2=0 "No"), ///
		gen(c_landline)
	label var c_landline "Landline (s11q42)"
	
**# connected to internet --------------
	fre s11q45
	recode s11q45 (1=1 "Yes") ///
					(2=0 "No"), ///
		gen(c_connectedtoint)
	label var c_connectedtoint "Connected to internet (s11q45)"
	
**# internet type	 --------
	fre s11q48
	recode s11q48 (1=1 "Modem") ///
				  (2=2 "ADSL") ///
				  (3=3 "Fiber optic (broadband)") ///
				  (4=4 "Satellite") ///
				  (5=5 "Mobile access") ///
				  (.=6 "No connection") , ///
		gen(c_internettype)
	label var c_internettype "Internet type (s11q45+s11q48)"

**# connected to cable satellite or dtt tv --------------
	fre s11q49
	recode s11q49 (1=1 "Yes") ///
					(2=0 "No"), ///
		gen(c_connectedtotv)
	label var c_connectedtotv "Connected to cable, satellite or dtt TV (s11q49)"
	
**# First and second choice of fuel for kitchen--------------
	fre s11q52__1 s11q52__2 s11q52__3 s11q52__4 s11q52__5 s11q52__6 s11q52__7 s11q52__8
	gen c_fuelfirst = .
	*gen c_fuelsecond = .

	forvalues i = 1/8 {
		replace c_fuelfirst = `i' if s11q52__`i' == 1
		*replace c_fuelsecond = `i' if s11q52__`i' == 2
	}

	label define fuel 1 "Collected wood" 2 "Bought wood" 3 "Charcoal" 4 "Gas" 5 "Electricity" 6 "Oil" 7 "Animal waste" 8 "Other"
	label val c_fuelfirst fuel
	*label val c_fuelsecond fuel
	label var c_fuelfirst "First choice of fuel for kitchen (s11q52__*)"
	*label var c_fuelsecond "Second choice of fuel for kitchen (s11q52__*)"

	tab c_fuelfirst s11q52__1 
	*tab c_fuelsecond s11q52__1
	*Second fuel source is misisng for 48% of sample, so only recode and use c_fuelfirst
	
**## Recode first fuel choice ----
	fre c_fuelfirst
	recode c_fuelfirst (4=1 "Gas") (1 2 =2 "Wood") (3=3 "Charcoal") (5 6 7 8 = 5 "Other/Electricity/Oil/Animal waste"), ///
		gen(c_fuelfirst_r)
	label var c_fuelfirst_r "First fuel source (rec of c_fuelfirst)"
	fre c_fuelfirst_r
	
**# Garbage disposal	 --------
	fre s11q53
	recode s11q53 (1=2 "Public dumpsite") ///
				  (2=1 "Collection") ///
				  (3 4 5=3 "Burned by household, Informal dumpsite, Other/burried by household"), ///
			gen(c_garbage)
	label var c_garbage "Garbage disposal (rec of s11q53)"

**# toilet -----------------------------
/* 	fre s11q54
	recode 	s11q54 ///
		(11 =1  		"In nauture (Aucune toilette (dans la nature)") ///
		(1 2 3 4 = 2  	"W.C. connected")  ///
		(6 8 = 3 		"Covered latrines (ECOSAN,: dalles, couvertes)")  ///
		(7 = 4 			"Uncovered latrines (SANPLAT,: dalles, non couvertes)") ///
		(5 = 5 			"Improved ventilated latrine (VIP: dalles, ventillees)") ///
		(9 10 12 = 6 	"Other"), ///
	gen (c_toilet_rur)
	label var c_toilet_rur "Toilet rural  (rec of s11q54)"
*/	
	recode 	s11q54 ///
		(1 2 3 4 = 1  	"W.C. connected")  ///
		(6  8 = 2 		"Covered latrines (ECOSAN: dalles, couvertes couvertes)")  ///
		(5 = 3 			"Improved ventilated latrine (VIP: dalles, ventillees)") ///
		(7  = 4 		"Uncovered latrines (SANPLAT: dalles, non couvertes)")  ///
		(9 10 11 12 = 5 "Other:Fosse rudimentaire, publiques, dans la nature, Autre)"), ///
	gen (c_toilet)
	label var c_toilet "Toilet  (rec of s11q54)"
	

	
	
	recode 	s11q54 ///
		(1 2 3 4 = 1  	"W.C. connected")  ///
		(6 7 8 = 2 		"Covered latrines (ECOSAN,SANPLAT: dalles, couvertes & non couvertes)")  ///
		(5 = 3 			"Improved ventilated latrine (VIP: dalles, ventillees)") ///
		(9 10 11 12 = 4 "Other and nauture (Aucune toilette)"), ///
	gen (c_s_toilet_urb_rur)
	label var c_s_toilet_urb_rur "Toilet urb & rur simplified (rec of s11q54)"
	
	
	
**# waste disposal -----------------------------
	fre s11q57
	recode 	s11q57 ///
		(1 = 1  "Sewer") ///
		(2 3= 2 "Septic or Watertight tank")  ///
		(4 = 3 "Simple pit") ///
		(5 6 7 . = 4 "Compost, Street/Yard/Gutter/Nature, Other"), /// missing data if households that go to public restroom or nature. I test using a univariate regression to group the coefficients
		///
	gen (c_waste)
	label var c_waste "Waste disposal (s11q57)"

*----## storing -------

	keep hhid grappe menage vague c_* 
	save "${swdTemp}/dwelling_temp.dta", replace
