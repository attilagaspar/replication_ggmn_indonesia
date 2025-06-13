/*

Tables A14, A18

*/

use ${processed_data_dir}/${final_sample2010s}.dta, clear


gen small = 0 if opinion_numeric2014!=.
gen medium = 0 if opinion_numeric2014!=.
gen severe = 0 if opinion_numeric2014!=.

replace small = 1 if opinion_numeric2014==1
replace medium = 1 if opinion_numeric2014==2
replace severe = 1 if opinion_numeric2014==3

la var small "Modest irregularities"
la var medium "Medium irregularities"
la var severe "Severe irregularities"

gen minor_small = has_minor2010 * small
gen minor_medium = has_minor2010 * medium
gen minor_severe = has_minor2010 * severe

la var minor_small "Modest X Minority"
la var minor_medium "Medium X Minority"
la var minor_severe "Severe X Minority"

la var has_minor2010 "Minority village" 

eststo clear
foreach v of varlist gets_aid   aid_pc_std {

reg `v'  small medium severe has_minor2010 minor_small minor_medium minor_severe lpop mb_*index2011	if d_islamist!=., cluster(${sevar14}) 
eststo

}

esttab using "${results_dir}/supplement_table_transfers.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(  small medium severe has_minor2010 minor_small minor_medium minor_severe  ///
	) ///
	order(   small medium severe has_minor2010 minor_small minor_medium minor_severe  ///
	) ///
	compress  nonotes ///
	tex ///	
		mtitles("Receives transfers" "Amount received (sd units)" ) ///
	title("Association between district corruption signals and financial transfers to villages") ///
	addnotes(" \begin{minipage}{16cm}  \textit{Notes:} The table shows differential support from district governments by minority support and financial transparency. In Column 1 the outcome is a dummy indicating that the village received transfers from the district government. In Column 2 the outcome is the amount of support received in standard deviation units. The controls include logarithm of population in 2010, and the value of three public good indices in 2011 (healthcare, education, basic services). Standard errors are clustered at the district level (*: 10\%, **: 5\%, ***: 1\%.). \end{minipage} ") ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	replace  

	

eststo clear


*Villages are not different in terms of their cces to informaton

bysort has_minor2018 :   eststo: estpost summarize access2018* no_mobile_data if d_islamist!=. 


esttab using ${results_dir}/supplement_table_access.tex, replace nodepvar  cells("mean (fmt(2)) sd (fmt(2)) ") ///
	addnotes(" \begin{minipage}{16cm}  \textit{Notes:} The table shows media access by minority status in 2018. \end{minipage} ") ///
	label
