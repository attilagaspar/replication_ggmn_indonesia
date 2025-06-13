
use ${processed_data_dir}/${final_sample2010s}.dta, clear

egen i = group(id2013 id2018)


destring own_s* receive_district_support*, force replace

keep i id*  own_source_type* own_source_amount* receive_district_support* mb_bs_index* mb_health_index*  mb_educ_index*  finsupport_amount* has* pop* more_* 
reshape long own_source_type own_source_amount receive_district_support mb_bs_index mb_health_index  mb_educ_index  finsupport_amount, i(i) j(year)
duplicates drop id2009 if year==2008, force
duplicates drop id2010 if year==2011, force
duplicates drop id2013 if year==2014, force

gen has_own_source = .
replace has_own_source=0 if own_source_type==4
replace has_own_source=1 if own_source_type<4

replace receive_district_support=0 if receive_district_support==4
replace receive_district_support=1 if receive_district_support>0&receive_district_support!=.

drop if has_own_source==.|receive_district_support==.


gen dist_support_pc = finsupport_amount
gen own_source_amount_pc = own_source_amount

rename population2010 population2011

foreach n in 2008 2011  {
	
	replace dist_support_pc = dist_support_pc/population`n' if year==`n'
	replace own_source_amount_pc = own_source_amount_pc/population`n' if year==`n'
}


	replace dist_support_pc = dist_support_pc/population2011 if year==2014
	replace own_source_amount_pc = own_source_amount_pc/population2011 if year==2014
	
gen log_dist_support_pc = log(dist_support_pc+1)
gen log_own_source_amount_pc = log(own_source_amount_pc+1)
gen log_dist_support = log(dist_support+1)
gen log_own_source_amount = log(own_source_amount+1)

egen mb_avg = rowmean(mb_bs_index mb_educ_index mb_health_index)
	
gen y = 2008 in 1
replace y = 2011 in 2
replace y = 2014 in 3



   
local depvar1 = "mb_avg"
local yaxis1 = "Government services indices avg."

local depvar2 = "log_dist_support_pc"
local yaxis2 = "Financial aid from district (log)"

local depvar3 = "log_own_source_amount_pc"
local yaxis3 = "Own revenue (log)"


		cap drop tr_*
		local corrvar = "more_corrupt_btw"
		gen tr_status = .
		replace tr_status = 1 if `corrvar'==1
		replace tr_status = 2 if `corrvar'==0

		cap label drop trs
		label define trs 1 "Signal" 2 "No signal"  
		la val tr_status trs

		
		
		forvalues n = 1/3 {
			cap drop beta
			cap drop se
			cap drop ci1 ci2
			reg `depvar`n'' tr_status##i.year , rob
			
			disp _b[2.tr_status#2014.year]
			disp _b[2.tr_status#2011.year]
			
			gen beta=0 in 1
			replace beta = _b[2.tr_status#2011.year] in 2
			replace beta = _b[2.tr_status#2014.year] in 3
			gen se=0 in 1
			replace se = _se[2.tr_status#2011.year] in 2
			replace se = _se[2.tr_status#2014.year] in 3
			gen ci1=beta-1.96*se
			gen ci2=beta+1.96*se
			twoway (line beta y ,  lcolor(black)) ///
					(rcap ci1 ci2 y , lpattern(solid) lcolor(black) ), ///
					  xtitle("Year") ytitle("`yaxis`n''")  ///
					 legend(order( 1 "Difference" 2 "95% CI" )) ///
					 yscale(range(-.1 [.01] 0.1)) ///
					 ylabel(-0.1 -0.05 0 0.05 0.1 )
		*			  ylabel(range(-1 [.1] 1))
					 graph export ${results_dir}/02_04_`corrvar'_2way_pretrend_`n'_`depvar`n''.png, replace
	
		}
