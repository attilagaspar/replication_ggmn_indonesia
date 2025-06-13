/*

- kell egy leírás az inputokról
- fileneveket harmonizálni kell 
- rendbe kéne tenni, hogy milyen változók legyenek a datában, és azok legyenek jól dokumentálva
- el kell dönteni, mennyire mélye menjen vissza a replication package - pl a raw datát az electionben ki akarjuk adni? a podesből mennyi menjen bele?
- az elemzési részt átláthatóbbá tenni  


- minden empíria egy komprehenzív izében (pl a folytonos változat sokkal szignifikánsabb)
		

		PODESBŐL PANELBŐL A FELESLEGES VÁLTOZÓKAT KI KELL DOBNI
		
		********
		- az empirical analysisből mindent ami data generation azt át kell rakni a data generáló scriptekbe
		- a végén kitörölni minden változót ami úgy kezdődik hogy podes
		************
*/


* install packages
*ssc install reghdfe

* set up environment
do 0_setwd.do

* STEP 0
* create conversion tables across changing village IDs to merge census ethnicity data to podes
do 1_0_create_consistent_id_conversion_tables.do

* STEP 1a - PODES
* filter necessary variables from PODES (Village Potential Survey) and create development indices 
do 1_1_generate_podes_indices.do

* create village panel from different PODES waves in 2 batches
*- 1996, 2000, 2005 
*- 2008, 2011, 2014, 2018
do 1_1_create_podes_panel96_05.do
do 1_1_create_podes_panel08_18.do

* STEP 1b - Census
* use Census data to create share of Muslim population by village, ethnic minority status by village
do 1_2_census2000.do  
do 1_2_census2010.do
* use Census data to create ethnic shares by village
do 1_2_village_ethnicity_shares.do


* STEP 2- Elections
* process 2014 election data
do 2_election_2014.do
* process 2019 election data
do 2_election_2019.do

* STEP 3 - Corruption signals
* process corruption signals for the 2010s
do 3_corruption_signals2010s.do 


* STEP 4 - Put together data
* analysis dataset for 2010s

do 3_2_create_variables_for_analysis_2010s.do
* put together analysis dataset for 2000s
* (the pipeline is much shorter because eection data is also in PODES)
do 3_2_create_variables_for_analysis_2000s.do


beep
beep
beep
