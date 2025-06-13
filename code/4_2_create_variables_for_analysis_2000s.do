/* data generation for 1999-2004 regressions */

clear
clear matrix
clear mata
set maxvar 10000

use ${processed_data_dir}/podes_panel96_05.dta, clear

destring podes2008_kab, gen(x)
gen kota=0
replace kota=1 if x>69&x!=.

gen name09 = proper(podes2008_nama_kab)
replace name09 = "Kota " + name09 if kota==1
replace name09 = "Kab. " + name09 if kota==0
replace name09="Kab. Batanghari"	if name09=="Kab. Batang Hari"
replace name09="Kab. Limapuluh Kota"	if name09=="Kab. Lima Puluh Kota"
replace name09="Kab. Pangkajene Kepulauan"	if name09=="Kab. Pangkajene Dan Kepulauan"
replace name09="Kab. Pasir"	if name09=="Kab. Paser"
replace name09="Kab. Sawahlunto Sijunjung"	if name09=="Kab. Sawahlunto/Sijunjung"
replace name09="Kab. Tulang Bawang"	if name09=="Kab. Tulangbawang"
replace name09="Kota Palangkaraya"	if name09=="Kota Palangka Raya"
replace name09="Kota Pekan Baru"	if name09=="Kota Pekanbaru"
replace name09="Kota Sawahlunto"	if name09=="Kota Sawah Lunto"
replace name09="Kab. Aceh Pidie" if name09=="Kab. Pidie" 
replace name09="Kab. Fak-Fak" if name09=="Kab. Fakfak"


merge m:1 name09 using "${raw_data_dir}/gg/govandgrowth_distribution.dta", gen(merge_gg) keepusing(COREX2 CORN2 CORV2  RGDPnoil_2001)  // merge corruption variables from Growth and governance dataset
drop if merge_gg==2

* we drop Aceh from the analysis sample which was in open rebellion at the time
drop if substr(id2000,1,2)=="11"


merge m:1 id2000 using ${processed_data_dir}/census2000.dta, gen(merge2000)
drop if merge2000==2  // not in podes

/*
	
	
	previous election cycle

*/


* merge cencus ethnicity shares


merge m:1 id2000 using ${processed_data_dir}/ethnic_shares2000.dta, gen(merge_ethnicshares2000)
drop if merge_ethnicshares2000==2  // missing from podes

*create ethnic dummies 

foreach v of varlist popshare* {
	
	qui gen c`v' = ceil(`v')
	* only consider popuations with at least 1 pct of population share
	replace c`v' = 0 if `v'<=0.01
	
}

rename cpopshare* ethn2004_*


cap drop  district00*
cap drop population03
gen district00 = substr(id2000,1,4)
egen district00_pop = total(population2000) if podes2003_b17r1701a!="", by(district00)


* political outcomes

rename podes2003_b17r1701a  party1999_1 
rename podes2003_b17r1701b  party1999_2
rename podes2003_b17r1701c  party1999_3

local n = 0
foreach v of varlist party1999_1 party1999_2 party1999_3 {
		replace `v'=strtrim(`v')
		local n = `n'+1
		
		gen islamist1999_`n'=0 if `v'!=""
		replace islamist1999_`n'=1  if `v'=="09" //"PPP"
		replace islamist1999_`n'=1  if `v'=="21" // "Masyumi"
		replace islamist1999_`n'=1  if `v'=="22" //"PBB"
		replace islamist1999_`n'=1  if `v'=="24"  //PKS, called PK at the time

}

rename podes2005_r12011k2 party2004_1
rename  podes2005_r12012k2 party2004_2 
rename  podes2005_r12013k2 party2004_3
rename  podes2005_r12014k2 party2004_4
rename  podes2005_r12015k2 party2004_5
gen islamist2004_1 =0 if party2004_1!=.
gen islamist2004_2 =0 if party2004_1!=.
gen islamist2004_3 =0 if party2004_1!=.
gen islamist2004_4 =0 if party2004_1!=.
gen islamist2004_5 =0 if party2004_1!=.
replace islamist2004_1=1 if party2004_1==16|party2004_1==3|party2004_1==5
replace islamist2004_2=1 if party2004_2==16|party2004_2==3|party2004_2==5
replace islamist2004_3=1 if party2004_3==16|party2004_3==3|party2004_3==5
replace islamist2004_4=1 if party2004_4==16|party2004_4==3|party2004_4==5
replace islamist2004_5=1 if party2004_5==16|party2004_5==3|party2004_5==5


* treatment var: the highest rank that islamists achieved increases
gen more_islamist=0 if islamist1999_1!=.&islamist2004_1!=. // consider cases only where election result is known
replace more_islamist=1 if (islamist1999_1==0&islamist1999_2==0&islamist1999_3==0)&(islamist2004_1==1|islamist2004_2==1|islamist2004_3==1)  // no islamist in top3 in 1999, islamist in top3 in 2004
replace more_islamist=1 if (islamist1999_1==0&islamist1999_2==0&islamist1999_3==1)&(islamist2004_1==1|islamist2004_2==1)  // islamist is 3rd in 1999, either 2nd or 1st in 2004
replace more_islamist=1 if (islamist1999_1==0&islamist1999_2==1)&(islamist2004_1==1)  // islamist is 2nd in 1999 and 1st in 2004


* corruption variables from GG dataset
gen corr_trial = 0 if merge_gg==3
replace corr_trial = 1 if COREX2!=.&COREX2!=0

gen corr_cases = 0 if merge_gg==3
replace corr_cases = CORN2 if CORN2!=.
gen log_corr_cases = log(corr_cases+1)

gen corr_case = 0 if corr_cases!=.
replace corr_case = 1 if corr_cases>0&corr_cases!=.

gen log_corr_value = log(CORV2) if merge_gg==3
replace log_corr_value = 0 if merge_gg==3&log_corr_value==.

gen log_population05 = log(podes2005_r401a+podes2005_r401b)
gen poorletter_share05 = podes2005_r606/(podes2005_r401a+podes2005_r401b)
 
gen log_population00 = log(podes2000_b4ar2a)
 
preserve
	keep name09 CORV2 merge_gg
	duplicates drop
	replace CORV2=0 if CORV2==.&merge_gg==3 // there are no zeros in the data but missings where there is no corruption value
	egen value_std = std(CORV2) 
	egen log_value_std = std(log(CORV2+1)) 
	drop CORV2  
	tempfile value_st
	save `value_st'
restore

merge m:1 name09 using `value_st', gen(merge_valuestd)

gen corr1 = corr_case
gen corr2 = corr_cases
gen corr3 = log_value_std 

gen minor_corr1 = has_minor2004*corr_case
gen minor_corr2 = has_minor2004*corr_cases
gen minor_corr3 = has_minor2004*log_value_std 

gen later_split = 0
replace later_split=1 if substr(idpodes08,1,4)!=substr(id2005,1,4)



gen log_dist00 = log(podes2000_b3r12+0.01)

gen highest_rank_islamist1999=0 if islamist1999_1!=.
replace highest_rank_islamist1999=3 if islamist1999_3==1
replace highest_rank_islamist1999=2 if islamist1999_2==1
replace highest_rank_islamist1999=1 if islamist1999_1==1

gen highest_rank_islamist2004=0 if islamist2004_1!=.
replace highest_rank_islamist2004=5 if islamist2004_5==1
replace highest_rank_islamist2004=4 if islamist2004_4==1
replace highest_rank_islamist2004=3 if islamist2004_3==1
replace highest_rank_islamist2004=2 if islamist2004_2==1
replace highest_rank_islamist2004=1 if islamist2004_1==1

egen top3_islamists1999=rowmax(islamist1999_*)
egen top3_islamists2004=rowmax(islamist2004_1 islamist2004_2 islamist2004_3)


* variables for additional analysis
gen distance_to_region2003 = podes2003_b3r314 

* final touches

* podes is propriety data, drop variables that are not used
drop podes*
qui compress
save ${processed_data_dir}/${final_sample2000s}.dta, replace

