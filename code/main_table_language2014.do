* create combined dataset
*net install lincomestadd, from("https://github.com/benzipperer/lincomestadd/raw/master")
cap log close
log using reglog2.txt, replace text
use ${processed_data_dir}/${final_sample2010s}.dta, clear




preserve
	drop if language2018==""
	collapse (sum) population2010, by(kab_code language2018) 
	drop if population==0
	egen max_pop = max(population), by(kab_code)
	keep if max_pop==population
	gen speaks_main_language = 1
	keep speaks_main_language kab_code language2018
	tempfile lang
	save `lang'
restore

merge m:1 kab_code language2018 using `lang', gen(merge_main_lang)
replace speaks_main_language=0 if speaks_main_language==.


eststo clear

 
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

local controls = " ${covariates14} "
local clustervar=" ${sevar14}"



reghdfe d_islamist   minority_var c_minor  `controls'  if speaks_main_language==0|${minor14}==0  , cluster(`clustervar') absorb(`clustervar') 

estadd local fracsample "No" 

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe d_islamist   minority_var c_minor  `controls'  if speaks_main_language==1|${minor14}==0  , cluster(`clustervar') absorb(`clustervar') 

estadd local fracsample "Yes" 	

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo

reghdfe d_islamist   minority_var c_minor  `controls'    , cluster(`clustervar') absorb(`clustervar') 

estadd local fracsample "Both" 

estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo



esttab using "${results_dir}/main_table_language10s.tex"  ///
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
	scalars("fracsample Same language " ///		
	"outcome Dependent variable" ///
			"csignal Corruption signal" ///
			"districtfe District fixed effects" ///
			"ethdummies Ethnic group dummies" ///
			"villagecontrols Village controls") ///
	replace  
	
