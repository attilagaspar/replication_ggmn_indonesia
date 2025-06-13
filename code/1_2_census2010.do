
/* steps
1. create district ID
2. collapse population within district by ethnicitiy
3. find majority
4. merge back minority status (and rank) to each ethnicity
5. calculate the share of ethnic minority muslims: 1(minority, muslim) / population
*/


* itearate over individual files
foreach s in  "11desa2010" "12desa2010" "13desa2010" "14desa2010"  ///
"15desa2010" "16desa2010" "17desa2010" "18desa2010" "19desa2010" ///
 "21desa2010" "31desa2010" "32desa2010" "33desa2010" "34desa2010"  ///
 "35desa2010" "36desa2010" "51desa2010" "52desa2010" "53desa2010" ///
 "61desa2010" "62desa2010" "63desa2010" "64desa2010" "71desa2010" ///
 "72desa2010" "73desa2010" "74desa2010" "75desa2010" "76desa2010" ///
 "81desa2010" "82desa2010" "91desa2010" "94desa2010" {
	disp "transforming `s'"
	use "${raw_data_dir}/census_ethnicity_religion_by_village/2010/`s'.dta", clear
	gen regid = substr(iddesa10,1,4)  // district id
	drop if iddesa10=="" // empty lines 
	

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
	
	collapse (sum) pop muslim minority muslim_minority (first) ethnic_fract , by(iddesa10)
	
	gen muslim_minority_villshare = muslim_minority / pop 
	gen muslimshare = muslim / pop 
	rename pop population 
	
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
 
 
 sort iddesa10 
 drop if iddesa10==""
 
 
* post 2010 village ID-s need to be merged
merge 1:m iddesa10 using "${processed_data_dir}/convtable_1998_2015.dta", gen(merge_convtable)

* drop if a village is missing from census or it is ceasing to exist
keep if id2018_1!=""&idpodes14!=""&iddesa10!=""
gen missing_from_census = 0
replace missing_from = 1 if merge_convtable==2
duplicates drop id2018_1, force   // 2018 has to be unique - 176 observations lost

keep   ethnic_fract muslim_minority_villshare minority  iddesa10 id2018_1
rename * *2010
rename iddesa10 id2010 
rename id2018_1 id2018_1 


tempfile borders2010
save `borders2010' 

/* 
***************************************************
generate same variables using 2018 district borders   
*************************************************** 
*/

/* steps
1. create district ID
2. collapse population within district by ethnicitiy
3. find majority
4. merge back minority status (and rank) to each ethnicity
5. calculate the share of ethnic minority muslims: 1(minority, muslim) / population
*/

* load 2018 ids

use ${processed_data_dir}/convtable_1998_2015.dta, clear
keep id2018_1 iddesa10
duplicates drop
drop if iddesa10 == "" // villages that are new in 2018 
gen regid18 = substr(id2018_1,1,4) 
drop if regid18 == ""  // villages that don't exist by 2018
duplicates drop iddesa10 regid18, force  // we only need a regional id in 2018 for the village in 2010
duplicates drop iddesa10, force // there is a single village which split and the new village went to another district - drop it 

tempfile newid
save `newid'


  



foreach s in  "11desa2010" "12desa2010" "13desa2010" "14desa2010"  ///
"15desa2010" "16desa2010" "17desa2010" "18desa2010" "19desa2010" ///
 "21desa2010" "31desa2010" "32desa2010" "33desa2010" "34desa2010"  ///
 "35desa2010" "36desa2010" "51desa2010" "52desa2010" "53desa2010" ///
 "61desa2010" "62desa2010" "63desa2010" "64desa2010" "71desa2010" ///
 "72desa2010" "73desa2010" "74desa2010" "75desa2010" "76desa2010" ///
 "81desa2010" "82desa2010" "91desa2010" "94desa2010" {
	disp "transforming `s'"
	use "${raw_data_dir}/census_ethnicity_religion_by_village/2010/`s'.dta", clear
	
	drop if iddesa10==""

	merge m:1 iddesa10 using `newid', gen(merge_`s')   // merge new id-s
	
	replace regid18 = substr(iddesa10,1,4) if regid18=="" // assume village remained in same district if cannOt be found in 2018
	drop if merge_`s'==2 //  data from every other province 
	drop merge_`s'

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
	
	collapse (sum) pop muslim minority muslim_minority (first) ethnic_fract , by(iddesa10)
	
	gen muslim_minority_villshare = muslim_minority / pop 
	gen muslimshare = muslim / pop 
	rename pop population 
	
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
 
 
 sort iddesa10 
 drop if iddesa10==""
 
  
foreach v of varlist population muslim minority muslim_minority muslim_minority_villshare muslimshare ethnic_fract  {

	 
	 rename `v' `v'2018
	

}


 
* post 2010 village ID-s need to be merged
merge 1:m iddesa10 using "${processed_data_dir}/convtable_1998_2015.dta", gen(merge_convtable)

* drop if a village is missing from census or it is ceasing to exist
keep if id2018_1!=""&idpodes14!=""&iddesa10!=""
gen missing_from_census = 0
replace missing_from = 1 if merge_convtable==2
duplicates drop id2018_1, force   // 2018 has to be unique - 176 observations lost

rename iddesa10 id2010

merge 1:1 id2018_1 using `borders2010', gen(merge_borders2010) 

keep id2010 population2018  muslim_minority2018 ethnic_fract2018 muslim_minority_villshare2018 muslimshare2018 id2018_1  ethnic_fract2010 muslim_minority_villshare2010  minority*  

order *, alpha
order id2010 id2018_1


la var ethnic_fract2010 "Census2010: Ethnic fractionalization in 2010"
la var ethnic_fract2018 "Census2010: Ethnic fractionalization in 2018"
la var muslim_minority_villshare2010 "Census2010: Share of Muslim ethnic minorities in 2010"
la var muslim_minority_villshare2018 "Census2010: Share of Muslim ethnic minorities in 2018"

gen has_minor2010=0 if muslim_minority_villshare2010!=.
replace has_minor2010=1 if muslim_minority_villshare2010>=.5 & muslim_minority_villshare2010!=.

gen has_minor2018=0 if muslim_minority_villshare2018!=.
replace has_minor2018=1 if muslim_minority_villshare2018>=.5 & muslim_minority_villshare2018!=.

la var has_minor2010 "Census2010: Minority-majority village in 2010"
la var has_minor2018 "Census2010: Minority-majority village in 2018"

gen minority_share2010 = minority2010 / population2018
gen minority_share2018 = minority2018 / population2018

la var minority_share2010 "Census2010: Share of ethnic minorities in 2010"
la var minority_share2018 "Census2010: Share of ethnic minorities in 2018"

drop minority2010 minority2018 muslim_minority2018 
la var muslimshare2018 "Census2010: Share of Muslims in 2018"
rename muslimshare2018 muslimshare2010
rename population2018 population2010
la var population2010 "Census2010: village population"

save "${processed_data_dir}/census2010.dta", replace
