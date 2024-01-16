* ------------------------------------------------------------------
*    
*     This do-file creates the codebooks for all 2021 pmt senegal surveys
*     Creator: Gabriel N. Camargo-Toledo
*	  Created on: December 21 2023
*
*-------------------------------------------------------------------


**# Datain
**## Menage
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Datain\\Menage"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\datain_2021\\menage"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}


**## Auxiliaire
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Datain\\Auxiliaire"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\datain_2021\\Auxiliaire"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}

**## Commune
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Datain\\Commune"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\datain_2021\\Commune"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}

**# Dataout
**## Menage
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Dataout\\NSU"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\dataout_2021\\NSU"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}

**## Auxiliaire
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Dataout\\Prix"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\dataout_2021\\Prix"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}


**## Commune
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Dataout\\Temp"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\dataout_2021\\Temp"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}

**## no subfolder
cd "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - EHCVM\\EHCVM_2021\\Dataout"
global logOutput = "C:\\Users\\wb545737\\WBG\\Daniel Valderrama Gonzalez - 03_PMT\\data\\codebooks\\dataout_2021"

// Get a list of all .dta files in the directory
local files : dir "." files "*.dta"

foreach file of local files {
    // Load the data
    use "`file'", clear

    // Get the filename without the .dta extension
    local logfile = substr("`file'", 1, strlen("`file'") - 4)

    // Start the log
    log using "$logOutput\\`logfile'.log", replace

    // Run the codebook command
    codebook

    // Close the log
    log close
}


