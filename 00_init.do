* ------------------------------------------------------------------
*    
*     This file contains the initialization to run the pipeline
*     processing the KAP-FD K-LSRH Data
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
	global swdDatain = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - EHCVM/EHCVM_2021/Dataout" 
	
	global swdDataraw = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - EHCVM/EHCVM_2021/Datain" 
	global swdResults = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/results"
	global swdTemp = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/data/temp"
	global swdFinal = "C:/Users/wb545737/WBG/Daniel Valderrama Gonzalez - 03_PMT/data/final"
}

else if (inlist("${suser}","wb419055")) {

	global gitrepo "C:/Users/wb419055\OneDrive - WBG/West Africa/Senegal/Senegal_tool/Projects/03_PMT/scripts/gitrepo"
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

* You need to install the follwoing programs
*ssc install fre




include "$scripts/01_createData.do"

