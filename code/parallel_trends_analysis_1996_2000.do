use ${processed_data_dir}/${final_sample2000s}.dta, clear

gen d_bs = mb_bs_index2000 - mb_bs_index1996 
gen d_health = mb_health_index2000 - mb_health_index1996 
gen d_educ = mb_educ_index2000 - mb_educ_index1996   

gen bps_2005 = substr(id2005,1,4)
collapse (firstnm) corr1 corr2 corr3 RGDPnoil_2001 (mean) highest_rank_islamist1999 top3_islamists1999 d_bs d_health d_educ mb_bs_index1996 mb_health_index1996 mb_educ_index1996 has_minor2000  muslimshare2000 (sum) population2000, by(bps_2005)
gen log_population00 =log(population2000)
gen log_gdp = log(RGDPnoil_2001)
la var log_population00 "Log(Population), 2000"
la var log_gdp "Log(Regional Domestic Product), 2001"
		
la var mb_bs_index1996 "Basic services index, 1996"
la var mb_educ_index1996 "Education index, 1996"
la var mb_health_index1996 "Healthcare index, 1996"

la var d_bs "Diff. basic services index, 1996-2000"
la var d_educ "Diff. education index, 1996-2000"
la var d_health "Diff. healthcare index, 1996-2000"

la var muslimshare2000 "Share of Muslims"
la var has_minor2000 "Share of Muslim minority villages"
foreach v of varlist corr1 corr2 corr3  top3_islamists1999   {
	reg `v' d_bs mb_bs_index1996 mb_health_index1996 mb_educ_index1996 d_health d_educ  log_population00 log_gdp muslimshare2000  has_minor2000  if corr3!=. , rob
	eststo
}
		
esttab using "${results_dir}/pretrends_1999_2004.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(mb_bs_index1996 mb_health_index1996 mb_educ_index1996 d_bs d_health d_educ  log_population00 log_gdp muslimshare2000  has_minor2000  ///
	) ///
	order(mb_bs_index1996 mb_health_index1996 mb_educ_index1996  d_bs d_health d_educ  log_population00 log_gdp muslimshare2000  has_minor2000  ///
	) ///
	compress  nonotes ///
	tex ///
		mgroups("Corruption" "Islamist support", pattern(1 0 0 1)) ///
		nomtitles ///
	obslast ///
	se(3)  ///
	b(3) ///
	unstack ///
	replace


