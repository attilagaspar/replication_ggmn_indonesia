/*


	- Put together data sources
		- PODES frame
		- Elections 2019
		- Elections 2014
		- Corruption signals 
		

*/


/*

	variable definitions for the analysis, merging corruption signals etc.

*/

global minority_var = "has_minor2018"


* load podes frame
use ${processed_data_dir}/podes_panel08_18, clear

* merge census minority variables

merge 1:1 id2018 using ${processed_data_dir}/census2010.dta, gen(merge_census2010)
drop if merge_census2010==2 // missing from podes


* merge cencus ethnicity shares
merge m:1 id2010 using ${processed_data_dir}/ethnic_shares2010.dta, gen(merge_ethnicshares2010)
drop if merge_ethnicshares2010==2  // missing from podes

* merge election data
merge 1:1 id2018 using ${processed_data_dir}/election2014_with_village_ids, gen(merge_election2014)
merge 1:1 id2018 using ${processed_data_dir}/election2019_with_village_ids, gen(merge_election2019)
drop if merge_election2019==2  // missing from podes


gen kab_code=substr(id2018_1,1,4)
destring kab_code, force replace

merge m:1 kab_code using "${processed_data_dir}/transparency_indicators_wide.dta", gen(merge_corr)
drop if merge_corr == 2  // areas not covered in PODES

/*

	treatment variable generation

*/


* corruption variables

* lewis was too lenient (numeric opinion 0,0.5,1 was considered good transparency,
* not much variation is left)
forvalues n = 2005/2018 {

	gen lewis_strict`n' = 1 if opinion_numeric`n'<=0.5
	replace lewis_strict`n'=0 if opinion_numeric`n'>0.5&opinion_numeric`n'!=.
	replace opinion_numeric`n' = 0 if opinion_numeric`n'==0.5
}

* create corruption change between election cycles 
egen mean_opinion = rowmean(opinion_numeric2018 opinion_numeric2017 opinion_numeric2016 opinion_numeric2015)
egen mean_opinion_prev = rowmean(opinion_numeric2013 opinion_numeric2012 opinion_numeric2011 opinion_numeric2010 )
gen d_mean_opinion = mean_opinion-mean_opinion_prev

gen d_opinion = opinion_numeric2018 - opinion_numeric2013 //%%% 2015 volt eredetileg
gen d_opinion_w = opinion_numeric2018 - opinion_numeric2015 

gen more_corrupt = .
replace more_corrupt = 0 if d_opinion!=.
replace more_corrupt = 1 if d_opinion>0&d_opinion!=.
gen less_corrupt = .
replace less_corrupt = 0 if d_opinion!=.
replace less_corrupt = 1 if d_opinion<0

gen more_corrupt_w = .
replace more_corrupt_w = 0 if d_opinion_w!=.
replace more_corrupt_w = 1 if d_opinion_w>0&d_opinion_w!=.
gen less_corrupt_w = .
replace less_corrupt_w = 0 if d_opinion_w!=.
replace less_corrupt_w = 1 if d_opinion_w<0


gen more_corrupt_btw = .
replace more_corrupt_btw = 0 if d_mean_opinion!=.
replace more_corrupt_btw = 1 if d_mean_opinion>0&d_mean_opinion!=.

gen less_corrupt_btw = .
replace less_corrupt_btw = 0 if d_mean_opinion!=.
replace less_corrupt_btw = 1 if d_mean_opinion<0


gen lewis_dummy2018=0 if opinion_numeric2018!=.
replace lewis_dummy2018=1 if opinion_numeric2018>1&opinion_numeric2018!=. 

*replace lewis_dummy2018 = 1-lewis_dummy2018 // harmonize the sign of the dummy

gen lewis_minor = lewis_dummy2018*${minority_var}
la var lewis_minor "\textbf{Corruption $\times$ Minority}"
la var lewis_dummy2018 "D(Corruption)"
la var ${minority_var} "Minority"

tab opinion_numeric2018, gen(on18)
la var on182 "Qualified opinion (Least corrupt)"
la var on183 "Disclaimer (Most corrupt)"
gen on182minor = on182*${minority_var}
la var on182minor "\textbf{Least $\times$ Minority}"
gen on183minor = on183*${minority_var}
la var on183minor "\textbf{Most $\times$ Minority}"


gen mean_opinion_minor = mean_opinion*${minority_var}
la var mean_opinion_minor "\textbf{Average $\times$ Minority}"
la var mean_opinion "Within-cycle average"

* 5 year diff
gen d_opinion_minor = d_opinion*${minority_var}
la var d_opinion_minor "\textbf{$\Delta_{2018-2013}$ $\times$ Minority}"
la var d_opinion "$\Delta_{2018-2013}$"

gen more_corrupt_minor = more_corrupt*${minority_var}
la var more_corrupt_minor "\textbf{More $\times$ Minority}"
gen less_corrupt_minor = less_corrupt*${minority_var}
la var less_corrupt_minor "\textbf{Less $\times$ Minority}"
la var more_corrupt "More corruption in 5 years"
la var less_corrupt "Less corruption in 5 years"

* within change
gen d_opinion_minor_w = d_opinion_w*${minority_var}
la var d_opinion_minor_w "\textbf{$\Delta_{2018-2015}$ $\times$ Minority}"
la var d_opinion_w "$\Delta_{2018-2015}$"

gen more_corrupt_minor_w = more_corrupt_w*${minority_var}
la var more_corrupt_minor_w "\textbf{More $\times$ Minority}"
gen less_corrupt_minor_w = less_corrupt_w*${minority_var}
la var less_corrupt_minor_w "\textbf{Less $\times$ Minority}"
la var more_corrupt_w "More corruption within cycle"
la var less_corrupt_w "Less corruption within cycle"


* betwwn change

gen d_mean_opinion_minor = d_mean_opinion*${minority_var}
la var d_mean_opinion_minor "\textbf{$(\overline{2015-to-2018}-\overline{2011-to-2014})$ $\times$ Minority}"
la var d_mean_opinion "$\overline{2015-to-2018}-\overline{2011-to-2014}"

gen more_corrupt_minor_btw = more_corrupt_btw*${minority_var}
la var more_corrupt_minor_btw "\textbf{More $\times$ Minority}"
gen less_corrupt_minor_btw = less_corrupt_btw*${minority_var}
la var less_corrupt_minor_btw "\textbf{Less $\times$ Minority}"
la var more_corrupt_btw "More corruption between cycles"
la var less_corrupt_btw "Less corruption between cycles"






* log distance from center
gen log_dist = log(podes2018_R1002BK5)

* monetary aid from district
gen aid_from_district2014 = podes2014_R1501C1_K3
replace aid_from_district2014 = 0 if aid_from_district==.
gen log_aid2014 = log(aid_from_district2014 + 1)
gen noaid2014=0 
replace noaid2014 = 1 if log_aid2014==0



* create ethnicity dummies


foreach v of varlist popshare* {
	replace `v' = 0 if `v'==. 
	qui gen c`v' = ceil(`v')
	* only consider popuations with at least 1 pct of population share
	replace c`v' = 0 if `v'<=0.01
	
}

rename cpopshare* ethn_*



* biggest



/* ez inkonzisztens a másikkal 
egen biggest_ethn = group(podes2018_R804A2A)

* dummy for each ethnic group
levelsof podes2018_R804A2A, local(levels) 
foreach l of local levels {
	qui gen ethn_`l'=0
	qui replace  ethn_`l'=1 if podes2018_R804A2A=="`l'"
	qui replace  ethn_`l'=1 if podes2018_R804A2B=="`l'"
	qui replace  ethn_`l'=1 if podes2018_R804A2C=="`l'"
 }

*/

* for missing observation analysis
gen island_code = substr(id2018_1,1,1)
replace island_code = "1" if island_code == "2"
label define isl 1 "Region: Sumatra and Riau Islands" 3 "Region: Java" 2 "Region: Sumatra and Riau Islands"  ///
5 "Region: Nusa Tenggara Islands" 6 "Region: Kalimantan" 7 "Region: Sulawesi" /// 
8 "Region: Maluku" 9 "Region: Papua" 

destring island_code, force replace



rename constituency_name20142014 dapil_name2014


* additional control variables (ad hoc)
*destring podes2014_R502A , force replace
*gen slumshare2014 = podes2014_R511B3/(podes2014_R501A1 + podes2014_R501A2 + podes2014_R501B)
*replace slumshare2014=0 if slumshare2014==.
*gen mosqueperhh2014 = (podes2014_R803A+podes2014_R803A)/(podes2014_R501A1 + podes2014_R501A2 + podes2014_R501B)
*gen electricity2014=(podes2014_R501A1 + podes2014_R501A2 )/(podes2014_R501A1 + podes2014_R501A2 + podes2014_R501B )



gen d_islamist = voteshare_islamist2019  - voteshare_islamist2014
gen lpop = log(population2010) 

* variables for additional analysis
gen distance_to_region2018 = podes2018_R1002BK5 

rename podes2018_R804B2 language2018

* village revenues
rename podes2008_r13011_2 own_source_type2008
rename podes2011_r1401ak2 own_source_type2011
rename podes2014_R1501A_K2 own_source_type2014

rename podes2008_r13011_3 own_source_amount2008
rename podes2011_r1401ak3 own_source_amount2011
rename podes2014_R1501A_K3 own_source_amount2014

rename podes2008_r13012a_2 receive_district_support2008
rename podes2011_r1401b1k2 receive_district_support2011
rename podes2014_R1501C1_K2 receive_district_support2014

rename podes2008_r13012a_3 finsupport_amount2008
rename podes2011_r1401b1k3 finsupport_amount2011
rename  podes2014_R1501C1_K3 finsupport_amount2014

gen gets_aid = 1 if receive_district_support2014!=""
replace gets_aid = 0 if receive_district_support2014=="4"
gen aid = finsupport_amount2014
destring aid, force replace
replace aid = 0 if aid==.&gets_aid==0
egen aid_pc_std = std(aid/population2010 ) if d_islamist!=.


foreach v of varlist podes2018_R1008*K2 {
	
	replace `v' = 2-`v'  // 2 means no, 1 means yes --> recode to dummy
 	
}


* media access
la var podes2018_R1008AK2 "National TV"
la var podes2018_R1008BK2 "Regional TV"
la var podes2018_R1008CK2 "Private TV"
la var podes2018_R1008DK2 "Foreign TV"
la var podes2018_R1008EK2 "National radio"
la var podes2018_R1008FK2 "Regional radio"
la var podes2018_R1008GK2 "Private/regional radio"

rename podes2018_R1008AK2 access2018_nattv
rename podes2018_R1008BK2 access2018_regtv
rename podes2018_R1008CK2 access2018_privtv
rename podes2018_R1008DK2 access2018_fortv
rename podes2018_R1008EK2 access2018_natrad
rename podes2018_R1008FK2 access2018_regrad
rename podes2018_R1008GK2 access2018_privrad


gen no_mobile_data=0 if podes2018_R1005D!=.
replace no_mobile_data= 1 if podes2018_R1005D==4
la var no_mobile_data "No mobile internet in village"

* final touches: drop podes variables that are not used (proprietary data)
drop podes*
qui compress
save ${processed_data_dir}/${final_sample2010s}.dta, replace





