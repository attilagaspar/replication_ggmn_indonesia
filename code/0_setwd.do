/*

	this script sets working directory

*/

if ("`c(username)'") == "gaspar.attila" {
	
	cd "C:/Users/gaspar.attila/Dropbox/research/corruption_and_extremism/replication_package_indonesia/code"
	

	
}	
if ("`c(username)'") == "attilagaspar" {
	
	cd /Users/attilagaspar/Dropbox/research/corruption_and_extremism/replication_package_indonesia/code

	
}
if ("`c(username)'") == "agaspar" {
	
	cd "C:/Users/agaspar/Dropbox/research/corruption_and_extremism/replication_package_indonesia/code"

	
}

global processed_data_dir "../data"
global raw_data_dir "../data/raw"
global results_dir "../results"
global final_sample2010s "analysis10s"
global final_sample2000s "analysis00s"

cap mkdir ../results
cap mkdir ../figures

clear
clear matrix
clear mata
set maxvar 10000 
