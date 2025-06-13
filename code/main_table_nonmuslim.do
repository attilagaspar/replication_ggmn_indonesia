* create combined dataset
*net install lincomestadd, from("https://github.com/benzipperer/lincomestadd/raw/master")
cap log close
log using reglog.txt, replace text
use ${processed_data_dir}/${final_sample2000s}.dta, clear

eststo clear

/* 2004-1999 */
gen bps_2005=substr(id2003,1,4)
* COLUMN 1
* variables

* non-muslim minority variable

gen non_muslim_minority_share = minority_share2004 - muslim_minority_villshare2004 
gen non_muslim_minority = 0 if non_muslim_minority_share!=.
replace non_muslim_minority = 1 if non_muslim_minority_share>.5&non_muslim_minority_share<=1

* protest vote

gen demokrat = 0 if party2004_1!=.
replace demokrat = 1 if party2004_1==9
replace demokrat = 1 if party2004_2==9
replace demokrat = 1 if party2004_3==9



cap drop c_minor
gen minority_var = non_muslim_minority
gen c = corr1
gen c_minor = non_muslim_minority*corr1 

la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption X Minority"


local covariates = " ${covariates00} ${condition00} "
reghdfe more_isl   minority_var c_minor  `covariates' ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb

estadd local outcome "Islamist support grows (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo

reghdfe demokrat   minority_var c_minor  `covariates' ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb

estadd local outcome "Partai Demokrat in Top3 (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo


drop *

use ${processed_data_dir}/${final_sample2010s}.dta, clear

/* 2018-2014 */

* protest vote

gen psi = party_PSI / totalvotes_desa
gen d_nasdem = (party_Nasdem/totalvotes_desa) - (vote_nasdem2014 / allvotes2014)

* non-muslim minority variable

gen non_muslim_minority_share = minority_share2018 - muslim_minority_villshare2018 
gen non_muslim_minority = 0 if non_muslim_minority_share!=.
replace non_muslim_minority = 1 if non_muslim_minority_share>.5&non_muslim_minority_share<=1


cap drop c 
cap drop c_minor 
cap drop minority_var
gen minority_var = non_muslim_minority
gen c=more_corrupt_btw
gen c_minor = more_corrupt_btw*non_muslim_minority


la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption * Minority"

local controls = " ${covariates14} ${condition14}"
local clustervar=" ${sevar14}"


reghdfe d_islamist   minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 

estadd local outcome "$Delta$ Islamist vs.%" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe psi   minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 

estadd local outcome "PSI vs.%" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe d_nasdem   minority_var c_minor  `controls'   , cluster(`clustervar') absorb(`clustervar') 

estadd local outcome "$Delta$ NasDem vs.%" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo

esttab using "${results_dir}/main_table_nonmuslim.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(  minority_var c_minor  ///
	) ///
	order(   minority_var c_minor  ///
	) ///
	compress  nonotes ///
	tex ///
		mgroups("1999-2004" "2014-2019", pattern(1 0 1 0)) ///
		nomtitles ////// title("Increase in Islamist support") ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	scalars(		"outcome Dependent variable" ///
			"csignal Corruption signal" ///
			"districtfe District fixed effects" ///
			"ethdummies Ethnic group dummies" ///
			"villagecontrols Village controls") ///
	replace  

	
	
