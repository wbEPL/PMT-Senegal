* ------------------------------------------------------------------
*	Authors: Gabriel N. Camargo-Toledo gcamargotoledo@worldbank.org
*			 Daniel Valderrama dvalderramagonza@worldbank.org
*	
*	Last edited: 12 January 2024
* 	Version 2.0 created by Daniel VAlderrama 
*	Reviewer: TBD
*	Last Reviewed: TBD
*                         
*-------------------------------------------------------------------
 
clear all
set more off
set maxvar 32000
set seed 10051990 
set sortseed 10051990 


* Define username
global suser = c(username)

*Gabriel create globals for folders
else if (inlist("${suser}","wb545737")) {
	//@Gabriel please update your paths following the logic I outlined below. There are three main folder that are not necessary together. 
		global gitrepo "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/scripts/scripts_gc/gitrepo" 
		global project "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/"
		
		global data_library = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - EHCVM/" 
		
	
}
*Daniel
else if (inlist("${suser}","wb419055")) {

	global gitrepo "C:\Users\wb419055\OneDrive - WBG\West Africa\Senegal\Senegal_tool\Projects\03_PMT\git_PMT-Senegal"
	global project "C:/Users/wb419055/OneDrive - WBG/West Africa/Senegal/Senegal_tool/Projects/03_PMT"
	
	global data_library  "C:/Users/wb419055/OneDrive - WBG/West Africa/Senegal/data/EHCVM" 
}

*folder from data library
global swdDataraw   "${data_library}/EHCVM_2021/Datain" 
global swdDatain	"${data_library}/EHCVM_2021/Dataout"
 
*folder from project 
global scripts 		"$gitrepo"
global swdTemp		"$project/data/temp"
global swdFinal		"$project/data/final"
global swdResults	"$project/results"

* Making sure fre gtools and egenmor packages are installed, if not install them
local commands = "fre gtools quantiles outreg2"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc!=0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

* Dofiles 

// Cleaning dataset on assets, dwelling characteristics and other 
	include "$scripts/01_00_createData.do.do"

// Running models 
	include "$scripts/02_00_estimate_models.do"



