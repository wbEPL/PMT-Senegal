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

else {
	di as error "Configure work environment in init.do before running the code."
	error 1
}


