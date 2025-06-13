
use ${processed_data_dir}/${final_sample2000s}.dta, clear

la var log_population00 "Log(Population)"
la var log_dist00 "Log(Distance from district center)"
la var muslimshare2000 "Share of Muslims"
la var top3_islamists1999 "Islamists in Top3 most popular 1999"
la var top3_islamists2004 "Islamists in Top3 most popular 2004"
la var more_isl "Islamists more popular from 1999 to 2004"

la var mb_bs_index2000 "Basic services index (2000)"
la var mb_educ_index2000 "Education index (2000)"
la var mb_health_index2000 "Healthcare index (2000)"

la var corr_case "Had corruption scandal by 2004"
la var corr_cases "Average corruption case count by 2004"
la var log_value_std "Value corrupted (standardized)"

replace has_minor2004 = 1-has_minor2004
label define minor 1 "Not minority" 0 "Minority"
la val has_minor2004 minor

gen samp = 1
foreach v of varlist log_population00 log_dist00  muslimshare2000  mb_bs_index2000 mb_educ_index2000 mb_health_index2000  top3_islamists1999 top3_islamists2004 more_isl corr_case corr_cases log_value_std has_minor2004 {
	
	replace samp=0 if `v'==.
}

keep if samp==1

eststo clear
bysort has_minor2004: eststo: estpost summarize log_population00 log_dist00  muslimshare2000  mb_bs_index2000 mb_educ_index2000 mb_health_index2000  top3_islamists1999 top3_islamists2004 more_isl corr_case corr_cases log_value_std 
esttab using ${results_dir}/desc2_2000.tex, replace nodepvar  cells("mean (fmt(2)) sd (fmt(2)) ") ///
	refcat(log_population00 "\emph{\textbf{Panel A: Basic characteristics}}" /// on182 "\emph{\underline{Original categories}}" ///
	top3_islamists1999 "\emph{\textbf{Panel B: Village political preferences}}" ///
	corr_case "\emph{\textbf{Panel C: Corruption in the district}}" ///
	,nolabel) ///
	addnotes(" \begin{minipage}{16cm}  \textit{Notes:} The table shows descriptive statistics by village groups. The first column corresponds to villages where the majority of the population is at the same time member of an ethnic minority and is Muslim. The second column corresponds to all other villages (not exclusively, but mostly members of the ethnic majority). The sample includes all villages from PODES 2000 and PODES 2005 which were able to link \end{minipage} ") ///
	label 




use ${processed_data_dir}/${final_sample2010s}.dta, clear

* create variables that are only here

gen lewis_dummy2008=0 if opinion_numeric2008!=.
replace lewis_dummy2008=1 if opinion_numeric2008>1&opinion_numeric2008!=. 

gen lewis_dummy2013=0 if opinion_numeric2013!=.
replace lewis_dummy2013=1 if opinion_numeric2013>1&opinion_numeric2013!=. 

replace lewis_dummy2008 = 1 - lewis_dummy2008
replace lewis_dummy2013 = 1 - lewis_dummy2013

gen gets_aid2014=.
replace gets_aid2014=0 if aid_from_district2014==0
replace gets_aid2014=1 if aid_from_district2014>0&aid_from_district2014!=.

* set sample
keep if voteshare_islamist2014!=.  // means that vote exists
keep if lpop!=.  // means that podes is merged 
keep if lewis_dummy2018!=. // means that transparency indicators were succesfully merged

la var lpop "Log(Population)"
la var log_dist "Log(Distance from district center)"
la var gets_aid2014 "Gets aid from district in 2014"
la var log_aid2014 "Log(Aid from district in 2014)"
la var muslimshare "Share of Muslims"
la var voteshare_islamist2014 "Voteshare of Islamist parties in 2014"
la var voteshare_islamist2019 "Voteshare of Islamist parties in 2019"
la var lewis_dummy2018 "Corruption (dummy) 2018"
la var lewis_dummy2013 "Corruption (dummy) 2013"
la var lewis_dummy2008 "Corruption (dummy) 2008"
la var opinion_numeric2018 "Budget quality in 2018"
la var opinion_numeric2013 "Budget quality in 2013"
la var opinion_numeric2008 "Budget quality in 2008 (0: least corrupt, 3: most corrupt)"
la var mb_bs_index2014 "Basic services index (2014)"
la var mb_educ_index2014 "Education index (2014)"
la var mb_health_index2014 "Healthcare index (2014)"

replace has_minor2010 = 1-has_minor2010
label define minor 1 "Not minority" 0 "Minority"
la val has_minor2010 minor



eststo clear
bysort has_minor2010: eststo: estpost summarize lpop log_dist muslimshare ///
gets_aid2014 log_aid2014 mb_bs_index2014 mb_educ_index2014 mb_health_index2014 voteshare_islamist2014 voteshare_islamist2019 ///
 opinion_numeric2008 opinion_numeric2013 opinion_numeric2018 
esttab using ${results_dir}/desc2_2014.tex, replace nodepvar  cells("mean (fmt(2)) sd (fmt(2)) ") ///
	refcat(lpop "\emph{\textbf{Panel A: Basic characteristics}}" /// on182 "\emph{\underline{Original categories}}" ///
	voteshare_islamist2014 "\emph{\textbf{Panel B: Village political preferences}}" ///
	opinion_numeric2008 "\emph{\textbf{Panel C: Corruption in the district}}" ///
	,nolabel) ///
	addnotes(" \begin{minipage}{16cm}  \textit{Notes:} The table shows descriptive statistics by village groups. The first column corresponds to villages where the majority of the population is at the same time member of an ethnic minority and is Muslim. The second column corresponds to all other villages (not exclusively, but mostly members of the ethnic majority). The sample includes all villages for which village level election results were available both in 2014 and 2019, and for which we were able to link PODES 2014 and PODES 2019 records. \end{minipage} ") ///
	label 

