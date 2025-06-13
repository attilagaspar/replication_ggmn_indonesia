/* 

	this script merges PODES18 data to PODES14 and PODES11  on village identifier 
	conversion table downloaded from the Indonesian Statistical Office's homepage (BPS)


*/
* load podes data
* 2018 wave


use "${processed_data_dir}/podes2018mb.dta", clear
rename podes2018_id id2018_1

rename podes2018_R101N podes2018_name_prov
rename podes2018_R102N podes2018_name_dist
rename podes2018_R103N podes2018_name_subdist
rename podes2018_R104N podes2018_name_vill

tempfile p18
save `p18'

* 2014 wave
use "${processed_data_dir}/podes2014mb.dta", clear
rename podes2014_id idpodes14

rename podes2014_R101N podes2014_name_prov
rename podes2014_R102N podes2014_name_dist
rename podes2014_R103N podes2014_name_subdist
rename podes2014_R104N podes2014_name_vill


tempfile p14
save `p14'



* 2011 wave

use "${processed_data_dir}/podes2011mb.dta", clear


* create string village id
tostring podes2011_prop podes2011_kab podes2011_kec podes2011_desa, force replace

* district ID must be 2 digits long, subdistrict and village id-s are 3 digits long
replace podes2011_kab = "0" + podes2011_kab if length(podes2011_kab)<2
replace podes2011_kec = "0" + podes2011_kec if length(podes2011_kec)<3
replace podes2011_kec = "0" + podes2011_kec if length(podes2011_kec)<3
replace podes2011_desa = "0" + podes2011_desa if length(podes2011_desa)<3
replace podes2011_desa = "0" + podes2011_desa if length(podes2011_desa)<3
replace podes2011_desa = "0" + podes2011_desa if length(podes2011_desa)<3
* creaate combined 10 digit id
gen idpodes11 = podes2011_prop + podes2011_kab + podes2011_kec + podes2011_desa

tempfile p11
save `p11'


* 2008 wave
use "${processed_data_dir}/podes2008mb.dta", clear

tostring  podes2008_prop podes2008_kab podes2008_kec podes2008_desa , force replace
replace podes2008_kab = "0" + podes2008_kab if length(podes2008_kab)<2
replace podes2008_kec = "0" + podes2008_kec if length(podes2008_kec)<3
replace podes2008_kec = "0" + podes2008_kec if length(podes2008_kec)<3
replace podes2008_desa = "0" + podes2008_desa if length(podes2008_desa)<3
replace podes2008_desa = "0" + podes2008_desa if length(podes2008_desa)<3
replace podes2008_desa = "0" + podes2008_desa if length(podes2008_desa)<3

gen idpodes08 =  podes2008_prop + podes2008_kab + podes2008_kec + podes2008_desa 
	drop if podes2008_desa=="000"
	drop if podes2008_kec=="000"
	drop if podes2008_kab=="00"
tempfile p08
save `p08' 
 
* load conversion table
use "${processed_data_dir}/convtable_1998_2015.dta", clear
duplicates drop id2018_1, force 

merge 1:1 id2018 using `p18', gen(merge_podes18)

merge m:1 idpodes14 using `p14', gen(merge_podes14)

merge m:1 idpodes11 using `p11', gen(merge_podes11)

merge m:1 idpodes08 using `p08', gen(merge_podes08)
* keep villages that we observe every year  

drop if id2018_1 ==""|idpodes14==""

save "${processed_data_dir}/podes_panel08_18", replace
 
