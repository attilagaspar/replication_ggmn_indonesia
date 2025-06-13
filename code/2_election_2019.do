import delimited ${raw_data_dir}/conversion_tables/convtable_bps2018_admin2018/convtable_bps2018_admin2018.csv, encoding(utf8) clear 

tostring v2, gen(id2018_1)
rename v4 admin_codes2019
replace admin_codes2019 = subinstr(admin_codes2019, ".","",.)
drop v1
drop v2
rename v3 desaname_convtable
rename v5 desaname_convtable2

replace admin_codes2019= strtrim(admin_codes2019)
drop if admin_codes2019==""

merge m:1 admin_codes2019 using "${raw_data_dir}/election2019_by_village_and_admincode/village_partylist_results_matched_with_admincodes2019_scraped.dta", gen(merge_admin)


drop if merge_admin==1
drop if id2018==""

* remove duplicates by collapsing to 2018 id-s
collapse (sum) party_PB party_Gerindra party_PDIP party_Golkar party_Nasdem  ///
	party_Garuda party_Berkarya party_PKS party_Perindo party_PPP party_PSI   ///
	party_PAN party_Hanura party_Demokrat party_PBB party_PKPI party_PA party_SIRA  ///
	 party_PDAceh party_PNA party_PB_subdist party_Gerindra_subdist  ///
	 party_PDIP_subdist party_Golkar_subdist party_Nasdem_subdist   ///
	 party_Garuda_subdist party_Berkarya_subdist party_PKS_subdist   ///
	 party_Perindo_subdist party_PPP_subdist party_PSI_subdist party_PAN_subdist   ///
	 party_Hanura_subdist party_Demokrat_subdist party_PBB_subdist party_PKPI_subdist  ///
	 party_PA_subdist party_SIRA_subdist party_PDAceh_subdist party_PNA_subdist   ///
	 party_PB_dist party_Gerindra_dist party_PDIP_dist party_Golkar_dist   ///
	 party_Nasdem_dist party_Garuda_dist party_Berkarya_dist party_PKS_dist   ///
	 party_Perindo_dist party_PPP_dist party_PSI_dist party_PAN_dist   ///
	 party_Hanura_dist party_Demokrat_dist party_PBB_dist party_PKPI_dist   ///
	 party_PA_dist party_SIRA_dist party_PDAceh_dist party_PNA_dist   ///
	 totalvotes_desa totalvote_dist  ///
	 (mean) percent_counted_subdist percent_counted ///
	 (first) desaname_convtable admin_codes2019 desaname_convtable2  ///
	 propinsi_nomornet kabupaten_nomornet kabupaten_name_election kecamatan_nomornet  ///
	 kecamatan_name_election desa_nomornet desa_name_election missing_data  ///
	 kodepos_nomornet regtype_nomornet , by(id2018)
	 

gen voteshare_islamist2019=(party_PBB+party_PPP+party_PKS)/totalvotes_desa

la var missing_data "No village level election data in 2019"

drop percent_counted_subdist percent_counted desaname_convtable admin_codes2019 desaname_convtable2 propinsi_nomornet kabupaten_nomornet kabupaten_name_election kecamatan_nomornet kecamatan_name_election desa_nomornet desa_name_election kodepos_nomornet regtype_nomornet

save "${processed_data_dir}/election2019_with_village_ids.dta", replace
