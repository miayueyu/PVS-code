* PVS Main file for data quality checks
* September 2022
* N. Kapoor 
* This is based on the data and files being in the internal file, file paths will change 


************************************************
* Drop all macros
macro drop _all

*Project settings
*Individual users 
global user "/Users/nek096/Dropbox (Harvard University)"

* Project paths 
* Path to internal .do files folder (will change)
global pvs_dq "$user/SPH-Kruk Team/QuEST Network/Core Research/People's Voice Survey/Internal HSPH/Data Quality"

* Output (will change)
global output "$pvs_dq/Output"

* Currently using data in internal folder (will change)
global data "$pvs_dq/Data"

************************************************
* Required packages 
* IPA's Stata Package for HFCs
net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")
ipacheck update

************************************************
* Run Globals 
run "$pvs_dq/1_globals_pvs.do"

* Initial data cleaning (prepping for HFC)
run "$pvs_dq/$country/2_clean01_pvs.do"

* High frequency checks 
run "$pvs_dq/3_hfc_pvs.do"

* Descriptive Analysis 
run "$pvs_dq/4_an01_pvs.do"
