/*


	this script creates village ID conversion tables from 1998 to 2013
	from official masterfiles and merges 2010 census data to it.


*/

clear



foreach s in "11_1998_2013_1" ///
	"12_1998_2013_1" ///
	"13_2005_2013_1" ///
	"14_1998_2013_1" ///
	"15_1998_2013_1" ///
	"16_1998_2013_1" ///
	"17_1998_2013_1" ///
	"18_1998_2013_1" ///
	"19_1998_2013_1" ///
	"21_1998_2013_1" ///
	"32_1998_2013_1" ///
	"33_1998_2013_1" ///
	"34_1998_2013_1" ///
	"35_1998_2013_1" ///
	"36_1998_2013_1" ///
	"51_1998_2013_1" ///
	"52_1998_2013_1" ///
	"53_1998_2013_1" ///
	"61_1998_2013_1" ///
	"62_1998_2013_1" ///
	"63_1998_2013_1" ///
	"64_1998_2013_1" ///
	"65_1998_2013_1" ///
	"71_1998_2013_1" ///
	"72_1998_2013_1" ///
	"73_1998_2013_1"  ///
	"74_1998_2013_1" ///
	"75_1998_2013_1"  ///
	"76_1998_2013_1"  ///
	"81_1998_2013_1"  ///
	"82_1998_2013_1"  ///
	"91_1998_2013_1" ///
	"94_1998_2013_1" ///
	{
	
	
	disp "opening `s'"
	import delimited  "${raw_data_dir}/conversion_tables/98-2013/`s'.csv"  ,encoding(utf8) clear  stringcols(_all)
	rename *c* *  // misnamed variables (length of variable included)
	tempfile file`s'
	save `file`s''
	
	
}

clear

foreach s in "11_1998_2013_1" ///
	"12_1998_2013_1" ///
	"13_2005_2013_1" ///
	"14_1998_2013_1" ///
	"15_1998_2013_1" ///
	"16_1998_2013_1" ///
	"17_1998_2013_1" ///
	"18_1998_2013_1" ///
	"19_1998_2013_1" ///
	"21_1998_2013_1" ///
	"32_1998_2013_1" ///
	"33_1998_2013_1" ///
	"34_1998_2013_1" ///
	"35_1998_2013_1" ///
	"36_1998_2013_1" ///
	"51_1998_2013_1" ///
	"52_1998_2013_1" ///
	"53_1998_2013_1" ///
	"61_1998_2013_1" ///
	"62_1998_2013_1" ///
	"63_1998_2013_1" ///
	"64_1998_2013_1" ///
	"65_1998_2013_1" ///
	"71_1998_2013_1" ///
	"72_1998_2013_1" ///
	"73_1998_2013_1" ///
	"74_1998_2013_1" ///
	"75_1998_2013_1"  ///
	"76_1998_2013_1"  ///
	"81_1998_2013_1"  ///
	"82_1998_2013_1"  ///
	"91_1998_2013_1" ///
	"94_1998_2013_1" ///
	{
	disp "appending `s'"
	append using `file`s''
	
	
}

gen iddesa10 = id_sp2010
replace iddesa10 = idsp2010 if iddesa10==""
replace iddesa10 = id2010_2 if iddesa10==""

drop if id2013==""&iddesa10==""  // these are empty lines in the table
rename id2013 id2013


* conversion table for 2000s cycle
save "${processed_data_dir}/convtable_1998_2013.dta", replace

keep id2009_2 id2013 id_se06 idpodes08 id2008_1 nm2008_1 id2008_2 nm2008_2 idpodes 

/*

	villages that merged before 2009 are duplicate observations in 2009 & 203
	so we need to drop these

*/
duplicates drop id2013, force

replace idpodes = idpodes08 if idpodes==""

tempfile i13
save `i13'

/* This masterfile is superior (all the way from 1998 to 2015 */


foreach s in "11_2010_podes14_2015" "12_2010_podes14_2015" "13_2010_podes14_2015" "14_2010_podes14_2015" "15_2010_podes14_2015"  ///
"16_2010_podes14_2015" "17_2010_podes14_2015" "18_2010_podes14_2015" "19_2010_podes14_2015" "21_2010_podes14_2015"  ///
"31_2010_podes14_2015" "32_2010_podes14_2015" "33_2010_podes14_2015" "34_2010_podes14_2015" "35_2010_podes14_2015" ///
"36_2010_podes14_2015" "51_2010_podes14_2015" "52_2010_podes14_2015" "53_2010_podes14_2015" "61_2010_podes14_2015" ///
"62_2010_podes14_2015" "63_2010_podes14_2015" "64_2010_podes14_2015" "65_2010_podes14_2015" "71_2010_podes14_2015" ///
"72_2010_podes14_2015" "73_2010_podes14_2015" "74_2010_podes14_2015" "75_2010_podes14_2015" "76_2010_podes14_2015" ///
"81_2010_podes14_2015" "82_2010_podes14_2015" "91_2010_podes14_2015" "94_1998_podes14_2015" {


	import excel "${raw_data_dir}/conversion_tables/2010-2015/`s'.xls", sheet("Sheet1") firstrow clear
	rename *C* *
	tempfile `s'
	save ``s''
	
}


foreach s in "11_2010_podes14_2015" "12_2010_podes14_2015" "13_2010_podes14_2015" "14_2010_podes14_2015" "15_2010_podes14_2015"  ///
"16_2010_podes14_2015" "17_2010_podes14_2015" "18_2010_podes14_2015" "19_2010_podes14_2015" "21_2010_podes14_2015"  ///
"31_2010_podes14_2015" "32_2010_podes14_2015" "33_2010_podes14_2015" "34_2010_podes14_2015" "35_2010_podes14_2015" ///
"36_2010_podes14_2015" "51_2010_podes14_2015" "52_2010_podes14_2015" "53_2010_podes14_2015" "61_2010_podes14_2015" ///
"62_2010_podes14_2015" "63_2010_podes14_2015" "64_2010_podes14_2015" "65_2010_podes14_2015" "71_2010_podes14_2015" ///
"72_2010_podes14_2015" "73_2010_podes14_2015" "74_2010_podes14_2015" "75_2010_podes14_2015" "76_2010_podes14_2015" ///
"81_2010_podes14_2015" "82_2010_podes14_2015" "91_2010_podes14_2015"  {

	append using  ``s''
	
}

duplicates drop // remove empty rows from excel	

rename *, lower()

* create merge id-s for census variables
gen iddesa10 = id_sp2010
replace iddesa10 = id2010_1 if iddesa10==""
drop if substr(iddesa10,-3,3)=="000" // drop headers	

replace idpodes11=id2011_1 if idpodes11==""


* there are almost 700 lines for podes 2014 ID-s which do not appear
* in any other period, so we have to drop them

drop if id2015_1==""


* we drop this to avoid having to care about earlier merges and separations
drop id1998 nm1998 id1999 nm1999 id2000 nm2000 id2001 nm2001 id2002 nm2002  ///
id2003 nm2003 id2004 nm2004 id2005 nm2005 id2006 nm2006 id2007 nm2007 id2007_2 nm2007_2
* same with later
drop id2014_1 nm2014_1 id2014_2 nm2014_2 id2015_1 nm2015_1
drop id_rd2010 nm_rd2010 id_sp2010 nmsp2010 id2010_1 nm2010_1 id2010_2 nm2010_2  ///
id2011_1 nm2011_1 id2011_2 nm2011_2 id2012_1 nm2012_1 id2012_2 id2013_2 nm2013_2  ///
idppls11 nmppls11 id2012_2n166
drop provno kabno kecno desano
drop  id2009_1 nm2009_1 nm2012_2
drop *2009*
* id2009_2 is used for election merge in 2009


* we have to do this to perform merge to 2013-2018 convtable 
duplicates drop id2013_1, force  // 1637 observations lost
rename id2013_1 id2013

merge 1:1 id2013  using `i13', gen(merge_2009)
drop if merge_2009==2

tempfile ctable
save `ctable'


/* merge it to conversion tables 2013 through 2018 */

import delimited ${raw_data_dir}/conversion_tables/4_convtable2013_2018.csv, encoding(utf8) clear 
rename id2013_1 id2013

tostring id2013 id2018_1, force replace
drop downloaded_filename no  // correct for duplicates in downloaded files
duplicates drop

merge m:1 id2013 using `ctable'  , gen(merge_conv)

replace idpodes= idpodes08 if idpodes==""
drop idpodes08
rename idpodes idpodes08 


save "${processed_data_dir}/convtable_1998_2015.dta", replace

