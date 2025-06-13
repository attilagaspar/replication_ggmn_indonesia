/*

	this script checks if alignment with central government predicts 
	local corruption results

	/* Presidents of Indonesia since 2004 */

/*   Susilo Bambang Yudhoyono 2004-09
	 Ticket nominated by: Partai Demokrat, PKPI, PBB
*/
/* Susilo Bambang Yudhoyono 2009-14
	 Ticket nominated by: Partai Demokrat, PKS, PAN, PPP, PKB
*/

/* Jokowi 2014-2019
	 Ticket nominated by: PDI-P, Hanura, NasDem, PKB, PKPI
*/


*/

use "${processed_data_dir}/transparency_indicators_wide.dta", clear

reshape long opinion_numeric, i(district) j(year)

replace district="Kab. Aceh Pidie" if district=="Kab. Pidie"
replace district="Kab. Batanghari" if district=="Kab. Batang Hari"
replace district="Kab. Dharmas Raya" if district=="Kab. Dharmasraya"
replace district="Kab. Fak-Fak" if district=="Kab. Fakfak"
replace district="Kab. Gunung Kidul" if district=="Kab. Gunungkidul"
replace district="Kab. Karang Asem" if district=="Kab. Karangasem"
replace district="Kab. Kep. Siau Tagulandang Biaro (Sitaro)" if district=="Kab. Kep. Siau Tagulandang Biaro"
replace district="Kab. Kepulauan Mentawai" if district=="Kab. Kep. Mentawai"
replace district="Kab. Kota Baru" if district=="Kab. Kotabaru"
replace district="Kab. Labuhan Batu" if district=="Kab. Labuhanbatu"
replace district="Kab. Labuhan Batu Selatan" if district=="Kab. Labuhanbatu Selatan"
replace district="Kab. Labuhan Batu Utara" if district=="Kab. Labuhanbatu Utara"
replace district="Kab. Limapuluh Kota" if district=="Kab. Lima Puluh Kota"
replace district="Kab. Mahakam Hulu" if district=="Kab. Mahakam Ulu"
replace district="Kab. Maluku Tenggara Barat" if district=="Kab. Kepulauan Tanimbar (Maluku Tenggara Barat)"
replace district="Kab. Minahasa Tenggara (Mitra)" if district=="Kab. Minahasa Tenggara"
replace district="Kab. Morotai" if district=="Kab. Pulau Morotai"
replace district="Kab. Pangkajene Kepulauan" if district=="Kab. Pangkajene dan Kepulauan"
replace district="Kab. Pasir" if district=="Kab. Paser"
replace district="Kab. Pontianak" if district=="Kab. Mempawah"
replace district="Kab. Sawahlunto Sijunjung" if district=="Kab. Sijunjung"
replace district="Kab. Selayar" if district=="Kab. Kep. Selayar"
replace district="Kab. Tanah Karo" if district=="Kab. Karo"
replace district="Kab. Toli-Toli" if district=="Kab. Tolitoli"
replace district="Kab. Yapen Waropen" if district=="Kab. Kepulauan Yapen"
replace district="Kota Banjar Baru" if district=="Kota Banjarbaru"
replace district="Kota Bau-bau" if district=="Kota Baubau"
replace district="Kota Gunung Sitoli" if district=="Kota Gunungsitoli"
replace district="Kota Lubuk Linggau" if district=="Kota Lubuklinggau"
replace district="Kota Padang Sidempuan" if district=="Kota Padangsidimpuan"
replace district="Kota Palangkaraya" if district=="Kota Palangka Raya"
replace district="Kota Pangkal Pinang" if district=="Kota Pangkalpinang"
replace district="Kota Pare-Pare" if district=="Kota Pare pare"
replace district="Kota Pekan Baru" if district=="Kota Pekanbaru"
replace district="Kota Pematang Siantar" if district=="Kota Pematangsiantar"
replace district="Kota Tanjung Balai" if district=="Kota Tanjungbalai"
replace district="Kota Tanjung Pinang" if district=="Kota Tanjungpinang"


tempfile transp
save `transp'

use "${raw_data_dir}/district_heads/elections.dta", clear

rename kabupaten_name district

merge 1:1 district year using `transp', gen(merge_transp)

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         3,579
        from master                         0  (merge_transp==1)
        from using                      3,579  (merge_transp==2)

    matched                             5,617  (merge_transp==3)
    -----------------------------------------

	
the election data is not complete coverage so there are instances with no
election data but existing transparency data, as the latter is complete coverage

*/
keep if merge_transp==3

* drop cases where nominating party is unknown
drop if nominating_parties==""
* parse party names
replace nominating_parties=subinstr(nominating_parties,"&",",",.)
split nominating_parties, gen(party) parse(",")

foreach v of varlist party1-party9 {

	replace `v'=strtrim(`v')
	replace `v'="Demokrat" if `v'=="Denokrat"|`v'=="Demokart"|`v'=="Demokrar"|`v'=="Demorkat"
	replace `v'="Gerindra" if `v'=="Derindra"|`v'=="Greindra"
	replace `v'="Hanura" if `v'=="Hanur"
	replace `v'="PDIP" if `v'=="PPDI"

}


gen p_demokrat = 0
gen p_gerindra = 0
gen p_golkar = 0
gen p_nasdem = 0
gen p_pan = 0
gen p_pdip = 0
gen p_pkb = 0
gen p_pks = 0
gen p_ppp = 0
gen p_berkarya = 0
gen p_pbb = 0
gen p_garuda = 0
gen p_hanura = 0
gen p_pkpi = 0
gen p_pbr = 0
foreach v of varlist party1-party9 {

replace  p_demokrat =1 if `v'=="Demokrat"
replace  p_gerindra=1 if `v'=="Gerindra"
replace  p_golkar =1 if `v'=="Golkar"
replace  p_nasdem = 1 if `v'=="Nasdem"
replace  p_pan = 1 if `v'=="PAN"|`v'=="Pan"
replace  p_pdip = 1 if `v'=="PDIP"
replace  p_pkb = 1 if `v'=="PKB"
replace  p_pks = 1 if `v'=="PKS"
replace  p_ppp = 1 if `v'=="PPP"|`v'=="PKNU" // merged
replace  p_berkarya = 1 if `v'=="Berkarya"
replace  p_pbb = 1 if `v'=="PBB"

replace  p_hanura = 1 if `v'=="Hanura"
replace  p_pkpi = 1 if `v'=="PKPI"|`v'=="PKIP"|`v'=="PKP"
replace p_pbr=1 if `v' == "PBR"

}

gen aligned_president = 0
replace aligned_president = 1 if (p_demokrat==1|p_pkpi==1|p_pbb==1)&year>2004&year<2009 // yudhoyono 1
replace aligned_president = 1 if (p_demokrat==1|p_pks==1|p_pan==1|p_ppp==1|p_pkb==1)&year>2009&year<2014 // yudhoyono 2
replace aligned_president = 1 if (p_pdip==1|p_hanura==1|p_nasdem==1|p_pkb==1|p_pkpi==1)&year>2014&year<2019 // yudhoyono 2

gen aligned_cabinet = 0
replace aligned_cabinet = 1 if (p_demokrat==1|p_golkar==1|p_ppp==1|p_pbb==1|p_pkb==1|p_pan==1|p_pkp==1|p_pks==1)&year>2004&year<2014
replace aligned_cabinet = 1 if (p_pdip==1|p_nasdem==1|p_golkar==1|p_hanura==1|p_pkb==1|p_ppp==1|p_pan==1)&year>2014
* drop election years altogether, as election happens mid-year
drop if year==2004|year==2009|year==2014|year>=2019

* drop independents and party aceh
egen anyparty = rowtotal(p_*)
drop if anyparty==0
drop anyparty

* corruption dummy
gen lewis_dummy = 0 if opinion_numeric!=.
replace lewis_dummy = 1 if opinion_numeric>1&opinion_numeric!=.

* alignment
la var opinion_numeric "Corruption 0-3"
la var aligned_president "Aligned"

replace lewis_dummy = 1-lewis_dummy  // Lewis defines dummy as "not corrupt", so we reverse it
eststo clear



* regression in paper 
egen name_group = group(district)
tsset name_group year 
xtreg opinion_numeric aligned_president  i.year if year<2018&year>2004, rob fe
eststo
xtreg lewis_dummy aligned_president  i.year if year<2018&year>2004, rob fe
eststo

esttab using "${results_dir}/audit_favoritism.tex"  ///
	, star(* 0.10 ** 0.05 *** 0.01) staraux ///
	label   ///
	keep(aligned_president  ///
	) ///
	order(aligned_president  ///
	) ///
	compress  nonotes ///
	mtitles ("Corruption (0-3)" "Corruption (D)") ///
	obslast ///
	se  ///
	unstack ///
	replace  ///
	nonumbers ///
	addnotes(" \begin{minipage}{8cm}  \textit{Notes:} The table shows the results from regressing the ącorruption signal of the district on a dummy indicating if the district executive was aligned with the president. Alignment is defined by sharing a nominating party. The dependent variable Column (1) is the audit score on 0-3 scale, in Column (2) it is a dummy indicating that the worst outcomes (2 and 3) Sample: districts from 2005 to 2018 excluding election years (2009 and 2014). Standard errors clustered at district level. Time and district fixed effects included. \end{minipage} ") 






* ez kerül a paperbe
binscatter opinion_numeric year if year>2004&year<2019, ///
absorb(district) by(aligned_president) rd(2009 2014) reportreg msymbol( + circle ) ///
mcolor(black gray) lcolor(black gray) xlabel(2006 2009 2014 2018) legend(label(1 "Not aligned") label(2 "Aligned")) ///
ytitle("Corruption 0-3")

graph export "${results_dir}/audit_favor.png", replace


