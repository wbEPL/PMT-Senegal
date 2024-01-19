* ------------------------------------------------------------------
*    
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
		//The folder of scripts, which is linked to Github 
		//The folder of data_library which for data files that are not specific to the project (like a general survey for Senegal) but that will be used in the project. 
		//The folder of project 
	
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

