/* this script creates balance checks for missing vote data in 2014 */

use ${processed_data_dir}/${final_sample2010s}.dta, clear


gen id_kec = substr(id2009_2, 1,7)
replace id_kec = substr(iddesa,1,10) if id_kec==""


merge m:1 id_kec using "${raw_data_dir}/2009_votes_and_seats.dta", gen(merge_2009_election)


*type 3 imputation: districts that did not exist at the time of the election

gen dist2009 = substr(id2009, 1,4)
egen total_islamist_dist = total(seat_islamist), by(dist2009)
replace seat_islamist = total_islamist_dist if imputation == 3
drop total_islamist_dist


gen gets_aid2014=.
replace gets_aid2014=0 if aid_from_district2014==0
replace gets_aid2014=1 if aid_from_district2014>0&aid_from_district2014!=.


* set sample
keep if lpop!=.  // means that podes is merged 
keep if lewis_dummy2018!=. // means that transparency indicators were succesfully merged

gen missing14 = 0
replace missing14 = 1 if voteshare_islamist2014 ==.


la var lpop "Log(Population)"
la var log_dist "Log(Distance from district center)"
la var gets_aid2014 "Gets aid from district in 2014"
la var log_aid2014 "Log(Aid from district in 2014)"
la var muslimshare "Share of Muslim population in village"
la var voteshare_islamist2014 "Voteshare of Islamist parties in 2014"
la var voteshare_islamist2019 "Voteshare of Islamist parties in 2019"
la var opinion_numeric2013 "Budget quality of the district in 2013 (0-3)"
la var opinion_numeric2018 "Budget quality of the district in 2018 (0-3)"

la var opinion_numeric2008 "Budget quality in 2008 (0: least corrupt, 3: most corrupt)"
la var missing14 "Election data missing (2014)"

la var voteshare_islamist2019 "Islamist voteshare 2019 (village)"
la var voteshare_islamist2009 "Islamist voteshare 2009 (district)"
la var has_minor2010 "Share of Muslim minority villages"


* descriptive table
eststo clear
bysort missing14: eststo: estpost summarize lpop has_minor2010  muslimshare log_dist voteshare_islamist2009 ///
 voteshare_islamist2014 voteshare_islamist2019 ///
 opinion_numeric2008 opinion_numeric2013  opinion_numeric2018

esttab using "${results_dir}/balance_2014.tex", replace nodepvar cells("mean (fmt(2)) sd (fmt(2)) ")  ///
	label nonotes  ///
	addnotes(" \begin{minipage}{14.5cm}  \textit{Notes:} The table shows differences between villages with and without election data in 2014. Villages that do not report election data in 2014 are less populous, further away from the district center, less Muslim, more minority. They do not differ in terms of budget quality and Islamist vote. This is consistent with our information that the reason for missing data is that money ran out halfway through the digitalization effort.  \end{minipage} ") 



* geographical table	
replace island_code = 1 if island_code == 2  // these are islands around sumatra
label define isl 1 "Region: Sumatra and Riau Islands" 3 "Region: Java" 2 "Region: Sumatra and Riau Islands"  ///
5 "Region: Nusa Tenggara Islands" 6 "Region: Kalimantan" 7 "Region: Sulawesi" /// 
8 "Region: Maluku" 9 "Region: Papua" 

destring island_code, force replace
la val island_code isl
la var island_code "Geographical area"
tabout island_code missing14 using "${results_dir}/balance_2014_regions.tex", c(freq row) f(0c 1) style(tex)  replace 

 
 gen bpid2018 = substr(id2018_1,1,4)

 la var has_minor2010 "Minority%" 
 la var muslimshare "Muslim%"
 la var voteshare_islamist2009 "Islamist2009"
 la var voteshare_islamist2019 "Islamist2019"
 la var opinion_numeric2013 "Corruption2013"
  la var opinion_numeric2018 "Corruption2018"

  local results_dir = "results_publishable"

eststo clear
la var missing14 "Missing election result in 2014"

foreach v of varlist voteshare_islamist2009 voteshare_islamist2019  opinion_numeric2013 opinion_numeric2018  {

	reg `v' missing14  , cluster(kab_code) 
	eststo

}

esttab using "${results_dir}/missing_1.tex", replace se label  nonotes  keep( missing14) noobs

eststo clear

foreach v of varlist voteshare_islamist2009 voteshare_islamist2019  opinion_numeric2013  opinion_numeric2018 {

	reg `v' missing14 if island_code<8 , cluster(kab_code) 
	eststo
}

esttab using "${results_dir}/missing_2.tex", replace se label nonotes  keep( missing14) noobs

eststo clear

foreach v of varlist voteshare_islamist2009 voteshare_islamist2019  opinion_numeric2013 opinion_numeric2018 {

	reg `v' missing14  lpop  has_minor2010  muslimshare log_dist , cluster(kab_code) //if island_code<8
	eststo
}

esttab using "${results_dir}/missing_3.tex", replace se label  nonotes  keep( missing14) noobs

eststo clear

foreach v of varlist voteshare_islamist2009 voteshare_islamist2019  opinion_numeric2013 opinion_numeric2018 {

	reg `v' missing14  lpop  has_minor2010  muslimshare log_dist if island_code<8 , cluster(kab_code) //if island_code<8
	eststo
}

esttab using "${results_dir}/missing_4.tex", replace se label  nonotes keep( missing14) noobs  ///
 addnotes(" \begin{minipage}{14.5cm} \textit{Notes:} The table investigates if villages with missing and non-missing election data in 2014 were in areas with significantly different Islamist support and corruption signals. Dependent variables are vote shares of Islamist parties in the constituency of the village in 2009 (Column 1), vote share of Islamist parties in the village in 2019 (Column 2), Corruption score of the district from 0 to 3 in 2013 (Column 3), Corruption score of the district in 2018 (Column 4). Controls in Panels C and D are: natural logarithm of population and distance of the village from the district center, and the share of Muslim population. Standard errros clustered at the district level.  \end{minipage} ") 


