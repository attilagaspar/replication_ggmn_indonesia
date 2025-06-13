


/*

	load crosswalk


*/

import excel "${raw_data_dir}/conversion_tables/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
drop if mod(bps_2014,100)==0
duplicates drop bps_1998, force
keep bps_1996 bps_1998 name_1996 name_1998
tempfile cw
save `cw'

/* 
	create 1998 string id in 2000 data
*/

use "${processed_data_dir}/podes2000mb.dta", clear

replace podes2000_drh98=2 if podes2000_drh98==.

* miscoded variables?
replace podes2000_prop98=podes2000_prop if podes2000_prop98<10|podes2000_prop98==. // miscoded variables?
replace podes2000_kab98=podes2000_kab99 if podes2000_kab98==0&podes2000_kab99!=0
replace podes2000_kab98=podes2000_kab if podes2000_kab98==0&podes2000_kab!=0

* merge 1996 district equaivalent

gen bps_1998 = podes2000_prop98*100+podes2000_kab98

merge m:1 bps_1998 using `cw', gen(merge_crosswalk98)

replace bps_1996 = bps_1998 if merge_crosswalk==1 // we matched all districts from the using data, so our best guess is this

foreach v of varlist  bps_1996 podes2000_kec98 podes2000_desa98 podes2000_drh98 ///
		podes2000_prop podes2000_kab podes2000_kec podes2000_desa podes2000_drh {

	tostring `v', force replace
	

}

*correct lenghts: kabupaten code is either one or two digits
foreach v of varlist   podes2000_kab {

	replace `v'="0"+`v' if length(`v')==1

}

*kecamatan and desa codes are either one, two, or three digits
foreach v of varlist  podes2000_kec98 podes2000_desa98 podes2000_kec podes2000_desa {

	replace `v'="0"+`v' if length(`v')==2
	replace `v'="00"+`v' if length(`v')==1

}

tostring bps_1996 , force replace

gen fullcode =  bps_1996 + podes2000_kec98 + podes2000_desa98 + podes2000_drh98 // this is not a unique identifier
gen fullcode2000 = podes2000_prop + podes2000_kab + podes2000_kec + podes2000_desa+ podes2000_drh // this is a unique identifier

tempfile p2000
save `p2000'


use "${processed_data_dir}/podes1996mb.dta", clear

drop if podes1996_prop==54 // East-Timor still occupied by Indonesia in 1996, not in 2000

foreach v of varlist podes1996_prop podes1996_kab podes1996_kec podes1996_desa podes1996_drh {

	tostring `v', force replace
	

}

 
*correct lenghts: kabupaten code is either one or two digits
foreach v of varlist  podes1996_kab {

	replace `v'="0"+`v' if length(`v')==1

}

*kecamatan and desa codes are either one, two, or three digits
foreach v of varlist   podes1996_kec podes1996_desa {

	replace `v'="0"+`v' if length(`v')==2
	replace `v'="00"+`v' if length(`v')==1

}


gen fullcode =  podes1996_prop + podes1996_kab + podes1996_kec + podes1996_desa + podes1996_drh // this is not a unique identifier




merge 1:m fullcode using `p2000', gen(m2000)


* resulting match is 94.5%
* we should rather keep 2000 data

drop if m2000==1 

gen id2000 = podes2000_prop + podes2000_kab + podes2000_kec + podes2000_desa



/*

Banten, Bangka Belitung, Gorontalo provinces created in 1999
*/

*/
replace  id2000=subinstr(id2000,"3200","3600",1) if substr(id2000,1,4)=="3200"
replace  id2000=subinstr(id2000,"3202","3602",1) if substr(id2000,1,4)=="3202"
replace  id2000=subinstr(id2000,"3201","3601",1) if substr(id2000,1,4)=="3201"
replace  id2000=subinstr(id2000,"3220","3604",1) if substr(id2000,1,4)=="3220"
replace  id2000=subinstr(id2000,"3219","3603",1) if substr(id2000,1,4)=="3219"
replace  id2000=subinstr(id2000,"3220","3672",1) if substr(id2000,1,4)=="3220"
replace  id2000=subinstr(id2000,"3275","3671",1) if substr(id2000,1,4)=="3275"
replace  id2000=subinstr(id2000,"3220","3604",1) if substr(id2000,1,4)=="3220"
replace  id2000=subinstr(id2000,"3219","3603",1) if substr(id2000,1,4)=="3219"
replace  id2000=subinstr(id2000,"1600","1900",1) if substr(id2000,1,4)=="1600"
replace  id2000=subinstr(id2000,"1607","1901",1) if substr(id2000,1,4)=="1607"
replace  id2000=subinstr(id2000,"1608","1902",1) if substr(id2000,1,4)=="1608"
replace  id2000=subinstr(id2000,"1672","1971",1) if substr(id2000,1,4)=="1672"
replace  id2000=subinstr(id2000,"1607","1901",1) if substr(id2000,1,4)=="1607"
replace  id2000=subinstr(id2000,"1608","1902",1) if substr(id2000,1,4)=="1608"
replace  id2000=subinstr(id2000,"1607","1901",1) if substr(id2000,1,4)=="1607"
replace  id2000=subinstr(id2000,"1607","1901",1) if substr(id2000,1,4)=="1607"
replace  id2000=subinstr(id2000,"7100","7500",1) if substr(id2000,1,4)=="7100"
replace  id2000=subinstr(id2000,"7101","7501",1) if substr(id2000,1,4)=="7101"
replace  id2000=subinstr(id2000,"7101","7502",1) if substr(id2000,1,4)=="7101"
replace  id2000=subinstr(id2000,"7171","7571",1) if substr(id2000,1,4)=="7171"
replace  id2000=subinstr(id2000,"7101","7502",1) if substr(id2000,1,4)=="7101"
replace  id2000=subinstr(id2000,"7101","7501",1) if substr(id2000,1,4)=="7101"
replace  id2000=subinstr(id2000,"7101","7502",1) if substr(id2000,1,4)=="7101"

* because of this, internal numbering of west java changes a lot
gen id2000b=""
replace  id2000b=subinstr(id2000,"3206","3204",1) if substr(id2000,1,4)=="3206"
replace  id2000b=subinstr(id2000,"3218","3216",1) if substr(id2000,1,4)=="3218"
replace  id2000b=subinstr(id2000,"3203","3201",1) if substr(id2000,1,4)=="3203"
replace  id2000b=subinstr(id2000,"3209","3207",1) if substr(id2000,1,4)=="3209"
replace  id2000b=subinstr(id2000,"3205","3203",1) if substr(id2000,1,4)=="3205"
replace  id2000b=subinstr(id2000,"3211","3209",1) if substr(id2000,1,4)=="3211"
replace  id2000b=subinstr(id2000,"3207","3205",1) if substr(id2000,1,4)=="3207"
replace  id2000b=subinstr(id2000,"3214","3212",1) if substr(id2000,1,4)=="3214"
replace  id2000b=subinstr(id2000,"3217","3215",1) if substr(id2000,1,4)=="3217"
replace  id2000b=subinstr(id2000,"3210","3208",1) if substr(id2000,1,4)=="3210"
replace  id2000b=subinstr(id2000,"3212","3210",1) if substr(id2000,1,4)=="3212"
replace  id2000b=subinstr(id2000,"3216","3214",1) if substr(id2000,1,4)=="3216"
replace  id2000b=subinstr(id2000,"3215","3213",1) if substr(id2000,1,4)=="3215"
replace  id2000b=subinstr(id2000,"3204","3202",1) if substr(id2000,1,4)=="3204"
replace  id2000b=subinstr(id2000,"3213","3211",1) if substr(id2000,1,4)=="3213"
replace  id2000b=subinstr(id2000,"3208","3206",1) if substr(id2000,1,4)=="3208"
replace  id2000b=subinstr(id2000,"3273","3273",1) if substr(id2000,1,4)=="3273"
replace  id2000b=subinstr(id2000,"3276","3275",1) if substr(id2000,1,4)=="3276"
replace  id2000b=subinstr(id2000,"3271","3271",1) if substr(id2000,1,4)=="3271"
replace  id2000b=subinstr(id2000,"3274","3274",1) if substr(id2000,1,4)=="3274"
replace  id2000b=subinstr(id2000,"3203","3276",1) if substr(id2000,1,4)=="3203"
replace  id2000b=subinstr(id2000,"3272","3272",1) if substr(id2000,1,4)=="3272"
replace  id2000b=subinstr(id2000,"3208","3206",1) if substr(id2000,1,4)=="3208"
replace  id2000b=subinstr(id2000,"3206","3204",1) if substr(id2000,1,4)=="3206"
replace  id2000b=subinstr(id2000,"3209","3207",1) if substr(id2000,1,4)=="3209"
replace  id2000b=subinstr(id2000,"3206","3204",1) if substr(id2000,1,4)=="3206"
replace  id2000b=subinstr(id2000,"3209","3209",1) if substr(id2000,1,4)=="3209"
* also sulawesi is internally reorganized
replace  id2000=subinstr(id2000,"7102","7101",1) if substr(id2000,1,4)=="7102"
replace  id2000=subinstr(id2000,"7103","7102",1) if substr(id2000,1,4)=="7103"
replace  id2000=subinstr(id2000,"7104","7103",1) if substr(id2000,1,4)=="7104"
replace  id2000=subinstr(id2000,"7173","7172",1) if substr(id2000,1,4)=="7173"
replace  id2000=subinstr(id2000,"7172","7171",1) if substr(id2000,1,4)=="7172"
replace  id2000=subinstr(id2000,"7104","7103",1) if substr(id2000,1,4)=="7104"
replace  id2000=subinstr(id2000,"7103","7102",1) if substr(id2000,1,4)=="7103"
replace  id2000=subinstr(id2000,"7103","7102",1) if substr(id2000,1,4)=="7103"
replace  id2000=subinstr(id2000,"7103","7102",1) if substr(id2000,1,4)=="7103"
replace  id2000=subinstr(id2000,"7102","7101",1) if substr(id2000,1,4)=="7102"
replace  id2000=subinstr(id2000,"7103","7102",1) if substr(id2000,1,4)=="7103"
replace  id2000=subinstr(id2000,"7102","7101",1) if substr(id2000,1,4)=="7102"
replace  id2000=subinstr(id2000,"7104","7103",1) if substr(id2000,1,4)=="7104"
replace  id2000=subinstr(id2000,"7102","7101",1) if substr(id2000,1,4)=="7102"
replace  id2000=subinstr(id2000,"7102","7101",1) if substr(id2000,1,4)=="7102"
replace  id2000=subinstr(id2000,"7200","7200",1) if substr(id2000,1,4)=="7200"
replace  id2000=subinstr(id2000,"7201","7202",1) if substr(id2000,1,4)=="7201"
replace  id2000=subinstr(id2000,"7201","7201",1) if substr(id2000,1,4)=="7201"
replace  id2000=subinstr(id2000,"7204","7207",1) if substr(id2000,1,4)=="7204"
replace  id2000=subinstr(id2000,"7203","7205",1) if substr(id2000,1,4)=="7203"
replace  id2000=subinstr(id2000,"7202","7203",1) if substr(id2000,1,4)=="7202"
replace  id2000=subinstr(id2000,"7202","7204",1) if substr(id2000,1,4)=="7202"
replace  id2000=subinstr(id2000,"7204","7206",1) if substr(id2000,1,4)=="7204"
replace  id2000=subinstr(id2000,"7271","7271",1) if substr(id2000,1,4)=="7271"
replace  id2000=subinstr(id2000,"7203","7205",1) if substr(id2000,1,4)=="7203"
replace  id2000=subinstr(id2000,"7202","7204",1) if substr(id2000,1,4)=="7202"
replace  id2000=subinstr(id2000,"7203","7205",1) if substr(id2000,1,4)=="7203"
replace  id2000=subinstr(id2000,"7201","7201",1) if substr(id2000,1,4)=="7201"
replace  id2000=subinstr(id2000,"7202","7203",1) if substr(id2000,1,4)=="7202"
replace  id2000=subinstr(id2000,"7300","7300",1) if substr(id2000,1,4)=="7300"

replace id2000 = id2000b if id2000b!=""
drop id2000b

duplicates drop id2000, force // (454 obs)

rename id2000 id2000

preserve
	use ${processed_data_dir}/convtable_1998_2013.dta, clear 
	duplicates drop  id2005, force
	keep id2000 id2005 idpodes idpodes08 id2002 id2003
	tempfile ids
	save `ids'
restore

merge 1:m id2000 using `ids', gen(merge_village_masterfile2000)

drop if id2005==""


*********** 2003 wave

preserve
	use "${processed_data_dir}/podes2003mb.dta", clear


	*podes2003_prop podes2003_kab podes2003_kec podes2003_desa

	foreach v of varlist  podes2003_prop podes2003_kab podes2003_kec podes2003_desa ///
	podes2003_prop2002 podes2003_kab2002 podes2003_kec2002 podes2003_desa2002 podes2003_drh2002 {

		tostring `v', force replace
		

	}

	*correct lenghts: kabupaten code is either one or two digits
	foreach v of varlist   podes2003_kab podes2003_kab2002 {

		replace `v'="0"+`v' if length(`v')==1

	}

	*kecamatan and desa codes are either one, two, or three digits
	foreach v of varlist  podes2003_kec podes2003_desa podes2003_kec2002 podes2003_desa2002 {

		replace `v'="0"+`v' if length(`v')==2
		replace `v'="00"+`v' if length(`v')==1

	}

	gen id2002 =podes2003_prop+podes2003_kab+podes2003_kec+podes2003_desa // unique!

	tempfile podes2003 
	save `podes2003'

restore

* 2005 wave 
preserve
	use "${processed_data_dir}/podes2005mb.dta", clear
	tostring podes2005_prop podes2005_kab podes2005_kec podes2005_desa, force replace 
	replace podes2005_kab = "0" + podes2005_kab if length(podes2005_kab)==1
	replace podes2005_kec = "0" + podes2005_kec if length(podes2005_kec)==2
	replace podes2005_kec = "00" + podes2005_kec if length(podes2005_kec)==1
	replace podes2005_desa = "0" + podes2005_desa if length(podes2005_desa)==2
	replace podes2005_desa = "00" + podes2005_desa if length(podes2005_desa)==1
	gen id2005 = 	podes2005_prop + podes2005_kab + podes2005_kec + podes2005_desa
	
	drop if podes2005_desa=="000"
	drop if podes2005_kec=="000"
	drop if podes2005_kab=="00"
	
	tempfile podes2005 
	save `podes2005'
restore



* 2008 wave
preserve
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
restore

merge m:1 id2002 using `podes2003', gen(merge_podes2003)
drop if merge_podes2003==2

* we want the data to be unique for the last wave
merge 1:1 id2005 using `podes2005', gen(merge_podes2005)

replace idpodes = idpodes08 if idpodes==""
drop idpodes08 
rename idpodes idpodes08 

merge m:1  idpodes08 using `p08', gen(merge_podes2008) 

* keep observations we see both in 2000 and 2005
keep if id2000!=""&id2005!=""


save ${processed_data_dir}/podes_panel96_05.dta, replace
