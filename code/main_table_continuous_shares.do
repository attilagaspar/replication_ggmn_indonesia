* create combined dataset
*net install lincomestadd, from("https://github.com/benzipperer/lincomestadd/raw/master")
cap log close
log using reglog.txt, replace text
use ${processed_data_dir}/${final_sample2000s}.dta, clear
merge m:1 id2000 using "${processed_data_dir}/ethnic_shares2000.dta"
keep if _merge==3
drop _merge

eststo clear

/* 2004-1999 */
gen bps_2005=substr(id2003,1,4)
* COLUMN 1
* variables
cap drop c_minor
gen minority_var = ${minor00}
gen c = corr1
gen c_minor = ${minor00}*corr1 

la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption X Minority"


local covariates = " ${covariates00}  ${condition00}  "

reghdfe more_isl  c minority_var c_minor  `covariates' ,   cluster(${sevar00})   noabsorb //

estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"No"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"


eststo

local covariates = " ${covariates00} ${condition00}  "
reghdfe more_isl   minority_var c_minor  `covariates' ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb

estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo


drop *

use ${processed_data_dir}/${final_sample2010s}.dta, clear
merge m:1 id2010 using "${processed_data_dir}/ethnic_shares2010.dta"
keep if _merge==3
drop _merge


/* 2018-2014 */

cap drop c 
cap drop c_minor 
cap drop minority_var
gen minority_var = ${minor14}
gen c=more_corrupt_btw
gen c_minor = more_corrupt_btw*${minor14}



la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption * Minority"

local controls = " ${covariates14} ${condition14}"
local clustervar=" ${sevar14}"

reghdfe d_islamist c  minority_var c_minor  `controls'   , cluster(`clustervar') noabsorb

estadd local outcome "Diff. vote share"
estadd local csignal "Worse audit score"
estadd local districtfe	"No"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe d_islamist   minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 


estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo
esttab using "${results_dir}/main_table_villageethnicshares.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(c  minority_var c_minor  ///
	) ///
	order( c  minority_var c_minor  ///
	) ///
	compress  nonotes ///
	tex ///
		mgroups("1999-2004" "2014-2019", pattern(1 0 1 0)) ///
		nomtitles ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	scalars(		"outcome Dependent variable" ///
			"csignal Corruption signal" ///
			"districtfe District fixed effects" ///
			"ethdummies Ethnic group shares" ///
			"villagecontrols Village controls") ///
	replace  

	
	
