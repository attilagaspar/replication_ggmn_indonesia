

/* steps
1. create district ID
2. collapse population within district by ethnicitiy
3. find majority
4. merge back minority status (and rank) to each ethnicity
5. calculate the share of ethnic minority muslims: 1(minority, muslim) / population
*/

* itearate over individual files
foreach s in  "11desa2000" "12desa2000" "13desa2000" "14desa2000"  ///
"15desa2000" "16desa2000" "17desa2000" "18desa2000" "19desa2000" ///
"31desa2000" "32desa2000" "33desa2000" "34desa2000"  ///
 "35desa2000" "36desa2000" "51desa2000" "52desa2000" "53desa2000" ///
 "61desa2000" "62desa2000" "63desa2000" "64desa2000" "71desa2000" ///
 "72desa2000" "73desa2000" "74desa2000" "75desa2000"  ///
 "81desa2000" "82desa2000"  "94desa2000" {
	disp "transforming `s'"
	use "../${raw_data_dir}/census_ethnicity_religion_by_village/2000/`s'.dta", clear
	gen regid = substr(iddesa00,1,4)  // district id
	drop if iddesa00=="" // empty lines 
	destring religion, force replace

	preserve
		* collapse observations to population by ethnic group to calculate 
		* which group is in majority
		collapse (sum) pop  , by(regid ethnicity)
		
		* rank population with biggest first
		egen ethnic_rank = rank(-pop), by(regid)
		* tag the biggest ethnic group
		gen biggest=0
		replace biggest=1 if ethnic_rank==1
		egen tot_pop = total(pop), by(regid)
		* create population share by ethnicity
		gen share = pop / tot_pop
		* calculate ethnic fractionalization
		gen sh2 = share^2
		egen ethnic_fract = total(sh2), by(regid)
		replace ethnic_fract = 1-ethnic_fract
		* keep relevant variables
		keep share biggest ethnic_fract regid ethnicity 
		
		tempfile eth
		save `eth'
	restore
	
	merge m:1 regid ethnicity using `eth', gen(merge_rank)
	* create a variable for the Muslim population (pop X muslim dummy)
	gen muslim = 0
	replace muslim = pop if religion==1

	* create minority dummy
	gen minority = 1-biggest
	/* variable if RELIGION-ETHNICITY cell  
		- is Muslim
		- belongs to an ethnic minority in the village
	*/
	gen muslim_minority = muslim*minority
	
	/* 
		"pop" is the number of observations in each ethnicity - religion cell 
		--> collapse to villages 
			
	*/
	replace minority = minority * pop

	collapse (sum) pop muslim minority muslim_minority (first) ethnic_fract , by(iddesa00)
	
	gen muslim_minority_villshare = muslim_minority / pop 
	gen muslimshare = muslim / pop 
	rename pop population 
	
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
 
 
 sort iddesa00 
 drop if iddesa00==""
 
* label variables
la var population "SP2000: village population"
la var muslim_minority_villshare "SP2000: share of Muslim ethnic minority in village"
la var ethnic_fract "SP2000: ethnic fractionalization index"
la var muslimshare "SP2000: share of Muslim population in village"
la var iddesa00 "SP2000 village ID"
 
rename iddesa00 id2000

rename * *2000
rename id2000 id2000

gen has_minor2000=0 if muslim_minority_villshare!=.
replace has_minor2000=1 if muslim_minority_villshare>=.5&muslim_minority_villshare!=.
la var has_minor2000 "SP2000: Minority-majority village in 2000"


tempfile borders2000
save `borders2000' 

/* 
***************************************************
generate same variables using 2004 district borders   
*************************************************** 
*/

/* steps
1. create district ID
2. collapse population within district by ethnicitiy
3. find majority
4. merge back minority status (and rank) to each ethnicity
5. calculate the share of ethnic minority muslims: 1(minority, muslim) / population
*/

/*
	create district id for 2004 borders
*/ 
use "${processed_data_dir}/convtable_1998_2013.dta", clear
drop id1998 nm1998 id1999 nm1999
drop if id2000==""
drop if substr(id2000,8,3)=="000"
replace id2000=id2002 if substr(id2002,1,2)=="94"
keep id2000   id2004
rename id2004 district2004
replace district2004 = substr(district2004,1,4)
duplicates drop
duplicates drop id2000, force
rename id2000 iddesa00
tempfile id2k
save `id2k'



* itearate over individual files
foreach s in  "11desa2000" "12desa2000" "13desa2000" "14desa2000"  ///
"15desa2000" "16desa2000" "17desa2000" "18desa2000" "19desa2000" ///
"31desa2000" "32desa2000" "33desa2000" "34desa2000"  ///
 "35desa2000" "36desa2000" "51desa2000" "52desa2000" "53desa2000" ///
 "61desa2000" "62desa2000" "63desa2000" "64desa2000" "71desa2000" ///
 "72desa2000" "73desa2000" "74desa2000" "75desa2000"  ///
 "81desa2000" "82desa2000"  "94desa2000" {
	disp "transforming `s'"
	use "../${raw_data_dir}/census_ethnicity_religion_by_village/2000/`s'.dta", clear
	
	merge m:1 iddesa00 using `id2k', gen(merge_id)
	drop if merge_id==2
	replace district2004=substr(iddesa00,1,4) if merge_id==1  //inputaljuk mostanival ha nincs
	drop merge_id
	drop if iddesa00=="" // empty lines 
	destring religion, force replace
	rename district2004 regid
	preserve
		* collapse observations to population by ethnic group to calculate 
		* which group is in majority
		collapse (sum) pop  , by(regid ethnicity)
		
		* rank population with biggest first
		egen ethnic_rank = rank(-pop), by(regid)
		* tag the biggest ethnic group
		gen biggest=0
		replace biggest=1 if ethnic_rank==1
		egen tot_pop = total(pop), by(regid)
		* create population share by ethnicity
		gen share = pop / tot_pop
				* calculate ethnic fractionalization
		gen sh2 = share^2
		egen ethnic_fract = total(sh2), by(regid)
		replace ethnic_fract = 1-ethnic_fract
		* keep relevant variables
		keep share biggest ethnic_fract regid ethnicity  
		
		tempfile eth
		save `eth'
	restore
	
	merge m:1 regid ethnicity using `eth', gen(merge_rank)
	* create a variable for the Muslim population (pop X muslim dummy)
	gen muslim = 0
	replace muslim = pop if religion==1

	* create minority dummy
	gen minority = 1-biggest
	/* variable if RELIGION-ETHNICITY cell  
		- is Muslim
		- belongs to an ethnic minority in the village
	*/
	gen muslim_minority = muslim*minority
	
	/* 
		"pop" is the number of observations in each ethnicity - religion cell 
		--> collapse to villages 
			
	*/
	replace minority = minority * pop

	collapse (sum) pop muslim minority muslim_minority (first) ethnic_fract , by(iddesa00)
	
	gen muslim_minority_villshare = muslim_minority / pop 
	gen muslimshare = muslim / pop 
	rename pop population 
	
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
 
 
 sort iddesa00 
 drop if iddesa00==""
 
* label variables

rename iddesa00 id2000

rename * *2004
rename id2000 id2000

gen has_minor2004=0 if muslim_minority_villshare!=.
replace has_minor2004=1 if muslim_minority_villshare>=.5&muslim_minority_villshare!=.

merge 1:1 id2000 using `borders2000' , gen(merge2000)

order *, alpha
order id*

la var id2000 "Census2000 village ID"

la var ethnic_fract2000 "Census2000: Ethnic fractionalization in 2000"
la var ethnic_fract2004 "Census2000: Ethnic fractionalization in 2004"
la var muslim_minority_villshare2000 "Census2000: Share of Muslim ethnic minorities in 2000"
la var muslim_minority_villshare2004 "Census2000: Share of Muslim ethnic minorities in 2004"
la var has_minor2000 "Census2000: Minority-majority village in 2000"
la var has_minor2004 "Census2000: Minority-majority village in 2004"

gen minority_share2000 = minority2000 / population2000
gen minority_share2004 = minority2004 / population2004

la var minority_share2000 "Census2000: Share of ethnic minorities in 2000"
la var minority_share2004 "Census2000: Share of ethnic minorities in 2004"
la var muslimshare2000 "Census2000: share of Muslim population in village"

la var population2000  "Census2000: village population"
keep id2000 ethnic_fract2000 ethnic_fract2004 has_minor2000 has_minor2004 muslim_minority_villshare2000 muslim_minority_villshare2004 muslimshare2000 population2000 minority_share2000 minority_share2004

save "${processed_data_dir}/census2000.dta", replace
