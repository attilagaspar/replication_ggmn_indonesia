
clear
clear matrix
clear mata
set maxvar 10000 
use ${processed_data_dir}/${final_sample2010s}.dta
eststo clear


merge m:1 district using "${processed_data_dir}/coalitions", gen(merge_coalitions)
drop if merge_coalitions==2


* generate coalition votes in district 

egen pop_dist = total(population2010), by(district) // no electorate data in either 2014 or 2019, use 2010 population instead

gen district_coalition_margin2019 = votes/pop_dist 

drop if district_coalition_margin>1

*replace coalition_margin = . if coalition_margin>1 // data error
* not neccessarily since the numerator is TURNOUT in 2019, not number of voters

gen coalition_votes = 0 if merge_coalitions==3



replace coalition_votes = coalition_votes + vote_pdip2014 if coalition_pdip==1
replace coalition_votes = coalition_votes + vote_gerindra2014 if coalition_gerindra==1
replace coalition_votes = coalition_votes + vote_pks2014 if coalition_pks==1
replace coalition_votes = coalition_votes + vote_nasdem2014 if coalition_nasdem==1
replace coalition_votes = coalition_votes + vote_hanura2014 if coalition_hanura==1
replace coalition_votes = coalition_votes + vote_pkp2014 if coalition_pkpi==1
replace coalition_votes = coalition_votes + vote_pan2014 if coalition_pan==1
replace coalition_votes = coalition_votes + vote_golkar2014 if coalition_golkar==1
replace coalition_votes = coalition_votes + vote_demokrat2014 if coalition_demokrat==1
replace coalition_votes = coalition_votes + vote_ppp2014 if coalition_ppp==1
replace coalition_votes = coalition_votes + vote_pbb2014 if coalition_pbb==1
replace coalition_votes = coalition_votes + vote_partai_aceh2014 if coalition_aceh==1
replace coalition_votes = coalition_votes + vote_pkb2014 if coalition_pkb==1

gen village_coalition_margin2014 = coalition_votes / allvotes2014 






egen xx = tag(${sevar14})
sum district_coalition_margin2019 if xx==1 , det // &coalition_pbb!=1&coalition_ppp!=1&coalition_pks!=1

local cf = "r(p${cutoff})"
local cutoff = `cf' 
disp "`cutoff'"

drop xx
 
/* 2018-2014 */

cap drop c 
cap drop c_minor 
cap drop minority_var
gen minority_var = ${minor14}
*gen c=more_corrupt_btw
gen c=more_corrupt
gen c_minor = more_corrupt*${minor14}


la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption * Minority"

local controls = " ${covariates14} "
local clustervar=" ${sevar14}"

reghdfe d_islamist c  minority_var c_minor  `controls' if  district_coalition_margin2019<`cutoff'  , cluster(`clustervar') absorb(`clustervar') 

*lincom c + minority_var + c_minor

*lincomestadd c + minority_var + c_minor, statname(sumcoef)


estadd local fracsample "Below ${cutoff}th ptile " 

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe d_islamist c  minority_var c_minor  `controls'  if  district_coalition_margin2019>=`cutoff' , cluster(`clustervar') absorb(`clustervar') 

*lincom c + minority_var + c_minor

*lincomestadd c + minority_var + c_minor, statname(sumcoef)


estadd local fracsample "Above ${cutoff}th ptile " 

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo

/*
reghdfe d_islamist c  minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 

estadd local fracsample "Both" 

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo
*/


esttab using "${results_dir}/main_table_coalitions_${suffix}${cutoff}.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(c  minority_var c_minor  ///
	) ///
	order( c  minority_var c_minor  ///
	) ///
	compress  nonotes ///
	tex ///	mgroups("1999-2004" "2014-2019", pattern(1 0 1 0)) ///
		nomtitles ///
	title("Increase in Islamist support") ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	scalars("fracsample Ethnic fractionalization" ///		
	"outcome Dependent variable" ///
			"csignal Corruption signal" ///
			"districtfe District fixed effects" ///
			"ethdummies Ethnic group dummies" ///
			"villagecontrols Village controls") ///
	replace  
	
/*

mgroups("1999-2004" "2014-2019", pattern(1 1)) ///
	nomtitles ///

	///
	nonumbers
	
