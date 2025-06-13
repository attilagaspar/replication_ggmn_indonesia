
/* 

this script generates ethnicity shares for each village in both censuses

*/




foreach s in  "11desa2010" "12desa2010" "13desa2010" "14desa2010"  ///
"15desa2010" "16desa2010" "17desa2010" "18desa2010" "19desa2010" ///
 "21desa2010" "31desa2010" "32desa2010" "33desa2010" "34desa2010"  ///
 "35desa2010" "36desa2010" "51desa2010" "52desa2010" "53desa2010" ///
 "61desa2010" "62desa2010" "63desa2010" "64desa2010" "71desa2010" ///
 "72desa2010" "73desa2010" "74desa2010" "75desa2010" "76desa2010" ///
 "81desa2010" "82desa2010" "91desa2010" "94desa2010" {
	disp "transforming `s'"
	use "${raw_data_dir}/census_ethnicity_religion_by_village/2010/`s'.dta", clear
	
	
	*village level
	collapse (sum) pop , by(iddesa10 ethnicity)
	
	drop if iddesa10=="" // we cannot use the people whom we dont know where they live
	
	
	egen totpop = total(pop), by(iddesa10) 
	
	drop if ethnicity ==. // we can still count them into the total so don't drop it before this
	
	gen popshare = pop/totpop
	drop pop totpop // stopping reshape
	reshape wide popshare, i(iddesa10) j(ethnicity)
	
	foreach v of varlist popshare* {
	
			replace `v'=0 if `v'==.
	
	}
	
	
	tempfile `s'
	save ``s''

}

foreach s in  "11desa2010" "12desa2010" "13desa2010" "14desa2010"  ///
"15desa2010" "16desa2010" "17desa2010" "18desa2010" "19desa2010" ///
 "21desa2010" "31desa2010" "32desa2010" "33desa2010" "34desa2010"  ///
 "35desa2010" "36desa2010" "51desa2010" "52desa2010" "53desa2010" ///
 "61desa2010" "62desa2010" "63desa2010" "64desa2010" "71desa2010" ///
 "72desa2010" "73desa2010" "74desa2010" "75desa2010" "76desa2010" ///
 "81desa2010" "82desa2010" "91desa2010" {
 * note that 94desa10 is not in the list
	disp "combining `s'"
	append using  ``s''
 
 }
 


rename iddesa10 id2010

save "${processed_data_dir}/ethnic_shares2010.dta", replace




* itearate over individual files
foreach s in  "11desa2000" "12desa2000" "13desa2000" "14desa2000"  ///
"15desa2000" "16desa2000" "17desa2000" "18desa2000" "19desa2000" ///
"31desa2000" "32desa2000" "33desa2000" "34desa2000"  ///
 "35desa2000" "36desa2000" "51desa2000" "52desa2000" "53desa2000" ///
 "61desa2000" "62desa2000" "63desa2000" "64desa2000" "71desa2000" ///
 "72desa2000" "73desa2000" "74desa2000" "75desa2000"  ///
 "81desa2000" "82desa2000"  "94desa2000" {
	disp "transforming `s'"

	use "${raw_data_dir}/census_ethnicity_religion_by_village/2000/`s'.dta", clear
	

	
	collapse (sum) pop , by(iddesa00 ethnicity)
	
	drop if iddesa00=="" // we cannot use the people whom we dont know where they live
	
	
	egen totpop = total(pop), by(iddesa00) 
	
	
	gen popshare = pop/totpop
	drop pop totpop // stopping reshape
	reshape wide popshare, i(iddesa00) j(ethnicity) string
	
	
	
	foreach v of varlist popshare* {
	
	replace `v'=0 if `v'==.
	
	}
	

	tempfile `s'
	save ``s''
	

}
clear
foreach s in  "11desa2000" "12desa2000" "13desa2000" "14desa2000"  ///
"15desa2000" "16desa2000" "17desa2000" "18desa2000" "19desa2000" ///
"31desa2000" "32desa2000" "33desa2000" "34desa2000"  ///
 "35desa2000" "36desa2000" "51desa2000" "52desa2000" "53desa2000" ///
 "61desa2000" "62desa2000" "63desa2000" "64desa2000" "71desa2000" ///
 "72desa2000" "73desa2000" "74desa2000" "75desa2000"  ///
 "81desa2000" "82desa2000"  "94desa2000" {
	disp "combining `s'
	append using  ``s''
 
 }
 
 foreach v of varlist popshare* {
	
	replace `v'=0 if `v'==.
	
}

 rename iddesa00 id2000
 
 save "${processed_data_dir}/ethnic_shares2000.dta", replace
