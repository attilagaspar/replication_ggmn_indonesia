/*

This script generates all tables in the main body of the paper and in the online
Appendix.

*/

* set dirs
do 0_setwd.do


* 0. descriptive tables in the paper (Tables 2 and 3)
do descriptive_table.do


*1. main regression specification in the paper

global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = ""

do main_table.do

********************************************************************************
* APPENDIX
********************************************************************************

*Tables A1-A3: T0 controls only, interact T0 controls with minority

global covariates00 = "ethn2004_* i.minority_var#(c.mb_bs_index2000  c.mb_educ_index2000 c.mb_health_index2000 c.log_dist00  c.log_population00  c.muslimshare2000)"
global covariates14 = "ethn_* i.minority_var#(c.log_dist c.log_aid2014 c.noaid2014  c.mb_educ_index2014 c.mb_health_index2014 c.mb_bs_index2014 c.lpop c.muslimshare2010)"
global suffix = "_baseline_interactions1"
do main_table.do

global covariates00 = "ethn2004_* i.c#(c.mb_bs_index2000  c.mb_educ_index2000 c.mb_health_index2000 c.log_dist00  c.log_population00  c.muslimshare2000) "
global covariates14 = "ethn_* i.c#(c.log_dist c.log_aid2014 c.noaid2014  c.mb_educ_index2014 c.mb_health_index2014 c.mb_bs_index2014 c.lpop c.muslimshare2010)"
global suffix = "_baseline_interactions2"
do main_table.do

global covariates00 = "ethn2004_* i.minority_var#(c.mb_bs_index2000  c.mb_educ_index2000 c.mb_health_index2000 c.log_dist00  c.log_population00  c.muslimshare2000)  i.c#(c.mb_bs_index2000  c.mb_educ_index2000 c.mb_health_index2000 c.log_dist00  c.log_population00  c.muslimshare2000) "
global covariates14 = "ethn_* i.minority_var#(c.log_dist c.log_aid2014 c.noaid2014  c.mb_educ_index2014 c.mb_health_index2014 c.mb_bs_index2014 c.lpop c.muslimshare2010) i.c#(c.log_dist c.log_aid2014 c.noaid2014  c.mb_educ_index2014 c.mb_health_index2014 c.mb_bs_index2014 c.lpop c.muslimshare2010)"
global suffix = "_baseline_interactions3"
do main_table.do

*Table A4
do parallel_trends_analysis_1996_2000.do
*Figure A1
do parallel_trends_analysis_2008_2014.do
*Table A5 & Figure A.2  - Does corruption predict 
do audit_favoritism.do

/*
Other robustness checks in the draft so far:

Table A6- continuous minority shares
*/


global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 popshare00*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  popshare*   log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "muslim_minority_villshare2004"
global minor14 = "muslim_minority_villshare2018" 
global suffix = "_continuous_minority"

do main_table_continuous_shares.do

/*
Table A7- interaction with muslim share
*/

global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00   ethn2004_*  "
global covariates14 = " lpop   ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = ""

do main_table_muslimshare_interaction.do


/*
Table A8  -  Muslim share above 80pct

*/

global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = "if muslimshare2000>.8"
global condition14 = "if muslimshare2010>.8"
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = "_muslims_80pct"
do main_table.do


/*
Table A9 -  omitting controls
*/

global covariates00 = "  ethn2004_*  "
global covariates14 = "  ethn_*  "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = "_nocontrols"

do main_table.do



* Table A.9B - omitting fixed effects

global covariates00 = "  "
global covariates14 = "  "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = "_no_ethnicities_controls"

do main_table.do

/*
Table A10 - different corruption signals
*/
global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = ""

do main_table_different_signals.do 



* analysis for missing data - Is missing data systematically different? - Tables A11, A12, A13
do missing_electiondata_2014_analysis

*Table A14 - Media access, Table A18 - Transfers

do supplement_table.do



*Table A15 - Heterogeneity by distance to district center 

global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = ""

do main_table_distance_heterogeneity.do

*Table A16(17 - twice numbered by mistake) - Language heterogeneity 2010s - linguistic minorities vs ethnic minorities (main language only known in 2014)

	global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
	global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
	global sevar00 = "name09"
	global sevar14 = "kab_code"
	global condition00 = ""
	global condition14 = ""
	global minor00 = "has_minor2004"
	global minor14 = "has_minor2018" 
	global suffix = ""

	do main_table_language2014.do

	
	
/*
Table A19 -  protest parties (placebo)
Table A20 - religious minorities (placebo)
*/
global covariates00 = " mb_bs_index2000  mb_educ_index2000 mb_health_index2000 log_dist00  log_population00  c.muslimshare2000##c.muslimshare2000 ethn2004_*  "
global covariates14 = " lpop c.muslimshare2010##c.muslimshare2010  ethn_*  log_dist log_aid2014 noaid2014  mb_educ_index2014 mb_health_index2014 mb_bs_index2014  mb_educ_index2018 mb_health_index2018 mb_bs_index2018 "
global sevar00 = "name09"
global sevar14 = "kab_code"
global condition00 = ""
global condition14 = ""
global minor00 = "has_minor2004"
global minor14 = "has_minor2018" 
global suffix = ""
* Table A19: Impact of corruption on support for other protest parties
do main_table_protest.do 
* Table A20: Impact of corruption on protest & islamist support among non-Muslim religious minorities
do main_table_nonmuslim.do A20

