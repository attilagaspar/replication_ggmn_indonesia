
/*

	this script filters the podes variables and creates the development indices 
	which are the main village level control variables

*/


	********************************************************************************
	*                               1996                                          * 
	********************************************************************************
	use "${raw_data_dir}/podes/podes1996.dta", clear


	drop if podes1996_prop==54 // East-Timor still occupied by Indonesia in 1996, not in 2000


	/* education index */ 

	foreach v of varlist podes1996_b5r1ak2   podes1996_b5r1ak3  podes1996_b5r1ak4  podes1996_b5r1ak5   /// TK
		podes1996_b5r1bk2   podes1996_b5r1bk3  podes1996_b5r1bk4  podes1996_b5r1bk5 /// SD
		podes1996_b5r1ck2   podes1996_b5r1ck3  podes1996_b5r1ck4  podes1996_b5r1ck5 /// SMP
		podes1996_b5r1dk2   podes1996_b5r1dk3  podes1996_b5r1dk4  podes1996_b5r1dk5 /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}

	/* negeri + swasta   -  Martinez-Bravo does not specify*/
	egen mb_educ_index1996 =rowmean( podes1996_b5r1ak2_sd   podes1996_b5r1ak3_sd  podes1996_b5r1ak4_sd  podes1996_b5r1ak5_sd   ///
		podes1996_b5r1bk2_sd   podes1996_b5r1bk3_sd  podes1996_b5r1bk4_sd  podes1996_b5r1bk5_sd /// 
		podes1996_b5r1ck2_sd   podes1996_b5r1ck3_sd  podes1996_b5r1ck4_sd  podes1996_b5r1ck5_sd /// 
		podes1996_b5r1dk2_sd   podes1996_b5r1dk3_sd  podes1996_b5r1dk4_sd  podes1996_b5r1dk5_sd ) 

	* negeri only
	egen mb_educ_index_state1996 =rowmean( podes1996_b5r1ak2_sd   podes1996_b5r1ak3_sd     ///
		podes1996_b5r1bk2_sd   podes1996_b5r1bk3_sd   /// 
		podes1996_b5r1ck2_sd   podes1996_b5r1ck3_sd   /// 
		podes1996_b5r1dk2_sd   podes1996_b5r1dk3_sd   ) 
		

	* swasta only
	egen mb_educ_index_priv1996 =rowmean(   podes1996_b5r1ak4_sd  podes1996_b5r1ak5_sd   ///
		  podes1996_b5r1bk4_sd  podes1996_b5r1bk5_sd /// 
		  podes1996_b5r1ck4_sd  podes1996_b5r1ck5_sd /// 
		  podes1996_b5r1dk4_sd  podes1996_b5r1dk5_sd ) 
	 
	la var mb_educ_index1996 "Education Index 1996 (Martinez-Bravo et al 2017)"


	/* 

			

	health index 

	- number of puskesmas
	- number of doctors
	- number of trained midwives
	- dummy for NO TRADITIONAL MIDWIFe


	*/

	* no traditional health worker ("dukun")
	gen notraditional1996 = 0 if podes1996_b8r2e2!=.
	replace notraditional1996 = 1 if podes1996_b8r2e1==0&podes1996_b8r2e2==0   // count of dukuns

	gen doctors1996=podes1996_b8r2a1+podes1996_b8r2a2
	gen midwives1996=podes1996_b8r2c+podes1996_b8r2d


	gen puskesmas1996 = podes1996_b8r1ek2+podes1996_b8r1fk2  //puskesmas + puskesmas pembantu

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {
		egen `s'1996_sd=std(`s'1996)


	}
	egen mb_health_index1996=rowmean(doctors1996_sd midwives1996_sd puskesmas1996_sd notraditional1996_sd)

	la var mb_health_index1996  "Health Index 1996 (Martinez-Bravo et al 2017)"

	drop *_sd

	/*

	Basic Services Index
	 - dummy: drinkingwater from pump or water company : question 507, answers 2,3,4
	 - dummy: waste in bins or buried in hole : question 504A in 2018, 505A in 2014, b4br2 in 1996
	 - dummy: existence of public toilet - this does not exist in current PODES. Instead: access to any toilet
	 - dummy: gas,electricity or kerosene for cooking. 2018: 503C, 2014: 503
	 - dummy: road passable year-round

	*/


	/* safe drinking water 
	- dummy: drinkingwater from pump or water company : question 507, answers 2,3,4
	*/
	gen bs_safewater1996=0 if podes1996_b8r4a!=.
	replace bs_safewater1996=1 if podes1996_b8r4a==1|podes1996_b8r4a==2



	/*

		safe garbage disposal
		 - dummy: waste in bins or buried in hole : question 504A in 2018, 505A in 2014, b4br2 in 1996

	*/


	gen bs_safegarb1996=0 if  podes1996_b4br2!=.
	replace bs_safegarb1996=1 if  podes1996_b4br4<3

	 
	/*

		road
		
		 - dummy: road passable year-round


	*/

	* type of main road cover
	rename podes1996_b9ar1b1 mainroad1996    
	replace mainroad1996=0 if mainroad1996==.&podes1996_b4br2!=.   // no road, but not missing

	la val mainroad* roadtype

	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}


	* road is passable
	gen road_passable1996 = 0 if podes1996_b9ar1b2!=.
	replace road_passable1996 = 1 if podes1996_b9ar1b2==1


	* roadlight
	gen has_roadlight1996 = 2- podes1996_b11er4a 

	gen public_roadlight1996 = .


	replace public_roadlight1996= 0 if podes1996_b11er4b!=.
	replace public_roadlight1996= 1 if podes1996_b11er4b==1
	replace public_roadlight1996= 0 if has_roadlight1996==0

	/*
		public toilet
		
	 - dummy: existence of public toilet - this does not exist in current PODES. Instead: access to any toilet


	*/

	*toilet
	rename podes1996_b4br3 toilet1996 // 1: private toilet

	/*main cooking fuel
		
		 - dummy: gas,electricity or kerosene for cooking. 2018: 503C, 2014: 503


	*/
	rename podes1996_b4br1 cooking_main1996 // city gas & LPG is same category, so recode first category to 1.5
	replace cooking_main1996=cooking_main1996+1
	replace cooking_main1996=1.5 if cooking_main1996==2

	destring toilet*, force replace
	la val toilet* toi

	gen bs_toilet1996=0 if toilet1996!=.
	replace bs_toilet1996=1 if toilet1996<4

	gen bs_cooking1996=0 if cooking_main1996!=.
	replace bs_cooking1996=1 if cooking_main1996<3

	gen bs_roadp1996=0 if cooking_main1996!=.  // this is also missing if the village is on an island, so we use other reference variable
	replace bs_roadp1996=1 if road_passable1996==1


	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {
		egen `s'1996_sd=std(`s'1996)

	}


	egen mb_bs_index1996 = rowmean(bs_safewater1996_sd bs_safegarb1996_sd bs_toilet1996_sd bs_cooking1996_sd bs_roadp1996_sd)

	la var mb_bs_index1996  "Basic Services Index 1996 (Martinez-Bravo et al 2017)"


	

	*keep fid* mb_*  

	save "${processed_data_dir}/podes1996mb.dta", replace

	 
	********************************************************************************
	*                               2000                                          * 
	********************************************************************************
	use "${raw_data_dir}/podes/podes2000.dta", clear


	/*
	
		education index
		
	*/
			foreach v of varlist podes2000_b5r1a2   podes2000_b5r1a3    /// T
		podes2000_b5r1b2   podes2000_b5r1b3   /// SD
		podes2000_b5r1c2   podes2000_b5r1c3   /// SMP
		podes2000_b5r1d2   podes2000_b5r1d3   /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}
	egen mb_educ_index2000 = rowmean (podes2000_b5r1a2_sd   podes2000_b5r1a3_sd    /// T
		podes2000_b5r1b2_sd   podes2000_b5r1b3_sd   /// SD
		podes2000_b5r1c2_sd   podes2000_b5r1c3_sd   /// SMP
		podes2000_b5r1d2_sd   podes2000_b5r1d3_sd )   // SMU



	egen mb_educ_index_state2000 = rowmean (podes2000_b5r1a2_sd      /// T
		podes2000_b5r1b2_sd    /// SD
		podes2000_b5r1c2_sd    /// SMP
		podes2000_b5r1d2_sd  )  // SMU 
			
	egen mb_educ_index_priv2000 = rowmean (   podes2000_b5r1a3_sd    /// T
		   podes2000_b5r1b3_sd   /// SD
		   podes2000_b5r1c3_sd   /// SMP
		  podes2000_b5r1d3_sd )  // SMU 


	la var mb_educ_index2000 "Education Index 2000 (Martinez-Bravo et al 2017)"
	
	/*
	
		health index
		
	*/
	
	
	gen notraditional2000 = 0
	replace notraditional2000 = 1 if podes2000_b8r2f1==2&podes2000_b8r2f2==4 // &podes2000_b8r2g==6   dummy if there is np  dukun


	* in 2000 there is only dummy of having a doctors, but rarely had a village more than 1 or 2 doctors before
	gen doctors2000=0 if podes2000_b8r2a2!=.&podes2000_b8r2a2!=.
	replace doctors2000 = 1 if podes2000_b8r2a1==1|podes2000_b8r2a2==3
	*replace doctors2000 = 2 if podes2000_b8r2a1==1&podes2000_b8r2a2==3 // nem tudom hogy ez jó -e 

	gen midwives2000=0 if podes2000_b8r2d!=.
	replace midwives2000 = 1 if podes2000_b8r2d==5|podes2000_b8r2e==7
	*replace midwives2000 = 2 if podes2000_b8r2d==5&podes2000_b8r2e==7


	gen puskesmas2000 = podes2000_b8r1f2+podes2000_b8r1e2

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {
		egen `s'2000_sd=std(`s'2000)


	}
	egen mb_health_index2000=rowmean(doctors2000_sd midwives2000_sd puskesmas2000_sd notraditional2000_sd)
	la var mb_health_index2000  "Health Index 2000 (Martinez-Bravo et al 2017)"


	gen bs_safewater2000=0 if podes2000_b8r8a!=.
	replace bs_safewater2000=1 if podes2000_b8r8a==1|podes2000_b8r8a==2

	gen bs_safegarb2000=0 if  podes2000_b4br4!=.
	replace bs_safegarb2000=1 if  podes2000_b4br4<3

	/*
		basic services index
	*/

	rename podes2000_b9ar1b1 mainroad2000

	gen road_passable2000 = 0 if podes2000_b9ar1b2!=.
	replace road_passable2000 = 1 if podes2000_b9ar1b2==1
	gen public_roadlight2000 = .


	gen has_roadlight2000 = 2- podes2000_b4br2a 


	replace public_roadlight2000= 0 if has_roadlight2000!=.
	replace public_roadlight2000= 1 if podes2000_b4br2b ==1
	rename podes2000_b4br5 toilet2000

	rename podes2000_b4br3 cooking_main2000
	replace cooking_main2000=cooking_main2000+1 // same problem
	replace cooking_main2000=1.5 if cooking_main2000==2

	gen bs_toilet2000=0 if toilet2000!=.
	replace bs_toilet2000=1 if toilet2000<4

	gen bs_cooking2000=0 if cooking_main2000!=.
	replace bs_cooking2000=1 if cooking_main2000<3

	gen bs_roadp2000=0 if cooking_main2000!=.
	replace bs_roadp2000=1 if road_passable2000==1

	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {
		egen `s'2000_sd=std(`s'2000)

	}

	egen mb_bs_index2000 = rowmean(bs_safewater2000_sd bs_safegarb2000_sd bs_toilet2000_sd bs_cooking2000_sd bs_roadp2000_sd)
	la var mb_bs_index2000  "Basic Services Index 2000 (Martinez-Bravo et al 2017)"



*	keep fid* mb_* population* 

	save "${processed_data_dir}/podes2000mb.dta", replace


	********************************************************************************
	*                               2003                                          * 
	********************************************************************************
	use "${raw_data_dir}/podes/podes2003.dta", clear


	
	/* education index */

	foreach v of varlist podes2003_b6r601a2   podes2003_b6r601a3    /// T
		podes2003_b6r601b2   podes2003_b6r601b3   /// SD
		podes2003_b6r601c2   podes2003_b6r601c3   /// SMP - same as SLTP
		podes2003_b6r601d2   podes2003_b6r601d3   /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}


	egen mb_educ_index2003 = rowmean (podes2003_b6r601a2_sd   podes2003_b6r601a3_sd    /// T
		podes2003_b6r601b2_sd   podes2003_b6r601b3_sd   /// SD
		podes2003_b6r601c2_sd   podes2003_b6r601c3_sd   /// SMP - same as SLTP
		podes2003_b6r601d2_sd   podes2003_b6r601d3_sd )  // SMU 
		
	egen mb_educ_index_state2003 = rowmean (podes2003_b6r601a2_sd       /// T
		podes2003_b6r601b2_sd     /// SD
		podes2003_b6r601c2_sd      /// SMP - same as SLTP
		podes2003_b6r601d2_sd    )  // SMU 

		  
	egen mb_educ_index_priv2003 = rowmean (  podes2003_b6r601a3_sd    /// T
		  podes2003_b6r601b3_sd   /// SD
		  podes2003_b6r601c3_sd   /// SMP - same as SLTP
		  podes2003_b6r601d3_sd )  // SMU 

	la var mb_educ_index2003 "Education Index 2003 (Martinez-Bravo et al 2017)"

/* health index */ 

	gen notraditional2003  =0 
	replace notraditional2003 = 1 if (podes2003_b7r703c1>0&podes2003_b7r703c1!=.)&(podes2003_b7r703c2>0&podes2003_b7r703c2!=.)


	gen doctors2003 = podes2003_b7r703a1+podes2003_b7r703a1
	gen midwives2003 = podes2003_b7r703b1+podes2003_b7r703b1

	gen puskesmas2003 = podes2003_b7r701d2+podes2003_b7r701e2

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {
		egen `s'2003_sd=std(`s'2003)
	}	 

	egen mb_health_index2003=rowmean(doctors2003_sd midwives2003_sd puskesmas2003_sd notraditional2003_sd)
	la var mb_health_index2003  "Health Index 2003 (Martinez-Bravo et al 2017)"

/* basic services index */ 

	
	gen bs_safewater2003=0 if podes2003_b7r709a!=.
	replace bs_safewater2003=1 if podes2003_b7r709a==1|podes2003_b7r709a==2

	gen bs_safegarb2003=0 if podes2003_b5r504!=.
	replace bs_safegarb2003=1 if podes2003_b5r504<3  
	 
	rename podes2003_b10r1001b1 mainroad2003
	gen road_passable2003 = 0 if mainroad2003!=.
	replace road_passable2003 = 1 if podes2003_b10r1001b2==1

	gen has_roadlight2003 = 2-podes2003_b5r502a 
	gen public_roadlight2003 = .

	replace public_roadlight2003= 0 if has_roadlight2003!=.
	replace public_roadlight2003= 1 if podes2003_b5r502b==1

	rename podes2003_b5r505 toilet2003
	rename podes2003_b5r503 cooking_main2003
	replace cooking_main2003=cooking_main2003+1
	replace cooking_main2003=1.5 if cooking_main2003==2


	gen bs_toilet2003=0 if toilet2003!=.
	replace bs_toilet2003=1 if toilet2003<4

	gen bs_cooking2003=0 if cooking_main2003!=.
	replace bs_cooking2003=1 if cooking_main2003<3

	gen bs_roadp2003=0 if cooking_main2003!=.
	replace bs_roadp2003=1 if road_passable2003==1



	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {

		egen `s'2003_sd=std(`s'2003)

	}

	egen mb_bs_index2003 = rowmean(bs_safewater2003_sd bs_safegarb2003_sd bs_toilet2003_sd bs_cooking2003_sd bs_roadp2003_sd)
	la var mb_bs_index2003  "Basic Services Index 2003 (Martinez-Bravo et al 2017)"
	

*	 keep fid* mb_* population* 

	save "${processed_data_dir}/podes2003mb.dta", replace

	********************************************************************************
	*                               2005                                           * 
	********************************************************************************
	use "${raw_data_dir}/podes/podes2005.dta", clear


	/* education index */

	foreach v of varlist podes2005_r601ak2   podes2005_r601ak3    /// T
		podes2005_r601bk2   podes2005_r601bk3   /// SD
		podes2005_r601ck2   podes2005_r601ck3   /// SMP - same as SLTP
		podes2005_r601dk2   podes2005_r601dk3   /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}


	egen mb_educ_index2005 =  rowmean (podes2005_r601ak2_sd   podes2005_r601ak3_sd   /// T
		podes2005_r601bk2_sd   podes2005_r601bk3_sd   /// SD
		podes2005_r601ck2_sd   podes2005_r601ck3_sd   /// SMP - same as SLTP
		podes2005_r601dk2_sd   podes2005_r601dk3_sd  )	

	egen mb_educ_index_state2005 = rowmean (podes2005_r601ak2_sd    /// T
		podes2005_r601bk2_sd    /// SD
		podes2005_r601ck2_sd     /// SMP - same as SLTP
		podes2005_r601dk2_sd    )

		egen mb_educ_index_priv2005 = rowmean (  podes2005_r601ak3_sd   /// T
		  podes2005_r601bk3_sd   /// SD
		  podes2005_r601ck3_sd   /// SMP - same as SLTP
		  podes2005_r601dk3_sd  )

	la var mb_educ_index2005 "Education Index 2005 (Martinez-Bravo et al 2017)"

	/*  health index  */
	
	gen notraditional2005 = .
	replace notraditional2005 = 1 if podes2005_r604d1==0&podes2005_r604d1==0
	replace notraditional2005 = 0 if (podes2005_r604d1>0|podes2005_r604d1>0)&podes2005_r604d1!=.&podes2005_r604d1!=.


	gen doctors2005 = podes2005_r604a1+podes2005_r604a2
	gen midwives2005=podes2005_r604c
	gen puskesmas2005 = podes2005_r603dk2+podes2005_r603ek2

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {

		egen `s'2005_sd=std(`s'2005)

	}

	egen mb_health_index2005=rowmean(doctors2005_sd midwives2005_sd puskesmas2005_sd notraditional2005_sd)
	la var mb_health_index2005  "Health Index 2005 (Martinez-Bravo et al 2017)"

	
	/* basic services index */
	
	
	gen bs_safewater2005=0 if podes2005_r608a!=.
	replace bs_safewater2005=1 if podes2005_r608a==1|podes2005_r608a==2
	gen bs_safegarb2005=0 if podes2005_r504!=.
	replace bs_safegarb2005=1 if podes2005_r504<3  


	rename podes2005_r901b1 mainroad2005
	replace mainroad2005=0 if mainroad2005==.&bs_safegarb2005!=.  // no road, but not missing obs


	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}
	gen road_passable2005 = 0 if mainroad2005!=.
	replace road_passable2005 = 1 if podes2005_r901b2==1

	gen has_roadlight2005 = 2-podes2005_r502a 
	gen public_roadlight2005 = .
	replace public_roadlight2005= 0 if has_roadlight2005!=.
	replace public_roadlight2005= 1 if podes2005_r502b==1

	rename podes2005_r505 toilet2005

	rename podes2005_r503 cooking_main2005
	replace cooking_main2005=cooking_main2005+1
	replace cooking_main2005=1.5 if cooking_main2005==2
	gen bs_toilet2005=0 if toilet2005!=.
	replace bs_toilet2005=1 if toilet2005<4

	gen bs_cooking2005=0 if cooking_main2005!=.
	replace bs_cooking2005=1 if cooking_main2005<3

	gen bs_roadp2005=0 if cooking_main2005!=.
	replace bs_roadp2005=1 if road_passable2005==1
	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {

		egen `s'2005_sd=std(`s'2005)



	}
	egen mb_bs_index2005 = rowmean(bs_safewater2005_sd bs_safegarb2005_sd bs_toilet2005_sd bs_cooking2005_sd bs_roadp2005_sd)
	la var mb_bs_index2005  "Basic Services Index 2005 (Martinez-Bravo et al 2017)"


*	keep fid* mb_* population* 

	save "${processed_data_dir}/podes2005mb.dta", replace

	********************************************************************************
	*                               2008                                           * 
	********************************************************************************


	use "${raw_data_dir}/podes/podes2008.dta", clear


	gen population2008= podes2008_r401a+podes2008_r401b
	
	/* education index */

	foreach v of varlist podes2008_r601a_2   podes2008_r601a_3    /// T
		podes2008_r601b_2   podes2008_r601b_3   /// SD
		podes2008_r601c_2   podes2008_r601c_3   /// SMP - same as SLTP
		podes2008_r601d_2   podes2008_r601d_3   /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}


	egen mb_educ_index2008 = rowmean(podes2008_r601a_2_sd  podes2008_r601a_3_sd    /// T
		podes2008_r601b_2_sd   podes2008_r601b_3_sd   /// SD
		podes2008_r601c_2_sd   podes2008_r601c_3_sd   /// SMP - same as SLTP
		podes2008_r601d_2_sd   podes2008_r601d_3_sd ) 

	egen mb_educ_index_state2008 = rowmean(podes2008_r601a_2_sd    /// T
		podes2008_r601b_2_sd      /// SD
		podes2008_r601c_2_sd     /// SMP - same as SLTP
		podes2008_r601d_2_sd   ) 
		

	egen mb_educ_index_priv2008 = rowmean(   podes2008_r601a_3_sd    /// T
		   podes2008_r601b_3_sd   /// SD
		  podes2008_r601c_3_sd   /// SMP - same as SLTP
		   podes2008_r601d_3_sd ) 
		
		
	la var mb_educ_index2008 "Education Index 2008 (Martinez-Bravo et al 2017)"



	/* 

			

	health index 

	- number of puskesmas
	- number of doctors
	- number of trained midwives
	- dummy for NO TRADITIONAL MIDWIFe


	*/
	gen notraditional2008 = .
	replace notraditional2008 = 1 if podes2008_r606e==0
	replace notraditional2008 = 0 if podes2008_r606e>0&podes2008_r606e!=.


	gen doctors2008 = podes2008_r606a1+podes2008_r606a2
	gen midwives2008=podes2008_r606c

	gen puskesmas2008 = podes2008_r604d_2+podes2008_r604e_2

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {

		egen `s'2008_sd=std(`s'2008)

	}

	egen mb_health_index2008=rowmean(doctors2008_sd midwives2008_sd puskesmas2008_sd notraditional2008_sd)


	la var mb_health_index2008  "Health Index 2008 (Martinez-Bravo et al 2017)"

	/*
		basic services index
	*/
	
	gen bs_safewater2008=0 if podes2008_r612a!=.
	replace bs_safewater2008=1 if podes2008_r612a==1|podes2008_r612a==2

	gen bs_safegarb2008=0 if podes2008_r504a!=.
	replace bs_safegarb2008=1 if podes2008_r504a<3  

	rename podes2008_r901b1 mainroad2008
	replace mainroad2008=0 if mainroad2008==.&bs_safegarb2008!=.  // no road, but not missing obs


	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}

	gen road_passable2008 = 0 if mainroad2008!=.
	replace road_passable2008 = 1 if podes2008_r901b2==1
	gen has_roadlight2008 = 2-podes2008_r502a 
	gen public_roadlight2008 = .


	replace public_roadlight2008= 0 if has_roadlight2008!=.
	replace public_roadlight2008= 1 if podes2008_r502b==1


	rename podes2008_r505 toilet2008

	rename podes2008_r503 cooking_main2008
	replace cooking_main2008=cooking_main2008+1
	replace cooking_main2008=1.5 if cooking_main2008==2



	destring toilet*, force replace
	gen bs_toilet2008=0 if toilet2008!=.
	replace bs_toilet2008=1 if toilet2008<4

	gen bs_cooking2008=0 if cooking_main2008!=.
	replace bs_cooking2008=1 if cooking_main2008<3


	gen bs_roadp2008=0 if cooking_main2008!=.
	replace bs_roadp2008=1 if road_passable2008==1


	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {

		egen `s'2008_sd=std(`s'2008)


	}

	egen mb_bs_index2008 = rowmean(bs_safewater2008_sd bs_safegarb2008_sd bs_toilet2008_sd bs_cooking2008_sd bs_roadp2008_sd)
	la var mb_bs_index2008  "Basic Services Index 2008 (Martinez-Bravo et al 2017)"


*	keep fid* mb_* population* 


		save "${processed_data_dir}/podes2008mb.dta", replace



	********************************************************************************
	*                               2011                                           * 
	********************************************************************************


	use "${raw_data_dir}/podes/podes2011.dta", clear


	/*

	education index

	*/

	foreach v of varlist podes2011_r701ak2   podes2011_r701ak3    /// T
		podes2011_r701bk2   podes2011_r701bk3   /// SD
		podes2011_r701ck2   podes2011_r701ck3   /// SMP - same as SLTP
		podes2011_r701dk2   podes2011_r701dk3   /// SMU 
		{
		
		egen `v'_sd = std(`v')
		
	}


	egen mb_educ_index2011 =rowmean( podes2011_r701ak2_sd   podes2011_r701ak3_sd    /// T
		podes2011_r701bk2_sd   podes2011_r701bk3_sd   /// SD
		podes2011_r701ck2_sd   podes2011_r701ck3_sd   /// SMP - same as SLTP
		podes2011_r701dk2_sd   podes2011_r701dk3_sd  ) // SMU 
		
		
		
	egen mb_educ_index_state2011 =rowmean( podes2011_r701ak2_sd     /// T
		podes2011_r701bk2_sd     /// SD
		podes2011_r701ck2_sd      /// SMP - same as SLTP
		podes2011_r701dk2_sd     ) // SMU 



	egen mb_educ_index_priv2011 =rowmean(    podes2011_r701ak3_sd    /// T
		 podes2011_r701bk3_sd   /// SD
		  podes2011_r701ck3_sd   /// SMP - same as SLTP
		 podes2011_r701dk3_sd  ) // SMU 
		
		
		
	la var mb_educ_index2011 "Education Index 2011 (Martinez-Bravo et al 2017)"




	/*
			
			healthcare index
			
	*/

	gen notraditional2011 = .
	replace notraditional2011 = 1 if podes2011_r707e==0
	replace notraditional2011 = 0 if podes2011_r707e>0&podes2011_r707e!=.


	gen doctors2011 = podes2011_r707a1+podes2011_r707a2
	gen midwives2011=podes2011_r707c


	gen puskesmas2011 = podes2011_r704dk2+podes2011_r704ek2


	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {
		egen `s'2011_sd=std(`s'2011)
	}

	egen mb_health_index2011=rowmean(doctors2011_sd midwives2011_sd puskesmas2011_sd notraditional2011_sd)
	la var mb_health_index2011  "Health Index 2008 (Martinez-Bravo et al 2017)"

	/*
			basic services index
	*/

	gen bs_safewater2011=0 if podes2011_r713a!=.
	replace bs_safewater2011=1 if podes2011_r713a==2|podes2011_r713a==3


	gen bs_safegarb2011=0 if podes2011_r505a!=.
	replace bs_safegarb2011=1 if podes2011_r505a<3  

	rename podes2011_r1001b1 mainroad2011
	replace mainroad2011=0 if mainroad2011==.&bs_safegarb2011!=.  // no road, but not missing obs


	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}
	gen road_passable2011 = 0 if mainroad2011!=.
	replace road_passable2011 = 1 if podes2011_r1001b2==1

	gen has_roadlight2011 = 2-podes2011_r502a 


	gen public_roadlight2011 = .

	replace public_roadlight2011= 0 if has_roadlight2011!=.
	replace public_roadlight2011= 1 if podes2011_r502b==1

	rename podes2011_r504 toilet2011


	rename podes2011_r503 cooking_main2011

	destring toilet*, force replace

	gen bs_toilet2011=0 if toilet2011!=.
	replace bs_toilet2011=1 if toilet2011<4

	gen bs_cooking2011=0 if cooking_main2011!=.
	replace bs_cooking2011=1 if cooking_main2011<3

	gen bs_roadp2011=0 if cooking_main2011!=.
	replace bs_roadp2011=1 if road_passable2011==1


	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {
		egen `s'2011_sd=std(`s'2011)
	}

	egen mb_bs_index2011 = rowmean(bs_safewater2011_sd bs_safegarb2011_sd bs_toilet2011_sd bs_cooking2011_sd bs_roadp2011_sd)

	la var mb_bs_index2011  "Basic Services Index 2011 (Martinez-Bravo et al 2017)"



	save "${processed_data_dir}/podes2011mb.dta", replace


	********************************************************************************
	*                               2014                                           * 
	********************************************************************************


	use "${raw_data_dir}/podes/podes2014.dta", clear




	
	/* education index */

	foreach v of varlist podes2014_R701A_K2  podes2014_R701A_K3  ///  TK
		 podes2014_R701B_K2  podes2014_R701B_K3   ///				  SD
		 podes2014_R701C_K2  podes2014_R701C_K3   ///				  SMP
		 podes2014_R701D_K2   podes2014_R701D_K3  ///                 SMU
		 {
		 
		 egen `v'_sd = std(`v')
		 
	}




	egen mb_educ_index2014=rowmean(podes2014_R701A_K2_sd podes2014_R701A_K3_sd ///
	podes2014_R701B_K2_sd podes2014_R701B_K3_sd ///
	podes2014_R701C_K2_sd podes2014_R701C_K3_sd ///
	podes2014_R701D_K2_sd podes2014_R701D_K3_sd)



	egen mb_educ_index_state2014=rowmean(podes2014_R701A_K2_sd  ///
	podes2014_R701B_K2_sd  ///
	podes2014_R701C_K2_sd ///
	podes2014_R701D_K2_sd )


		  
	egen mb_educ_index_priv2014=rowmean( podes2014_R701A_K3_sd ///
	 podes2014_R701B_K3_sd ///
	 podes2014_R701C_K3_sd ///
	podes2014_R701D_K3_sd)

	la var mb_educ_index2014 "Education Index 2014 (Martinez-Bravo et al 2017)"

	/*

				helthcare index
				
	*/

	gen notraditional2014 = .
	replace notraditional2014 = 1 if podes2014_R708==0
	replace notraditional2014 = 0 if podes2014_R708>0&podes2014_R708!=.

	gen doctors2014=podes2014_R706A1+podes2014_R706A2
	gen midwives2014=podes2014_R706C


	destring podes2014_R704*, force replace
	foreach s in  "podes2014_R704C" "podes2014_R704D" "podes2014_R704E" {

		replace `s'_K3=0 if `s'_K3==.&`s'_K2==2

	}
	gen puskesmas2014 = podes2014_R704C_K3+podes2014_R704D_K3+podes2014_R704E_K3

	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {

		egen `s'2014_sd=std(`s'2014)

	}

	egen mb_health_index2014=rowmean(doctors2014_sd midwives2014_sd puskesmas2014_sd notraditional2014_sd)
	la var mb_health_index2014  "Health Index 2014 (Martinez-Bravo et al 2017)"

	/*

		basic services index

	*/

	destring podes2014_R50*, force replace
	*destring podes2014_R10*, force replace
	destring podes2014_R100*, force replace

	gen bs_safewater2014 = 0 if podes2014_R507A!=.
	replace bs_safewater2014=1 if podes2014_R507A==2|podes2014_R507A==3|podes2014_R507A==4

	 
	gen bs_safegarb2014=0 if podes2014_R505A!=.
	replace bs_safegarb2014=1 if podes2014_R505A==1|podes2014_R505A==2


	rename podes2014_R1001B1 mainroad2014
	destring mainroad* bs_safegarb*, force replace
	replace mainroad2014 = 0 if mainroad2014==.&bs_safegarb2014!=.
	la val mainroad* roadtype

	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}

	rename podes2014_R1001B2 road_passable2014
	gen has_roadlight2014 = 2-podes2014_R502A 
	gen public_roadlight2014 = .
	replace public_roadlight2014= 0 if podes2014_R502B!=.
	replace public_roadlight2014= 1 if podes2014_R502B==1
	rename podes2014_R504 toilet2014

	rename podes2014_R503 cooking_main2014


	gen bs_toilet2014=0 if toilet2014!=.
	replace bs_toilet2014=1 if toilet2014<4


	gen bs_cooking2014=0 if cooking_main2014!=.
	replace bs_cooking2014=1 if cooking_main2014<3

	gen bs_roadp2014=0 if cooking_main2014!=.  // this is also missing if the village is on an island, so we use other reference variable
	replace bs_roadp2014=1 if road_passable2014==1

	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {

		egen `s'2014_sd=std(`s'2014)


	}
	egen mb_bs_index2014 = rowmean(bs_safewater2014_sd bs_safegarb2014_sd bs_toilet2014_sd bs_cooking2014_sd bs_roadp2014_sd)
	la var mb_bs_index2014  "Basic Services Index 2014 (Martinez-Bravo et al 2017)"

	

	save "${processed_data_dir}/podes2014mb.dta", replace



	********************************************************************************
	*                               2018                                           * 
	********************************************************************************
		
	use "${raw_data_dir}/podes/podes2018.dta", clear
		
		
	/*


		education index

	*/


	foreach v of varlist  podes2018_R701BK2  podes2018_R701BK3   ///  				  TK
		 podes2018_R701CK2  podes2018_R701CK3  					 ///				  SD
		 podes2018_R701DK2  podes2018_R701DK3  					 ///				  SMP
		 podes2018_R701EK2   podes2018_R701EK3 				 ///                 SMU
		 {
		 
		 egen `v'_sd = std(`v')
		 
	}

	egen mb_educ_index2018=rowmean(podes2018_R701EK2_sd podes2018_R701EK3_sd ///
	podes2018_R701BK2_sd podes2018_R701BK3_sd ///
	podes2018_R701CK2_sd podes2018_R701CK3_sd ///
	podes2018_R701DK2_sd podes2018_R701DK3_sd)
	la var mb_educ_index2018  "Education Index 2018 (Martinez-Bravo et al 2017)"

	/*

		healthcare index 
		
	*/

	gen notraditional2018 = .
	replace notraditional2018 = 1 if podes2018_R708==0
	replace notraditional2018 = 0 if podes2018_R708>0&podes2018_R708!=.


	gen doctors2018=podes2018_R706A1+podes2018_R706A2
	gen midwives2018=podes2018_R706C

	gen puskesmas2018 = podes2018_R704CK2+podes2018_R704DK2+podes2018_R704EK2



	foreach s in  "doctors" "midwives" "puskesmas" "notraditional" {

		egen `s'2018_sd=std(`s'2018)

	}

	egen mb_health_index2018=rowmean(doctors2018_sd midwives2018_sd puskesmas2018_sd notraditional2018_sd)
	la var mb_health_index2018  "Health Index 2018 (Martinez-Bravo et al 2017)"

		
	/*

		basic services index

	*/
	destring podes2018_R50*, force replace
	destring podes2018_R10*, force replace


	gen bs_safewater2018 = 0 if podes2018_R507A!=.
	replace bs_safewater2018=1 if podes2018_R507A==2|podes2018_R507A==3|podes2018_R507A==4


	gen bs_safegarb2018=0 if podes2018_R504A1!=.  //not a typo! 504 in 2018, 505 in 2014
	replace bs_safegarb2018=1 if podes2018_R504A1==1|podes2018_R504A2==3

	rename podes2018_R1001B1 mainroad2018

	destring mainroad* bs_safegarb*, force replace

	replace mainroad2018 = 0 if mainroad2018==.&bs_safegarb2018!=.

	foreach v of varlist mainroad* {

		replace `v' = 5 if `v'==0   // 0 (no road at all) is the worst outcome, while 1 is the best (aspahlt)

	}

	rename podes2018_R1001B2 road_passable2018

	gen public_roadlight2018 = .
	replace public_roadlight2018= 0 if podes2018_R502B!=.
	replace public_roadlight2018= 1 if podes2018_R502B==1

	rename podes2018_R505A toilet2018  // not a typo, switched with 504 in 2018

	gen bs_toilet2018=0 if toilet2018!=.
	replace bs_toilet2018=1 if toilet2018<4


	gen bs_cooking2018=0 if podes2018_R503A1!=.
	replace bs_cooking2018=1 if podes2018_R503A1==1|podes2018_R503A2==3|podes2018_R503A3==5
	gen bs_roadp2018=0 if podes2018_R503A1!=.  // this is also missing if the village is on an island, so we use other reference variable
	replace bs_roadp2018=1 if road_passable2018==1 // road is passable year round

	foreach s in "bs_safewater" "bs_safegarb" "bs_toilet"  "bs_cooking" "bs_roadp" {

		egen `s'2018_sd=std(`s'2018)


	}
	egen mb_bs_index2018 = rowmean(bs_safewater2018_sd bs_safegarb2018_sd bs_toilet2018_sd bs_cooking2018_sd bs_roadp2018_sd)
	la var mb_bs_index2018  "Basic Services Index 2018 (Martinez-Bravo et al 2017)"


	save "${processed_data_dir}/podes2018mb.dta", replace
