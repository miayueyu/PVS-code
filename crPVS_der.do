* People's Voice Survey derived variable creation
* Date of last update: April 2023
* N Kapoor, S Sabwa, M Yu

/*

	This file creates derived variables for analysis from the multi-country 
	dataset after append in the crPVS_append.do file. 

*/

***************************** Deriving variables *******************************
u "$data_mc/02 recoded data/pvs_appended.dta", clear

*------------------------------------------------------------------------------*

* Trim extreme values for for q27, q46 and q47; q46b for IT, MX, US, KR and UK

* Mia's note: check extreme values for Nigeria needed
qui levelsof country, local(countrylev)

foreach i in `countrylev' {
	
	if inlist(`i',12, 13, 14, 15, 17 18 19) {
		extremes q46b country if country == `i', high
	}

	foreach var in q27 q46 q47 {
		
		extremes `var' country if country == `i', high
	}
}

clonevar q27_original = q27
clonevar q46_original = q46
clonevar q47_original = q47
clonevar q46b_origial = q46b

* All q27 seems fine

* q46
* Colombia okay
* Ethiopia - 3 values recoded 
replace q46 = . if q46 > 600 & q46 < . & country == 3
* India - 1 value recoded 
replace q46 = . if q46 > 730 & q46 < . & country == 4 
* Kenya - 1 value recoded 
replace q46 = . if q46 > 720 & q46 < . & country == 5
* Peru okay
* South Africa - 2 values recoded 
replace q46 = . if q46 > 600 & q46 < . & country == 9
* Uruguay okay, Lao okay, US okay, Mexico okay, Italy okay 
* Korea - 1 value recoded 
replace q46 = . if q46 > 780 & q46 < . & country == 15
* Mendoza - 2 values recoded
replace q46 = . if q46 > 540 & q46 < . & country == 16
* UK - 3 values recoded
replace q46 = . if q46 > 780 & q46 < . & country == 17
* Greece - 1 value recoded (Todd to review)
replace q46 = . if q46 > 600 & q46 < . & country == 18
* Romania -  1 value recoded (Todd to review)
replace q46 = . if q46 > 600 & q46 < . & country == 19

* q47
* Colombia okay 
* Ethiopia - 6 values recoded
replace q47 = . if q47 >= 600 & q47 < . & country == 3 
* India - 8 values recoded
replace q47 = . if q47 >= 600 & q47 < . & country == 4 
* Kenya - 3 values recoded
replace q47 = . if q47 > 600 & q47 < . & country == 5
* Peru okay 
* South Africa - 2 values recoded 
replace q47 = . if q47 > 600 & q47 < . & country == 9 
* Uruguay okay, Lao okay 
* United States - 5 values recoded
replace q47 = . if q47 >= 600 & q47 < . & country == 12
* Mexico okay 
* Italy - 2 values recoded
replace q47 = . if q47 >= 600 & q47 < . & country == 14
* Korea - 13 values recoded
replace q47 = . if q47 >= 600 & q47 < . & country == 15
* Mendoza okay 
* UK - 1 value recoded
replace q47 = . if q47 > 560 & q47 < . & country == 17 
* Greece okay (Todd to review)
* Romania okay (Todd to review)

* q46b
* US - 4 values recoded 
replace q46b = . if q46b > 365 & q46b < . & country == 12
* Mexico okay 
* Italy - 2 values recoded
replace q46b = . if q46b > 365 & q46b < . & country == 14
* Korea - 1 value recoded
replace q46b = . if q46b > 365 & q46b < . & country == 15
* UK - 2 values recoded 
replace q46b = . if q46b > 365 & q46b < . & country == 17
* Greece - 1 value recoded (Todd to review)
replace q46b = . if q46b > 720 & q46b < . & country == 18
* Romania - 12 values recoded (Todd to review)
replace q46b = . if q46b > 720 & q46b < . & country == 19

*****************************

* age: exact respondent age or middle of age range 
gen age = q1 
recode age (.r = 23.5) if q2 == 0
recode age (.r = 34.5) if q2 == 1
recode age (.r = 44.5) if q2 == 2
recode age (.r = 54.5) if q2 == 3
recode age (.r = 64.5) if q2 == 4
recode age (.r = 74.5) if q2 == 5
recode age (.r = 80) if q2 == 6
lab def ref .r "Refused"
lab val age ref

* age_cat: categorical age 
gen age_cat = q2
recode age_cat (.a = 0) if q1 >= 18 & q1 <= 29
recode age_cat (.a = 1) if q1 >= 30 & q1 <= 39
recode age_cat (.a = 2) if q1 >= 40 & q1 <= 49
recode age_cat (.a = 3) if q1 >= 50 & q1 <= 59
recode age_cat (.a = 4) if q1 >= 60 & q1 <= 69
recode age_cat (.a = 5) if q1 >= 70 & q1 <= 79
recode age_cat (.a = 6) if q1 >= 80
lab val age_cat age_cat

* female: gender 	   
gen gender = q3
lab val gender gender

* covid_vax
recode q14 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax)
	
recode q14_la ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax_la)
replace covid_vax = covid_vax_la if country == 11
drop covid_vax_la
	
* covid_vax_intent 
gen covid_vax_intent = q15 
replace covid_vax_intent = q15_la if country == 11
lab val covid_vax_intent yes_no_doses
* Note: In Laos, q15 was only asked to those who said 0 doses 

* region
gen region = q5
lab val region q5_label

* patient activiation
gen activation = 1 if q16 == 3 & q17 == 3
recode activation (. = 1) if q16 == 3 & q17 == .r | q16 == .r & q17 == 3 
recode activation (. = 0) if q16 < 3 | q17 < 3 
recode activation (. = .r) if q16 == .r & q17 == .r
lab def pa 0 "Not activated" ///
			1 "Activated (Very confident on Q16 and Q17)" ///
			.r "Refused", replace
lab val activation pa

* usual_reason - confirm placements of 11-13
recode q21 (2 = 1 "Convenience (short distance)") /// 
			(1 8 = 2 "Cost (low cost, covered by insurance)") ///
			(4 = 3 "Techincal quality (provider skills)") ///
			(3 5 10  = 4 "Interpersonal quality (short waiting time, respect)") ///
			(6 = 5 "Service readiness (medicines and equipment available)") ///
			(7 = 6 "Only facility available") ///
			(.r 9 11 12 13 = .r "Other or Refused") ///
			(.a = .a "NA") , gen(usual_reason)

* visits
gen visits = q23_q24

* visits_cat
gen visits_cat = 0 if q23 == 0 | q24 == 0
recode visits_cat (. = 1) if q23 >=1 & q23 <= 4 | q24 == 1
recode visits_cat (. = 2) if q23 > 4 & q23 < . | q24 == 2 | q24 == 3
recode visits_cat (. = .r) if q23 == .r | q24 == .r
lab def visits_cat 0 "Non-user (0 visits)" 1 "Occasional user (1-4 visits)" ///
			   2 "Frequent user (more than 4)" .r "Refused"
lab val visits_cat visits_cat

* visits_covid
gen visits_covid = q25_b
recode visits_covid (.a = 1) if q25_a == 1
recode visits_covid (.a = 0) if q25_a == 0

*fac_number
* Note: recoded 0's and 1's in q27 during cleaning 
gen fac_number = 1 if q26 == 1 
recode fac_number (. = 2) if q27 == 2 | q27 == 3
recode fac_number (. = 3) if q27 > 3 & q27 < . 
recode fac_number (. = .a) if q26 == .a & q27 == .a
recode fac_number (. = .d) if q27 == .d
recode fac_number (. = .r) if q26 == .r | q27 == .r
lab def fn 1 "1 facility (Q26 is yes)" 2 "2-3 facilities (Q27 is 2 or 3)" ///
		   3 "More than 3 facilities (Q27 is 4 or more)" .a "NA" .r "Refused" ///
		   .d "Don't know"
lab val fac_number fn 

* visits_home
gen visits_home = q28_a
gen visits_tele = q28_b

* tele_qual
gen tele_qual = q28_c
lab val tele_qual exc_poor
* Note - maybe move above lab val 

* visits_total
egen visits_total = rowtotal(q23_q24 q28_a q28_b)

* value label for all numeric var
lab val visits visits_covid visits_total visits_home visits_tele na_rf

* unmet_reason - confirm placements of 12-15
recode q42 (1 = 1 "Cost (High cost)") ///
			(2 = 2 "Convenience (Far distance)") ///
			(3 5 11 = 3 "Interpersonal quality (Long waiting time, Respect)") ///
			(4 = 4 "Technical quality (Poor provider skills)") ///
			(6 = 5 "Service readiness (Medicines and equipment not available)") ///
			(8 9 = 6 "COVID (COVID restritions or COVID fear)") ///
			(10 12 13 14 15 = 7 "Other") ///
			(.a 7 = .a "NA or Illness not serious") ///
			(.r = .r "Refused"), gen(unmet_reason)

* last_reason
gen last_reason = q45
lab def lr 1 "Urgent or new problem" 2 "Follow-up for chronic disease" ///
		   3 "Preventative or health check" 4 "Other" .a "NA" .r "Refused"
lab val last_reason lr

*last_wait_time
gen last_wait_time = 0 if q46 <= 15
recode last_wait_time (. = 1) if q46 >= 15 & q46 < 60
recode last_wait_time (. = 2) if q46 >= 60 & q46 < .
recode last_wait_time (. = .a) if q46 == .a
recode last_wait_time (. = .r) if q46 == .r
lab def lwt 0 "Short (15 minutes)" 1 "Moderate (< 1 hour)" 2 "Long (>= 1 hour)" ///
			.r "Refused" .a "NA"
lab val last_wait_time lwt

*last_sched_time
gen last_sched_time = q46b
lab val last_sched_time na_rf

*last_visit_time
gen last_visit_time = 0 if q47 <= 15
recode last_visit_time (. = 1) if q47 > 15 & q47 < .
recode last_visit_time (. = .a) if q47 == .a
recode last_visit_time (. = .r) if q47 == .r
lab def lvt 0 "<= 15 minutes" 1 "> 15 minutes " ///
			.r "Refused" .a "NA"
lab val last_visit_time lvt

* last_promote
gen last_promote = 0 if q49 < 8
recode last_promote (. = 1) if q49 == 8 | q49 == 9 | q49 == 10
recode last_promote (. = .a) if q49 == .a
recode last_promote (. = .r) if q49 == .r
lab def lp 0 "Detractor" 1 "Promoter" .r "Refused" .a "NA"
lab val last_promote lp

* system_outlook 
gen system_outlook = q57
lab val system_outlook system_outlook

* system_reform 
gen system_reform = q58
lab def sr 1 "Health system needs to be rebuilt" 2 "Health system needs major changes" /// 
		3 "Health system only needs minor chanes" .r "Refused", replace
lab val system_reform sr

**** Yes/No Questions ****

* health_chronic, ever_covid, covid_confirmed, usual_source, inpatient
* unmet_need 
* Yes/No/Refused - Q11 Q12 Q13 Q18 Q29 Q41 

gen health_chronic = q11
gen ever_covid = q12
gen covid_confirmed = q13 
gen usual_source = q18
recode usual_source (.a = 1) if (q18a_la == 1 & inlist(q19_q20a_la,1,2,3,4,6)) | q18b_la == 1
recode usual_source (.a = 0) if q18a_la == 0 | q18a_la == 1 & q18b_la == 0
recode usual_source (.a = .r) if q18b_la == .r


gen inpatient = q29 
gen unmet_need = q41 
lab val health_chronic ever_covid covid_confirmed usual_source ///
		inpatient unmet_need yes_no	
* blood_pressure mammogram cervical_cancer eyes_exam teeth_exam blood_sugar  
* blood_chol care_mental 
* Yes/No/Don't Know/Refused - Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q38 Q30 Q40 Q66 
gen blood_pressure = q30 
gen mammogram = q31
gen cervical_cancer = q32
gen eyes_exam = q33
gen teeth_exam = q34
gen blood_sugar = q35 
gen blood_chol = q36
gen hiv_test = q37_za
* Mia's note: need to gen a variable for q37_ng
gen care_mental = q38 
gen mistake = q39
gen discrim = q40
lab val blood_pressure mammogram cervical_cancer eyes_exam teeth_exam /// 
	blood_sugar blood_chol hiv_test care_mental mistake discrim yes_no_dk
lab val mistake discrim yes_no_na
	
**** Excellent to Poor scales *****	   

gen health = q9 
gen health_mental = q10 
gen last_qual = q48_a 
gen last_skills = q48_b 
gen last_supplies = q48_c 
gen last_respect = q48_d 
gen last_explain = q48_f 
gen last_decisions = q48_g
gen last_visit_rate = q48_h 
gen last_wait_rate = q48_i 
gen last_sched_rate = q48_k 
gen vignette_poor = q60
gen vignette_good = q61
lab val health health_mental last_qual last_skills last_supplies last_respect /// 
last_explain last_decisions last_visit_rate last_wait_rate last_sched_rate vignette_poor /// 
vignette_good exc_poor
	   
gen usual_quality =q22
gen last_know = q48_e
gen last_courtesy = q48_j
lab val usual_quality exc_pr_hlthcare
lab val last_know exc_pr_visits
lab val last_courtesy exc_poor_staff

gen phc_women = q50_a
gen phc_child = q50_b
gen phc_chronic = q50_c
gen phc_mental = q50_d
* Mia's note: need to gen a variable for q50_e_ng
lab val phc_women phc_child phc_chronic phc_mental exc_poor_judge
	
gen qual_public = q54
gen qual_private = q55 
gen covid_manage = q59
lab val qual_public qual_private covid_manage exc_poor

**** All Very Confident to Not at all Confident scales ****

* conf_sick conf_afford conf_opinion

recode q51 q52 ///
	   (3 2 = 1 "Somewhat confident/Very confident") ///
	   (0 1 = 0 "Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a na), /// 
	   pre(der) label(vc_nc_der)

gen conf_opinion = q53
lab val conf_opinion vc_nc

ren (derq51 derq52) (conf_sick conf_afford)

gen conf_getafford = .
replace conf_getafford=1 if conf_sick==1 & conf_afford==1
replace conf_getafford=0 if conf_sick==0 | conf_afford==0
replace conf_getafford=.r if conf_sick==.r | conf_afford==.r
lab val conf_getafford vc_nc_der

*urban/rural

recode q4 (9001 9002 9003 5006 5007 7006 7007 2009 2010 3009 3010 10012 10013 11001 11003 12001 13001 14001 12002 13002 14002 12003 13003 14003 15001 16001 16002 ///
           4015 4016 17001 17002 17003 18018 19021 20022 20023 = 1 "Urban") ///
          (9004 5008 7008 2011 3011 10014 11002 12004 13004 14004 15002 16003 4017 17004 18019 19020 20024 = 0 "Rural") ///
		  (.r = .r "Refused"), gen(urban)

* insurance status
* Note: All are insured in South Africa, Laos, Italy, Mendoza and UK
gen insured = q6 
recode insured (.a = 1) if country == 11 | country == 14 | country == 16 | country == 17
recode insured (.a = 0) if inlist(q7,7014,13014) | inlist(q6_kr, 3) 
recode insured (.a = 1) if inlist(q7,2015,2016,2017,2018,2028,7010,7011,7012,7013,10019,10020,10021,10022,13001,13002,13003,13004,13005,2015,2016,2017,2018, 2030) | inlist(q6_kr, 1, 2)
recode insured (.a = .r) if q7 == .r | inlist(q7,2995,13995) | q6_kr == .r
lab val insured yes_no


recode insured (.a = 1) if q6_za == 1
recode insured (.a = 0) if q6_za == 0

* For Colombia, moved "no insurance" to "yes" in insured and "public" in "insur_type"

* insur_type 

recode q7 (3001 5003 2017 2018 7010 7011 7012 10019 10020 10022 11002 12002 12003 12005 13001 13002 13003 13004 14002 16001 16002 16003 16004 4023 4024 4025 4026 17002 ///
           2030 18029 19031 20034 20037 = 0 Public) ///
		  (3002 5004 5005 5006 3007 9008 9009 2015 2016 2028 7013 10021 11001 12001 12004 13005 14001 16005 4027 17001 18004 18030 19032 19033 19034 20035 20036 = 1 Private) /// 
		  (2995 9995 12995 13995 4995 18995 19995 20995 = 2 Other) ///
		  (.r = .r "Refused") (7014 13014 16007 .a = .a NA), gen(insur_type)

recode insur_type (.a = 1) if q6_za == 1
recode insur_type (.a = 1) if q7_kr == 1
recode insur_type (.a = 0) if q7_kr == 0
		 	  
		  
* education

recode q8 (3001 3002 5007 9012 9013 2025 2026 7018 7019 10032 10033 11001 13001 14001 12001 15001 16001 16002 4039 17001 18045 19052 20058 = 0 "None (or no formal education)") ///
          (3003 5008 9014 9015 2027 7020 10034 11002 13002 14002 14003 12002 12003 15002 16003 4040 17002 18046 19053 20059 = 1 "Primary") ///
		  (3004 5009 9016 2028 7021 10035 11003 11004 14004 14005 13003 13004 12004 15003 15004 16004 4041 17003 18047 19054 19055 20060 = 2 "Secondary") ///
          (3005 5010 5011 9017 2029 2030 2031 7022 7023 7024 10036 10037 10038 11005 11006 14006 14007 ///
		  13005 13006 13007 12005 12006 15005 15006 15007 16005 16006 16007 4042 4043 4044 17004 17005 18048 18049 18050 19056 19057 20061 20062 = 3 "Post-secondary") ///
          (.r = .r "Refused"), gen(education)

		  
* usual_type_own
		  
recode q19_multi (1 = 0 "Public") (2 3 = 1 "Private") (4 = 2 "Other") /// 
		(.a = .a "NA") (.d = .d "Don't Know") (.r = .r "Refused"), ///
		gen(usual_type_own)

* Colombia recode
* Recode based on insurance type (but refusal for insurance defaults to q19_co_pe)
recode usual_type_own (.a = 1) if country == 2 & q7 == 2028 & q19_co_pe != .a 
recode usual_type_own (.a = 0) if country == 2 & inlist(q7,2017,2018,2030) & q19_co_pe != .a 
recode usual_type_own (.a = 2) if country == 2 & inlist(q7,2015,2016) & q19_co_pe != .a 
*recode usual_type_own (.a = .r) if country == 2 & q7 == .r

		
recode usual_type_own (.a = 0) if (q19_co_pe == 1) | q19_uy == 1 | ///
								  q19_q20a_la == 1 | q19_q20a_la == 2 |  ///
								  q19_q20b_la == 1 | q19_q20b_la == 2 | ///
								  q19_it == 1 | inlist(q19_mx,3,4) | ///
								  inlist(q20,12003,12004) | q19_kr == 1 | ///
								  q19_ar == 1 ///
								  | q19a_gb == 1 | q19b_gb == 1 | q19_gr == 1
								  							  
recode usual_type_own (.a = 1) if (q19_co_pe == 2) | q19_uy == 2 | ///
								  inlist(q19_q20a_la,3,4,6) | ///
								  inlist(q19_q20b_la,3,4,6) | ///
								  q19_it == 2 | q19_it == 3 | q19_mx == 6 | ///
								  inlist(q20,12001,12002,12005,12006) ///
								  | q19_kr == 3 | q19_ar == 3 ///
								  | q19a_gb == 2 | q19b_gb == 2 | q19_gr == 2
						  
recode usual_type_own (.a = 2) if inlist(q19_uy,5,995) | ///
								  q19_q20a_la == 9 | q19_q20b_la == 7 | ///
								  q19_it == 4 | inlist(q19_mx,1,2,5,7) | ///
								  q20 == 12995 | q19_kr == 4 | inlist(q19_ar,2,4,6,7) ///
								  | q19a_gb == 3 | q19_gr == 3
								  
recode usual_type_own (.a = .r) if (q19_co_pe  == .r )| q19_uy == .r | ///
								   q19_q20a_la == .r | q19_q20b_la == .r | ///
								   q19_it == .r | q19_mx == .r | ///
								   (q20 == .r & country == 12) | q19_kr == .r | ///
								   q19_ar == .r | q19a_gb == .r | q19b_gb == .r

*Peru recode 
*Recode based on q19_co_pe, but those who say public and have SHI are recoded to other 
recode usual_type_own (0 = 2) if country == 7 & inlist(q7,7011,7012)
								   
* usual type level								  

recode q20 (3001 3002 3003 3006 3007 3008 3011 5012 5014 5015 5017 5018 5020 9023 9024 9025 9026 9027 9028 9031 ///
			9032 9033 9036 2080 2085 2090 7001 7002 7040 7043 7045 7047 7048 10092 10094 10096 10098 10100 10102 ///
			10104 14001 14002 13001 13002 13005 13008 13009 13012 13013 13015 13017 13018 12001 12002 12003 12004 ///
			15001 15002 16001 16003 16005 16006 16009 4067 4068 4069 4072 4073 4074 17001 17002 17003 17004 17005 ///
			17006 19120 19122 19126 19124 19125 19129 19128 20131 20132 20135 20136 20137 20139 = 0 "Primary") /// 
		   (3004 3005 3009 3021 5013 5019 5021 9029 9030 9034 9035 9037 2081 2082 2086 2087 7008 7041 7042 7044 7046 7049 ///
		   10093 10097 10101 10105 14003 14004 13003 13004 13006 13007 13010 13011 13014 13016 13019 13020 12005 12006 ///
		   15003 15004 16002 16004 16007 16008 4070 4071 4075 4076 17007 17008 17009 19121 19127 19123 19130 ///
		   20133 20134 20138 20140 = 1 "Secondary (or higher)") ///
		   (.a 18106 18107 18108 18109 18110 18111 18112 18113 18115 18116 18117 = .a "NA") (3995 9995 12995 4995 18995 20995 .r = .r "Refused"), gen(usual_type_lvl)

recode usual_type_lvl (.a = 0) if inlist(q19_q20a_la,2,4,6) | ///
								  inlist(q19_q20b_la,2,4,6)
recode usual_type_lvl (.a = 1) if q19_q20a_la == 1 | q19_q20a_la == 3 | q19_q20b_la == 1 | q19_q20b_la == 3

recode usual_type_lvl (.a . .r = 0) if (q20a_gr == 1 | q20a_gr == 2) & country == 18

recode usual_type_lvl (.a . = 1) if (q20a_gr == 3 | q20a_gr == 4 | q20a_gr == 6) & country == 18

* NOTE: Maybe add an other for Laos? also for last visit level? But we will see with other, specify data
		   
* usual_type - ownership and level 
gen usual_type = . 
recode usual_type (. = 0) if usual_type_own == 0 & usual_type_lvl == 0
recode usual_type (. = 1) if usual_type_own == 0 & usual_type_lvl == 1
recode usual_type (. = 2) if usual_type_own == 1 & usual_type_lvl == 0
recode usual_type (. = 3) if usual_type_own == 1 & usual_type_lvl == 1
recode usual_type (. = 4) if usual_type_own == 2 & usual_type_lvl == 0
recode usual_type (. = 5) if usual_type_own == 2 & usual_type_lvl == 1
recode usual_type (. = .a) if usual_type_own == .a | usual_type_lvl == .a
recode usual_type (. = .r) if usual_type_own == .r | usual_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val usual_type fac_own_lvl


* last_type_own

recode q43_multi (1 = 0 Public) (2 3 = 1 Private) (4 = 2 Other) /// 
		(.a = .a NA) (.r = .r Refused), ///
		gen(last_type_own)

* Colombia recode
* Recode based on insurance type (but refusal for insurance defaults to q43_co_pe)
recode last_type_own (.a = 1) if country == 2 & q7 == 2028 & q43_co_pe != .a 
recode last_type_own (.a = 0) if country == 2 & inlist(q7,2017,2018,2030) & q43_co_pe != .a 
recode last_type_own (.a = 2) if country == 2 & inlist(q7,2015,2016) & q43_co_pe != .a 
*recode last_type_own (.a = .r) if country == 2 & q7 == .r

*Laos
recode last_type_own (.a = 0) if q43_la == 1 | q44 == 11002
recode last_type_own (.a = 1) if q43_la == 2 | q44 == 11003

recode last_type_own (.a = 0) if (q43_co_pe == 1) | q43_uy == 1 | ///
								 q43_it == 1 | inlist(q43_mx,3,4) | ///
								 inlist(q44,12003,12004,12005) | q43_kr == 1 | ///
								 q43_ar == 1 ///
								 | q43a_gb == 1 | q43b_gb == 1 | q43a_gr == 1

recode last_type_own (.a = 1) if (q43_co_pe == 2) | q43_uy == 2 | ///
								 q43_it == 2 | q43_it == 3 | q43_mx == 6 | ///
								 inlist(q44,12001,12002,12006,12007) | q43_kr == 3 | ///
								 q43_ar == 3 | q43a_gb == 2 | q43b_gb == 2 | q43a_gr == 2 | q43a_gr == 3
 
recode last_type_own (.a = 2) if inlist(q43_uy,5,995) | q43_it == 4 | inlist(q43_mx,1,2,5,7) | ///
								 q44 == 12995 | q43_kr == 4 | inlist(q43_ar,2,4,6,7) ///
								 | q43a_gb == 3 | q43a_gr == 5
								 
recode last_type_own (.a = .r) if (q43_co_pe == .r) | q43_uy == .r | ///
								  q43_it == .r | q43_mx == .r | ///
								  (q44 == .r & country == 12) | q43_kr == .r | ///
								  q43_ar == .r | q43a_gb == .r | q43b_gb == .r | q43a_gr == .r
								  
*Peru recode 
*Recode based on q19_co_pe, but those who say public and have SHI are recoded to other 
recode last_type_own (0 = 2) if country == 7 & inlist(q7,7011,7012)

* last type level
								  
recode q44 (3001 3002 3003 3006 3007 3008 3011 5012 5014 5015 5017 5018 5020 9023 9024 9025 9026 9027 9028 9031 9032 9033 9036 ///
		   2080 2085 2090 7001 7002 7040 7043 7045 7047 7048 10092 10094 10096 10100 10102 10104 11002 11003 ///
		   14001 14002 13001 13002 13005 13008 13009 13012 13013 13015 13017 13018 12001 12002 12003 12004 ///
		   15001 15002 16001 16003 16004 16005 4067 4068 4069 4072 4073 4074 17001 17002 17003 17004 17005 17006 ///
		   19120 19122 19124 19125 19128 19129 20131 20132 20135 20136 20137 20139 = 0 "Primary") /// 
		   (3004 3005 3009 3021 5013 5019 5021 9029 9030 9034 9035 9037 2081 2082 2086 2087 7008 7009 7041 7042 ///
		   7044 7046 7049 10093 10097 10101 10103 10105 11001 14003 14004 13003 13004 13006 13007 13010 13014 13016 ///
		   13019 13020 12005 12006 12007 15003 15004 16002 16006 16007 4070 4071 4075 4076 17007 17008 17009 19121 ///
		   19127 19130 19123 20133 20134 20138 20140 = 1 "Secondary (or higher)") ///
		   (.a 18106 18107 18108 18109 18110 18111 18112 18113 18115 18116 18117 = .a "NA") ///
		   (3995 9995 11995 12995 13995 4995 18995 20995 .r = .r "Refused"), gen(last_type_lvl)

* Greece recode
recode last_type_lvl (.a = 0) if q44a_gr == 1 | q44a_gr == 2
recode last_type_lvl (.a = 1) if q44a_gr == 3 | q44a_gr == 4 | q44a_gr == 6		   
		   
		      
* last_type - ownership and level
gen last_type = . 
recode last_type (. = 0) if last_type_own == 0 & last_type_lvl == 0
recode last_type (. = 1) if last_type_own == 0 & last_type_lvl == 1
recode last_type (. = 2) if last_type_own == 1 & last_type_lvl == 0
recode last_type (. = 3) if last_type_own == 1 & last_type_lvl == 1
recode last_type (. = 4) if last_type_own == 2 & last_type_lvl == 0
recode last_type (. = 5) if last_type_own == 2 & last_type_lvl == 1
recode last_type (. = .a) if last_type_own == .a | last_type_lvl == .a
recode last_type (. = .r) if last_type_own == .r | last_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val last_type fac_own_lvl

* minority

*Notes: No data for AR, For India: No actual data for Bodo" or "Dogri" but it is in the country-specific sheet.
recode q62 (11002 11003 11001 = .a) // First recode all to .a for Laos since we will be using q62a_la

recode q62 (5001 5005 5008 5009 5010 5011 5012 5013 5014 5015 3023 3024 3025 ///
		   3026 3027 3028 3029 3030 3031 3032 7044 7045 7049 2081  ///
		   15002 9035 9036 9037 9038 9041 9044 2995 3995 5995 11995 3995 9995 ///
		   4055 4062 4063 4064 4066 4068 4070 4071 4072 4073 4995 11002 11003 11005 18995 19092 19093 19995 ///
		   20097 20099 20103 20104 20105 20107 20108 20109 20995 = 1 "Minority group") /// 
		   (5002 5003 5004 5006 5007 3021 3022 7053 2087 15001 9033 ///
		   9034 9039 9040 9042 9043 4060 4056 4067 4075 4074 4059 4076 4061 4069 4065 11001 18090 19091 ///
		   20094 20095 20096 20098 20100 20101 20102 20106 = 0 "Majority group") /// 
		   (.r = .r "Refused") (.a = .a "NA"), gen(minority)
		   
*US & MX:
recode minority (.a = 1) if q62_mx == 1		   
recode minority (.a = 1) if q62a_us == 1
recode minority (.a = 1) if inlist(q62b_us,1,2,3,4,6,995)

*US:white and non-hispanic group = majority:
recode minority (.a = 0) if (q62b_us == 5 & q62a_us == 2)
recode minority (.a = .r) if q62b_us == .r & q62a_us == .r // (two refused q62a_us but answered q62b_us)

*Mexico majority group (doesn't speak indigenous language)
recode minority (.a = 0) if q62_mx == 0
recode minority (.a = .r) if q62_mx == .r 

*UK
recode minority (.a = 1) if inlist(q62_gb,1,2,3,5)
recode minority (.a = 0) if q62_gb == 4	
recode minority (.a = .r) if q62_gb == .r   

*Laos:
recode minority (.a = 1) if inlist(q62a_la,11002,11003,11004,11005)
recode minority (.a = 0) if q62a_la == 11001

* income 
* Note - this is the income categories trying to reflex tertiles as close as possible based on distribution in sample 

recode q63 (2039 2040 2041 3009 5001 7031 7032 9015 9016 9017 10049 ///
		   10050 10051 10052 11001 11002 12001 12002 13001 14001 14002 15001 15002 ///
		   15003 15004 16001 16002 16003 17001 17002 4024 4025 18062 19068 ///
		   20075 20076 20077 = 0 "Lowest income") /// 
		   (2042 2043 2044 3010 7033 9018 9019 10052 10053 10054 11003 ///
		   11004 12003 13002 14003 15005 15006 16004 16005 17003 17004 4026 4027 18063 18064 ///
		   18065 18066 18067 18082 18083 18084 19069 19070 19071 19072 19073 ///
		   20078 20079 = 1 "Middle income") /// 
		   (2045 2048 3011 3012 3013 3014 5002 5003 5004 5005 5006 5007 7034 7035 ///
		   7036 7037 7038 9020 9021 9022 9023 10055 10061 11005 11006 11007 12004 ///
		   12005 13003 13004 13005 14004 14005 14006 14007 15007 15008 16005 16006 ///
		   16007 17005 17006 4028 4029 4030 18085 19074 20080 20081 = 2 "Highest income") ///
		   (.r = .r "Refused") (.d = .d "Don't know"), gen(income)
		  
* Recode extreme values to missing 

* All visit count variables and wait time variables:

* q23, q25_b, q28_a, q28_b

* Mia's note: check extreme values for Nigeria needed
qui levelsof country, local(countrylev)

foreach i in `countrylev' {
	
	if !inlist(`i', 12, 13, 14, 17) {
		extremes visits_home country if country == `i', high
	}
	
	foreach var in visits visits_covid visits_tele {

		
		extremes `var' country if country == `i', high
	}
}

* Colombia q28_b values seem implausible
recode visits_tele (80 = .) if country == 2 
* Ethiopia: 92 visits for q28 
recode visits_home (92 = .) if country == 3 
* India 2 visits value and 3 visit_home value
replace visits = . if visits > 60 & visits < . & country == 4 
replace visits_home = . if visits_home > 60 & visits_home < . & country == 4 
*South Africa: 120 visits for q28
recode visits_home (120 = .) if country == 9 
* South Africa; 144 visits for q23
recode visits (144 = .) if country == 9 
* Uruguay: q23 values seem implausible 
recode visits (200 = .) (156 = .) if country == 10 
* US visits, 4 values recoded
replace visits = . if visits > 60 & visits < . & country == 12 
* Italy visits, 1 value recoded 
replace visits = . if visits > 60 & visits < . & country == 14 
* Korea, 1 visit_home and 1 visit_covid value, 5 visit values
recode visits_home (68 = .) if country == 15 
recode visits_covid (80 = .) if country == 15 
replace visits = . if visits > 60 & visits < . & country == 15 
* Argentina (Mendoza) visits, 4 value recoded, visits_tele, 1 value recoded 
replace visits = . if visits > 50 & visits < . & country == 16 
recode visits_tele (96 = .) if country == 16 
* UK 
recode visits (150 = .) if country == 17
recode visits_tele (100 = .) if country == 17

*** New country var based on region ***
recode country (3 = 1 "Ethiopia") (5 = 2 "Kenya") ///
			   (20 = 3 "Nigeria") (9 = 4 "South Africa") ///
			   (7 = 5 "Peru") (2 = 6 "Colombia") ///
			   (13 = 7 "Mexico") (10 = 8 "Uruguay") ///
			   (16 = 9 "Argentina") (11 = 10 "Lao PDR") ///
			   (4 = 11 "India") (15 = 13 "Rep. of Korea") ///
			   (19 = 14 "Romania") (18 = 15 "Greece") ///
			   (14 = 16 "Italy") (17 = 17 "United Kingdom") ///
			   (12 = 18 "United States"), gen(country_reg)
lab var country_reg "Country (ordered by region)" 


* Drop trimmed q27 q46 q47 and get back the orignal var
drop q27 q46 q47 q46b
rename q27_original  q27
rename q46_original  q46
rename q47_original  q47
rename q46b_origial  q46b

*** Political alignment***

**Import excel as updatas and save it as .dta
/*import excel "$data_mc/03 input output/Input/Policial alignment variable/Pol_align_recode_all.xlsx", sheet("pol_al") firstrow clear
destring q5 pol_align, replace float
save "$data_mc/03 input output/Input/Policial alignment variable/pol_align.dta", replace
*/

merge m:m q5 using "$data_mc/03 input output/Input/Policial alignment variable/pol_align.dta" 
drop _merge
lab def pol_align 0 "Aligned (in favor)" 1 "Not aligned (out of favor)" .a "NA"
lab val pol_align pol_align


*****************************

**** Order Variables ****
		   
order respondent_serial respondent_id country country_reg language date /// 
	  int_length mode weight psu_id_for_svy_cmds age age_cat gender urban region ///
	  insured insur_type education health health_mental health_chronic ///
	  ever_covid covid_confirmed covid_vax covid_vax_intent activation ///
	  usual_source usual_type_own usual_type_lvl usual_type ///
	  usual_reason usual_quality visits visits_cat visits_covid ///
	  fac_number visits_home visits_tele tele_qual visits_total inpatient blood_pressure mammogram ///
	  cervical_cancer eyes_exam teeth_exam blood_sugar blood_chol hiv_test care_mental /// 
	  mistake discrim unmet_need unmet_reason last_type_own last_type_lvl ///
	  last_type last_reason last_wait_time last_sched_time ///
	  last_visit_time last_qual last_skills last_supplies last_respect last_know ///
	  last_explain last_decisions last_visit_rate last_wait_rate last_courtesy last_sched_rate ///
	  last_promote phc_women phc_child phc_chronic phc_mental conf_sick ///
	  conf_afford conf_getafford conf_opinion qual_public qual_private ///
	  system_outlook system_reform covid_manage vignette_poor /// 
	  vignette_good minority income pol_align q1 q2 q3 q3a_co_pe_uy_ar q4 q5 q5_other q6 q6_it q6_kr q6_la q6_za q6_gb q7 q7_kr ///
	  q7_other q8 q9 q10 q11 q12 q13 q13b_co_pe_uy_ar q13e* q13e_other* q14 q14_la q15 q15_la q16 q17 q18 ///
	  q18a_la q18b_la q19_co q19_multi q19_gr_other q19_it q19a_gb q19b_gb q19_other_gb q19_kr q19_mx ///
	  q19_co_pe q19_uy q19_ar q19_other ///
	  q19_q20a_la q19_q20a_other q19_q20b_la ///
	  q19_q20b_other q20 q20_other q20a_gr q20a_gr_other q20b_gr q20b_gr_other q20c_gr q20c_gr_other q21 q21_other q22 ///
	  q23 q24 q23_q24 q25_a q25_b q26 q27 q28_a q28_b q28_c q29 q30 q31 q32 q33 q34 q35 q36 ///
	  q37_za q37_gr_in_ro q37_ng q38 q39 q40 q41 q42 q42_other q43_ar q43_co_pe q43_multi q43a_gr q43b_gr q43_la q43_it q43_kr q43_mx ///
	   q43_uy q43_other q43a_gb q43b_gb q43_other_gb q44 ///
	  q44_other q44a_gr q44a_gr_other q44b_gr q44b_gr_other q45 q45_other q46 q46_refused q46a q46b q46b_refused ///
	  q47 q47_refused ///
	  q48_a q48_b q48_c q48_d q48_e q48_f q48_g q48_h q48_i q48_j q48_k q49 q50_a ///
	  q50_b q50_c q50_d q50_e_ng q51 q52 q53 q54 q55 q56_multi q56_pe q56_uy q56a_mx q56b_mx q56a_ar q56b_ar q56c_ar q57 q58 q59 ///
	  q60 q61 q62 q62_gb q62_other q62_mx q62a_la q62a_other_la q62a_us q62b_us q62b_other_us q63 q64 q65 q66 q66a_us q66b_us q66_gb q66a_gr q66b_gr q69_gr
	   	  
***************************** Labeling variables ***************************** 
 
lab var age "Exact respondent age or midpoint of age range (Q1/Q2)"
lab var age_cat "Age (categorical) (Q1/Q2)"
lab var gender "Gender (Q3)" 
lab var urban "Respondent lives in urban vs rural area (Q4)"
lab var region "Region where respondent lives (County, state, province, etc.) (Q5)"
lab var insured "Insurance status (Q6)"
lab var insur_type "Type of insurance (for those who have insurance) (Q7)" 
lab var education "Highest level of education completed (Q8)"
lab var	health "Self-rated health (Q9)"
lab var	health_mental "Self-rated mental health (Q10)"
lab var	health_chronic "Longstanding illness or health problem (chronic illness) (Q11)"
lab var	ever_covid "Ever had COVID-19 or coronavirus (Q12)"
lab var	covid_confirmed	"COVID-19 or coronavirus confirmed by a test (Q13)"
lab var	covid_vax "COVID-19 vaccination status (Q14)"
lab var	covid_vax_intent "Intent to receive all recommended COVID vaccine doses if available (Q15)"
lab var	activation "Patient activation: manage overall health and tell a provider concerns (Q16/Q17)"
lab var	usual_source "Whether respondent has a usual source of care (Q18)"
lab var	usual_type_own "Facility ownership for usual source of care (Q19)"
lab var	usual_type_lvl "Facility level for usual source of care (Q20)"
lab var	usual_type "Facility ownership and level for usual source of care (Q19/Q20)"
lab var	usual_reason "Main reason for choosing usual source of care facility (Q21)"
lab var	usual_quality "Overall quality rating of usual source of care (Q22)"
lab var	visits "Visits (continuous) made in-person to a facility in past 12 months (Q23/Q24)"
lab var	visits_cat "Visits (categorical) made in-person to a facility in past 12 months (Q23/Q24)"
lab var	visits_covid "Number of visits made for COVID in past 12 months (Q25A/Q25B)"
lab var	fac_number "Number of facilities visited during the past 12 months (Q26/Q27)"
lab var visits_home "Number of visits made by healthcare provider at home (Q28A)"
lab var visits_tele "Number of virtual or telemedicine visits (Q28B)"
lab var	visits_total "Total number of healthcare contacts: facility, home, and tele (Q23/Q28A/Q28B)"
lab var	inpatient "Stayed overnight at a facility in past 12 months (inpatient care) (Q29)"
lab var	blood_pressure "Blood pressure checked by healthcare provider in past 12 months (Q30)"
lab var	mammogram "Mammogram conducted by healthcare provider in past 12 months (Q31)"
lab var	cervical_cancer "Cervical cancer screening done by healthcare provider in past 12 months (Q32)"
lab var	eyes_exam "Eyes checked by healthcare provider in past 12 months (Q33)"
lab var	teeth_exam "Teeth checked by healthcare provider in past 12 months (Q34)"
lab var	blood_sugar "Blood sugar tested by healthcare provider in past 12 months (Q35)"
lab var	blood_chol "Blood cholesterol tested by healthcare provider in past 12 months (Q36)"		
lab var	hiv_test "ZA only: HIV test conducted by healthcare provider in past 12 months (Q37_ZA)"
lab var	care_mental	"Received care for depression, anxiety, or another mental health condition (Q38)"
lab var	mistake	"A medical mistake was made in treatment or care in the past 12 months (Q39)"	
lab var	discrim	"You were treated unfairly or discriminated against in the past 12 months (Q40)"	
lab var	unmet_need "Needed medical attention but did not get healthcare (Q41)"
lab var	unmet_reason "Reason for not getting healthcare when needed medical attention (Q42)"
lab var	last_type_own "Facility ownership for last visit to a healthcare provider (Q43)"
lab var	last_type_lvl "Facility level for last visit to a healthcare provider (Q44)"
lab var last_type "Facility ownership and level for last visit to a healthcare provider (Q43/Q44)"
lab var	last_reason	"Reason for last healthcare visit (Q45)" 
lab var	last_wait_time "Length of time waited for last visit to a healthcare provider (Q46)"
lab var	last_visit_time "Length of time spent with the provider during last healthcare visit (Q47)"
lab var	last_qual "Last visit rating: overall quality (Q48A)"
lab var	last_skills "Last visit rating: knowledge and skills of provider (Care competence) (Q48B)"
lab var	last_supplies "Last visit rating: equipment and supplies provider had available (Q48C)"
lab var	last_respect "Last visit rating: provider respect (Q48D)"
lab var	last_know "Last visit rating: knowledge of prior tests and visits (Q48E)"
lab var	last_explain "Last visit rating: explained things in an understandable way (Q48F)"
lab var	last_decisions "Last visit rating: involved you in decisions about your care (Q48G)"
lab var	last_visit_rate "Last visit rating: amount of time provider spent with you (Q48H)"
lab var	last_wait_rate "Last visit rating: amount of time you waited before being seen (Q48I)"
lab var	last_courtesy "Last visit rating: courtesy and helpfulness of the staff (Q48J)"
lab var	last_promote "Net promoter score for facility visited for last visit (Q49)"
lab var	phc_women "Public primary care system rating for: pregnant women (Q50A)"
lab var	phc_child "Public primary care system rating for: children (Q50B)"
lab var	phc_chronic "Public primary care system rating for: chronic conditions (Q50C)"
lab var	phc_mental "Public primary care system rating for: mental health (Q50D)"
lab var	conf_sick "Confidence in receiving good quality healthcare if became very sick (Q51)"
lab var	conf_afford	"Confidence in ability to afford care healthcare if became very sick (Q52)"
lab var	conf_opinion "Confidence that the gov considers public's opinion when making decisions (Q53)"
lab var	qual_public	"Overall quality rating of gov or public healthcare system in country (Q54)"
lab var	qual_private "Overall quality rating of private healthcare system in country (Q55)" 
lab var	system_outlook "Health system opinion: getting better, staying the same, or getting worse (Q57)"
lab var	system_reform "Health system opinion: minor, major changes, or must be completely rebuilt (Q58)" 
lab var	covid_manage "Rating of the government's management of the COVID-19 pandemic (Q59)" 
lab var	vignette_poor "Rating of vignette in Q60 (poor care)"
lab var	vignette_good "Rating of vignette in Q61 (good care)"
lab var	minority "Minority group (based on native language, ethnicity or race) (Q62)"
lab var	income "Income group (Q63)"
lab var tele_qual "Overall quality of last telemedicine visit (Q28C)"
lab var last_sched_time "Length of days between scheduling visit and seeing provider (Q46b)"
lab var last_sched_rate "Last visit rating: time between scheduling visit and seeing provider (Q48K)"
lab var conf_getafford "Confidence in receiving and affording healthcare if became very sick (Q51/Q52)"
lab var pol_align "Political alignment in respondent's region / district / state"



**************************** Save data *****************************

notes drop _all
compress 
save "$data_mc/02 recoded data/pvs_all_countries.dta", replace


/*
**************=Save individual datasets to recoded data folder****************

*Colombia
preserve
keep if country == 2
save "$data/Colombia/02 recoded data/pvs_colombia_recoded", replace
restore

*Ethiopia
preserve
keep if country == 3
save "$data/Ethiopia/02 recoded data/pvs_ethiopia_recoded", replace
restore

*India
preserve
keep if country == 4
save "$data/India/02 recoded data/pvs_india_recoded", replace
restore

*Kenya
preserve
keep if country == 5
save "$data/Kenya/02 recoded data/pvs_kenya_recoded", replace
restore

*Peru
preserve
keep if country == 7
save "$data/Peru/02 recoded data/pvs_peru_recoded", replace
restore

*South Africa
preserve
keep if country == 9
save "$data/South Africa/02 recoded data/pvs_za_recoded", replace
restore

*Uruguay
preserve
keep if country == 10
save "$data/Uruguay/02 recoded data/pvs_uruguay_recoded", replace
restore

*Lao PDR
preserve
keep if country == 11
save "$data/Laos/02 recoded data/pvs_laos_recoded", replace
restore

*United States - saved in multi country recoded folder
preserve
keep if country == 12
save "$data_mc/02 recoded data/pvs_us_recoded", replace
restore

*Mexico - saved in multi country recoded folder
preserve
keep if country == 13
save "$data_mc/02 recoded data/pvs_mx_recoded", replace
restore

*Italy - saved in multi country recoded folder
preserve
keep if country == 14
save "$data_mc/02 recoded data/pvs_it_recoded", replace
restore

*South Korea
preserve
keep if country == 15
save "$data/South Korea/recoded data/pvs_korea_recoded", replace
restore

*Argentina
preserve
keep if country == 16
save "$data/Argentina (Mendoza)/02 recoded data/pvs_argentina_recoded", replace
restore

*United Kingdown
preserve
keep if country == 17
save "$data/United Kingdom/02 recoded data/pvs_gb_recoded"
restore

*Greece
preserve
keep if country == 18
save "$data/Greece/02 recoded data/pvs_gr_recoded"
restore

*Romania
preserve
keep if country == 19
save "$data/Romania/02 recoded data/pvs_ro_recoded"
restore

*Nigeria 
preserve
keep if country == 20
save "$data/Nigeria/02 recoded data/pvs_ng_recoded"
restore

*/


* ONLY RUN COMMAND BELOW WHEN SHARING TO ALL
* save "$data/Multi-country (shared)/pvs_all_countries.dta", replace 


