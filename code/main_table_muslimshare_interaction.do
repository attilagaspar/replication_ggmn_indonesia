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
cap drop c_minor
gen minority_var = ${minor00}
gen c = corr1
gen c_minor = ${minor00}*corr1 

la var c "Corruption"
la var minority_var "Minority village"
la var c_minor "Corruption X Minority"

gen ms = muslimshare2000
gen muslim2 = muslimshare2000^2
gen muslimc = muslimshare2000*c 
gen muslimc2 = muslim2*c

la var muslimshare "MuslimShare"
la var muslim2 "MuslimShare^2"
la var muslimc "Corruption X MuslimShare "
la var muslimc2 "Corruption X MuslimShare^2 "

local covariates = " ${covariates00}  ${condition00}  "

reghdfe more_isl  c minority_var c_minor ms muslim2 muslimc muslimc2 `covariates' ,   cluster(${sevar00})   noabsorb //
lincom c + c_minor






estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"No"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"




eststo

local covariates = " ${covariates00} ${condition00} "
reghdfe more_isl  c minority_var c_minor ms muslim2 muslimc muslimc2 `covariates' ,   cluster(${sevar00})   absorb(${sevar00}) //noabsorb
lincom c + minority_var + c_minor


estadd local outcome "Rank increased (Dummy)"
estadd local csignal "Corruption scandal"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"

eststo


drop *

use ${processed_data_dir}/${final_sample2010s}.dta, clear

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

cap drop ms muslim2 muslimc muslimc2 
gen ms = muslimshare
gen muslim2 = muslimshare^2
gen muslimc = muslimshare*c 
gen muslimc2 = muslim2*c


la var ms "MuslimShare"
la var muslim2 "MuslimShare^2"
la var muslimc "Corruption X MuslimShare "
la var muslimc2 "Corruption X MuslimShare^2 "


local controls = " ${covariates14} ${condition14}"
local clustervar=" ${sevar14}"

reghdfe d_islamist c  minority_var c_minor ms muslim2 muslimc muslimc2 `controls'   , cluster(`clustervar') noabsorb
lincom c + minority_var + c_minor

estadd local outcome "Diff. vote share"
estadd local csignal "Worse audit score"
estadd local districtfe	"No"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo


reghdfe d_islamist c  minority_var c_minor ms muslim2 muslimc muslimc2 `controls'   , cluster(`clustervar') absorb(`clustervar') 
lincom c + minority_var + c_minor

*lincom c + minority_var + c_minor

*lincomestadd c + minority_var + c_minor, statname(sumcoef)



estadd local outcome "Diff. vote share" 
estadd local csignal "Worse audit score"
estadd local districtfe	"Yes"
estadd local ethdummies	"Yes"
estadd local villagecontrols	"Yes"
eststo
esttab using "${results_dir}/main_table_ms_interaction${suffix}.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(c  minority_var c_minor  ms muslim2 muslimc muslimc2 ///
	) ///
	order( c  minority_var c_minor ms muslim2 muslimc muslimc2  ///
	) ///
	compress  nonotes ///
	tex ///
		mgroups("1999-2004" "2014-2019", pattern(1 0 1 0)) ///
		nomtitles ///
	title("Increase in Islamist support") ///
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

	
*1000rel több megfigyelés van 2004ben és nem szigni az egyik oszlop

	
/*

mgroups("1999-2004" "2014-2019", pattern(1 1)) ///
	nomtitles ///

	///
	nonumbers
	