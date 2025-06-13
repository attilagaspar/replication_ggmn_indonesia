* create combined dataset
*net install lincomestadd, from("https://github.com/benzipperer/lincomestadd/raw/master")
cap log close
log using reglog2.txt, replace text
use ${processed_data_dir}/${final_sample2000s}.dta, clear

eststo clear

/* 2004-1999 */

* COLUMN 1
* variables
cap drop c_minor
gen minority_var = ${minor00}
gen c = corr1
gen c_minor = ${minor00}*corr1 

la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption X Minority"


sum distance_to_region2003 if more_isl!=.&c!=., det
local cutoff = `r(p50)'
gen distant = 0 if distance_to_region2003!=.&c!=.
replace distant = 1 if distance_to_region2003!=.&distance_to_region2003>`cutoff'

local covariates = " ${covariates00}    "
reghdfe more_isl  c minority_var c_minor  `covariates' if distant==0 ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb
lincom c + minority_var + c_minor

estadd local di "Below median"
estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo

reghdfe more_isl  c minority_var c_minor  `covariates' if distant==1 ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb
lincom c + minority_var + c_minor

estadd local di "Above median"
estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo

reghdfe more_isl  c minority_var c_minor  `covariates' ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb
lincom c + minority_var + c_minor

estadd local di "Both"
estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo



drop *

use ${processed_data_dir}/${final_sample2010s}.dta, clear

/* 2018-2014 */


sum distance_to_region2018 if d_islamist!=., det
local cutoff = `r(p50)'
gen distant = 0 if distance_to_region2018!=.
replace distant = 1 if distance_to_region2018!=.&distance_to_region2018>`cutoff'



cap drop c 
cap drop c_minor 
cap drop minority_var
gen minority_var = ${minor14}
gen c=more_corrupt_btw
gen c_minor = more_corrupt_btw*${minor14}


la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption * Minority"

local controls = " ${covariates14} "
local clustervar=" ${sevar14}"

reghdfe d_islamist c  minority_var c_minor  `controls'  if distant==1  , cluster(`clustervar') absorb(`clustervar') 
lincom c + minority_var + c_minor

estadd local di "Below median"
estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo



reghdfe d_islamist c  minority_var c_minor  `controls' if distant==0   , cluster(`clustervar') absorb(`clustervar') 
lincom c + minority_var + c_minor

estadd local di "Above median"
estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo

reghdfe d_islamist c  minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 
lincom c + minority_var + c_minor

estadd local di "Both "
estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo

esttab using "${results_dir}/main_table_distance_heterogeneity.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(  minority_var c_minor  ///
	) ///
	order(  minority_var c_minor  ///
	) ///
	compress  nonotes ///
	tex ///
		mgroups("1999-2004" "2014-2019", pattern(1 0 0 1 0 0)) ///
		nomtitles ///
	title("Increase in Islamist support") ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	scalars( "di Distance from district center" ///	
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
	