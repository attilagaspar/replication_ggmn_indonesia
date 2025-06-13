/*
this sript creates a hand-cleaned, exact match between podes 2014 districts and 
subdistricts and subdistrict level election results


input: scraped election data from here:
			 https://pemilu2014.kpu.go.id/da1_dprd2.php
hand-matched with podes

1. merge subdistrict level results to PODES ID (exactly hand-matched each of the 7000)

2. merge village level results PODES ID (hand-cleaned + fuzzy)

3. save

*/


/*  subdistrict level results */


use "${raw_data_dir}/election2014_by_kecamatan_dapil_candidate/subdistrict_party_candidate_vote14.dta", clear



keep if candidate_id == "party_summary"
drop name
rename party_name_name party_name


gen pc = 0
replace pc = 1 if party_name=="PARTAI ACEH"
replace pc = 2 if party_name=="PARTAI AMANAT NASIONAL"
replace pc = 3 if party_name=="PARTAI BULAN BINTANG"
replace pc = 4 if party_name=="PARTAI DAMAI ACEH"
replace pc = 5 if party_name=="PARTAI DEMOKRASI INDONESIA PERJUANGAN"
replace pc = 6 if party_name=="PARTAI DEMOKRAT"
replace pc = 7 if party_name=="PARTAI GERAKAN INDONESIA RAYA"
replace pc = 8 if party_name=="PARTAI GOLONGAN KARYA"
replace pc = 9 if party_name=="PARTAI HATI NURANI RAKYAT"
replace pc = 10 if party_name=="PARTAI KEADILAN DAN PERSATUAN INDONESIA"
replace pc = 11 if party_name=="PARTAI KEADILAN SEJAHTERA"
replace pc = 12 if party_name=="PARTAI KEBANGKITAN BANGSA"
replace pc = 13 if party_name=="PARTAI NASDEM"
replace pc = 14 if party_name=="PARTAI NASIONAL ACEH"
replace pc = 15 if party_name=="PARTAI PERSATUAN PEMBANGUNAN"



drop party_name
drop list_id candidate_id

egen i = group(province_name district_name constituency_name subdistrict_name)


drop *_homepage_id 



reshape wide votes, i(i) j(pc)



rename votes1 vote_partai_aceh
rename votes2 vote_pan
rename votes3 vote_pbb
rename votes4 vote_pd_aceh
rename votes5 vote_pdip
rename votes6 vote_demokrat
rename votes7 vote_gerindra
rename votes8 vote_golkar
rename votes9 vote_hanura
rename votes10 vote_pkp
rename votes11 vote_pks
rename votes12 vote_pkb
rename votes13 vote_nasdem
rename votes14 vote_pn_aceh
rename votes15 vote_ppp

egen allvotes = rowtotal(vote_*)
gen vote_missing = 0
replace vote_missing = 1 if allvotes==0


egen vote_islamist = rowtotal( vote_ppp vote_pks vote_pbb )
gen voteshare_islamist = vote_islamist / allvotes


order province_name district_name constituency_name subdistrict_name


drop i

rename vote* vote*_subdist2014
rename allvotes allvotes_in_subdist2014


save "${processed_data_dir}/election2014_reshaped_subdist.dta", replace


/*

		collapse raw electio data to	village level 

*/


use "${raw_data_dir}/election2014_by_village_dapil_candidate/village_party_candidate_vote14.dta", clear
* this script collapses raw data to 2014 party list data by village



keep if candidate_id == "party_summary"
drop name
rename party_name_name party_name


/*
                            PARTAI ACEH |     89,528        6.67        6.67
                 PARTAI AMANAT NASIONAL |     89,538        6.67       13.33
                   PARTAI BULAN BINTANG |     89,539        6.67       20.00
                      PARTAI DAMAI ACEH |     89,528        6.67       26.67
  PARTAI DEMOKRASI INDONESIA PERJUANGAN |     89,539        6.67       33.33
                        PARTAI DEMOKRAT |     89,540        6.67       40.00
          PARTAI GERAKAN INDONESIA RAYA |     89,540        6.67       46.67
                  PARTAI GOLONGAN KARYA |     89,540        6.67       53.33
              PARTAI HATI NURANI RAKYAT |     89,537        6.67       60.00
PARTAI KEADILAN DAN PERSATUAN INDONESIA |     89,534        6.67       66.67
              PARTAI KEADILAN SEJAHTERA |     89,536        6.67       73.33
              PARTAI KEBANGKITAN BANGSA |     89,540        6.67       80.00
                          PARTAI NASDEM |     89,541        6.67       86.67
                   PARTAI NASIONAL ACEH |     89,528        6.67       93.33
           PARTAI PERSATUAN PEMBANGUNAN |     89,540        6.67      100.00
*/

gen pc = 0
replace pc = 1 if party_name=="PARTAI ACEH"
replace pc = 2 if party_name=="PARTAI AMANAT NASIONAL"
replace pc = 3 if party_name=="PARTAI BULAN BINTANG"
replace pc = 4 if party_name=="PARTAI DAMAI ACEH"
replace pc = 5 if party_name=="PARTAI DEMOKRASI INDONESIA PERJUANGAN"
replace pc = 6 if party_name=="PARTAI DEMOKRAT"
replace pc = 7 if party_name=="PARTAI GERAKAN INDONESIA RAYA"
replace pc = 8 if party_name=="PARTAI GOLONGAN KARYA"
replace pc = 9 if party_name=="PARTAI HATI NURANI RAKYAT"
replace pc = 10 if party_name=="PARTAI KEADILAN DAN PERSATUAN INDONESIA"
replace pc = 11 if party_name=="PARTAI KEADILAN SEJAHTERA"
replace pc = 12 if party_name=="PARTAI KEBANGKITAN BANGSA"
replace pc = 13 if party_name=="PARTAI NASDEM"
replace pc = 14 if party_name=="PARTAI NASIONAL ACEH"
replace pc = 15 if party_name=="PARTAI PERSATUAN PEMBANGUNAN"



drop party_name
drop list_id candidate_id

egen i = group(province_name district_name constituency_name subdistrict_name village_name)

sort i

/* Duplicates entries generated by scraping error */
duplicates tag i pc, gen(t)
drop if t==1&votes==0
duplicates drop i pc, force

* Scraped columns from KPU homepage that block reshape
drop province_homepage_id district_homepage_id constituency_homepage_id subdistrict_homepage_id t


reshape wide votes, i(i) j(pc)



rename votes1 vote_partai_aceh
rename votes2 vote_pan
rename votes3 vote_pbb
rename votes4 vote_partai_damai_aceh
rename votes5 vote_pdip
rename votes6 vote_demokrat
rename votes7 vote_gerindra
rename votes8 vote_golkar
rename votes9 vote_hanura
rename votes10 vote_pkp
rename votes11 vote_pks
rename votes12 vote_pkb
rename votes13 vote_nasdem
rename votes14 vote_partai_nasional_aceh
rename votes15 vote_ppp

egen allvotes = rowtotal(vote_*)
gen vote_missing = 0
replace vote_missing = 1 if allvotes==0


egen vote_islamist = rowtotal( vote_ppp vote_pks vote_pbb )
gen voteshare_islamist = vote_islamist / allvotes

drop if vote_partai_aceh!=.&province_name=="PAPUA BARAT" // adathiba

save "${processed_data_dir}/election2014_reshaped_village.dta", replace


/*


	merge to PODES ID-s
	

*/


* hand-cleaned constituency names for podes
import excel "${raw_data_dir}/election2014_by_kecamatan_dapil_candidate/kecamatan_podes_to_election_handclean.xlsx", ///
	sheet("Sheet2") cellrange(A2:D441) firstrow clear

*drop C F G
tempfile hand_cleaned
save `hand_cleaned'

* election

*use ../data/consistent/election2014_reshaped_subdist.dta, clear
use "${processed_data_dir}/election2014_reshaped_subdist.dta", clear

gen distname_match=district_name 
gen subdistname_match=subdistrict_name
* use of spaces and other signs is inconsistent across data sets, we get rid of them in both ends
replace subdistname_match = subinstr(subdistname_match, " ", "", .)
replace distname_match = subinstr(distname_match, " ", "", .)
replace distname_match = subinstr(distname_match, "-", "", .)

* collapse needed
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="KINTAMANI-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="KINTAMANI-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="TANJUNGPANDAN-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="TANJUNGPANDAN-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="MANDAU-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="MANDAU-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="KAIMANA-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="KAIMANA-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="YAPENSELATAN-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="YAPENSELATAN-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="SIRIMAU-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="SIRIMAU-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="CIMAHISELATAN-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="CIMAHISELATAN-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="CIMAHITENGAH-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="CIMAHITENGAH-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="DENPASARBARAT-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="DENPASARBARAT-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="TAMAN-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="TAMAN-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="MAGERSARI-A"	
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="MAGERSARI-B"	
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="JEKANRAYA-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="JEKANRAYA-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="SERANG-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="SERANG-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="BANJARSARI-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="BANJARSARI-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="ARUTSELATAN-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="ARUTSELATAN-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="SUNGAIRAYA-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="SUNGAIRAYA-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="SANGATTAUTARA-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="SANGATTAUTARA-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="TORGAMBA-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="TORGAMBA-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="MERAUKE-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="MERAUKE-B"
replace subdistname_match=subinstr(subdistname_match,"-A","",.)	if subdistname_match=="MIMIKABARU-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="MIMIKABARU-B"
replace subdistname_match=subinstr(subdistname_match,"-C","",.)	if subdistname_match=="MIMIKABARU-C"
replace subdistname_match=subinstr(subdistname_match,"-A","",.) if subdistname_match=="NABIRE-A"
replace subdistname_match=subinstr(subdistname_match,"-B","",.)	if subdistname_match=="NABIRE-B"


collapse (sum) vote_partai_aceh_subdist2014 vote_pan_subdist2014 vote_pbb_subdist2014  ///
vote_pd_aceh_subdist2014 vote_pdip_subdist2014 vote_demokrat_subdist2014   ///
vote_gerindra_subdist2014 vote_golkar_subdist2014 vote_hanura_subdist2014   ///
vote_pkp_subdist2014 vote_pks_subdist2014 vote_pkb_subdist2014   ///
vote_nasdem_subdist2014 vote_pn_aceh_subdist2014 vote_ppp_subdist2014   ///
male_voters_in_subdist female_voters_in_subdist total_voters_in_subdist   ///
male_turnout_in_subdist female_turnout_in_subdist total_turnout_in_subdist   ///
(first) allvotes_in_subdist2014 vote_missing_subdist2014 vote_islamist_subdist2014  ///
province_name district_name subdistrict_name  distname_match  ///
, by(subdistname_match)

tempfile elect
save `elect'


* load podes to get id-s

use "${processed_data_dir}/podes_panel08_18.dta", clear 

keep id2018_1 name2018_1   podes2014_name_dist podes2014_name_subdist
gen distname_match=podes2014_name_dist 
gen subdistname_match=podes2014_name_subdist




* cleaning some district names
replace distname_match = "BATAM" if distname_match=="B A T A M"
replace distname_match = "SIAK" if distname_match=="S I A K"

* Urban regencies do not have "KOTA" in their name in podes, but they do in the election data
gen iskota = 0
replace iskota=1 if substr(id2018_1,3,1)=="7"

replace distname_match = "KOTA " + distname_match if iskota==1
* use of spaces and other signs is inconsistent across data sets, we get rid of them in both ends

replace subdistname_match = subinstr(subdistname_match, " ", "", .)
replace subdistname_match = subinstr(subdistname_match, "-", "", .)

replace distname_match = subinstr(distname_match, " ", "", .)
replace distname_match = subinstr(distname_match, "-", "", .)


replace distname_match = "KEP.SIAUTAGULANDANGBIARO" if distname_match=="SIAUTAGULANDANGBIARO"


merge m:1 distname_match subdistname_match using  `hand_cleaned', gen(merge_clean_list)

replace subdistname_match=subdist_in_election if merge_clean_list==3
replace distname_match=dist_in_election if merge_clean_list==3

drop dist_in_election subdist_in_election merge_clean_list



merge m:1 distname_match subdistname_match using  `elect', gen(merge_subdist_elect2014)

drop if merge_subdist_elect2014==2


******************
gen village_name = name2018_1  
gen kecamatan_name_master=podes2014_name_subdist 
replace village_name=subinstr(village_name, char(34),"",.)
replace village_name=subinstr(village_name, "'","",.)
replace village_name=subinstr(village_name, " ","",.)
replace village_name=subinstr(village_name, "-","",.)
replace village_name=subinstr(village_name, ".","",.)
replace village_name=subinstr(village_name, "?","",.)
sort v*
replace village_name=subinstr(village_name, "0009","",.)
replace village_name=subinstr(village_name, "402062010","",.)
replace village_name=subinstr(village_name, "402062011","",.)
replace village_name=subinstr(village_name, "7402072009","",.)
replace kecamatan_name = subinstr(kecamatan_name, " ", "", .)

gen kecamatan_master = substr(id2018,1,7)
do AUX_hand_clean_inconsistent_village_names.do


preserve
	use "${processed_data_dir}/election2014_reshaped_village.dta", clear
	
	gen village_name_election2014 = village_name
	gen subdistrict_name_election2014 = subdistrict_name
	gen district_name_election2014 = district_name
	
	gen distname_match=district_name 
	gen subdistname_match=subdistrict_name
	* use of spaces and other signs is inconsistent across data sets, we get rid of them in both ends
	replace subdistname_match = subinstr(subdistname_match, " ", "", .)
	replace distname_match = subinstr(distname_match, " ", "", .)
	replace distname_match = subinstr(distname_match, "-", "", .)
	replace village_name=subinstr(village_name, char(34),"",.)
	replace village_name=subinstr(village_name, "'","",.)
	replace village_name=subinstr(village_name, " ","",.)
	replace village_name=subinstr(village_name, "-","",.)
	replace village_name=subinstr(village_name, ".","",.)
	replace village_name=subinstr(village_name, "?","",.)
	sort v*
	replace village_name=subinstr(village_name, "0009","",.)
	replace village_name=subinstr(village_name, "402062010","",.)
	replace village_name=subinstr(village_name, "402062011","",.)
	replace village_name=subinstr(village_name, "7402072009","",.)
	
	egen kecamatan_using = group(province_name district_name subdistrict_name)
	gen kecamatan_name_using = subdistrict_name
	replace kecamatan_name = subinstr(kecamatan_name, " ", "", .)
	
	duplicates tag kecamatan_using village_name , gen(t)
	drop if t>0&allvotes==0
	drop t
	

	
	
	foreach v  of varlist distname_match subdistname_match village_name {

		replace `v'=upper(`v')
	
	}
	
	*inconsistent observations
	duplicates drop kecamatan_using village_name , force
	
	tempfile elect
	save `elect'

restore

duplicates drop distname_match subdistname_match village_name  , force // 22 observations



foreach v  of varlist distname_match subdistname_match village_name {

	replace `v'=upper(`v')

}

merge 1:1 distname_match subdistname_match village_name  using `elect'



drop if _merge==2

keep id2018_1 name* vote* *voters* *turnout* allvotes*  *_name_election2014 constituency_name

rename vote_partai_damai_aceh vote_pd_aceh 
rename vote_partai_nasional_aceh vote_pn_aceh
rename constituency_name constituency_name2014

foreach v of varlist vote_partai_aceh-voteshare_islamist {

	
	rename `v' `v'2014


}

order id2018_1 name2018_1 village_name_election2014 subdistrict_name_election2014 constituency_name


drop if id2018_1==""  // empty lines from an excel table
  


save "${processed_data_dir}/election2014_with_village_ids.dta", replace
