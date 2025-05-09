use "birds (1).dta", clear

* Preparing data (encoding string variables and replacing missing values with zeros for snow and speed)

encode AMCloud, gen(amcloud_num)
encode PMCloud, gen(pmcloud_num)
encode StillWater, gen(stillwater_num)
encode MovingWater, gen(movingwater_num)
encode WindDirection, gen(winddirection_num)
encode Am_rain_cond_Names, gen(am_rain_cond_num)
encode Pm_rain_cond_Names, gen(pm_rain_cond_num)
encode Am_snow_cond_Names, gen(am_snow_cond_num)
encode Pm_snow_cond_Names, gen(pm_snow_cond_num)

replace Min_snow = 0 if Min_snow == .
replace Max_snow = 0 if Max_snow == .
replace Min_wind = 0 if Min_wind == .
replace Max_wind = 0 if Max_wind == .



* Winsorising data at the 99th percentile to exclude extreme values that may skew estimates

ssc install winsor2, replace

local vars_to_winsorize num_tot num_grassland num_woodland num_wetland num_otherhabitat num_urban num_nonurban num_resident num_shortmigration num_longermigration spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration population c_num_turbines c_shalewells Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow amcloud_num pmcloud_num stillwater_num movingwater_num winddirection_num am_rain_cond_num pm_rain_cond_num am_snow_cond_num pm_snow_cond_num


foreach var of local vars_to_winsorize {
    winsor2 `var', replace cut(0 99)
}



* Transforming Winsorised results with asinh()

replace ihs_num_tot            = asinh(num_tot)
replace ihs_num_grassland      = asinh(num_grassland)
replace ihs_num_woodland       = asinh(num_woodland)
replace ihs_num_wetland        = asinh(num_wetland)
replace ihs_num_otherhabitat   = asinh(num_otherhabitat)
replace ihs_num_urban          = asinh(num_urban)
replace ihs_num_nonurban       = asinh(num_nonurban)
replace ihs_num_resident       = asinh(num_resident)
replace ihs_num_shortmig       = asinh(num_shortmigration)
replace ihs_num_longermig      = asinh(num_longermigration)

replace ihs_spec_tot           = asinh(spec_tot)
replace ihs_spec_grassland     = asinh(spec_grassland)
replace ihs_spec_woodland      = asinh(spec_woodland)
replace ihs_spec_wetland       = asinh(spec_wetland)
replace ihs_spec_otherhabitat  = asinh(spec_otherhabitat)
replace ihs_spec_urban         = asinh(spec_urban)
replace ihs_spec_nonurban      = asinh(spec_nonurban)
replace ihs_spec_resident      = asinh(spec_resident)
replace ihs_spec_shortmig      = asinh(spec_shortmigration)
replace ihs_spec_longermig     = asinh(spec_longermigration)
replace lnpop = asinh(population)
replace ihs_c_num_turbines        = asinh(c_num_turbines)
replace ihs_c_shalewells      = asinh(c_shalewells)


* Creating DID treatment variables

gen turbine_ever_treated = 0
bysort circle_id (year): egen max_turbine = max(any_turbine)
replace turbine_ever_treated = max_turbine

bysort circle_id (year): egen first_turbine = min(cond(any_turbine == 1, year, .))
gen post_turbine = (year >= first_turbine & !missing(first_turbine))
gen turbine_did = (turbine_ever_treated == 1 & post_turbine == 1)


gen shale_ever_treated = 0
bysort circle_id (year): egen max_shale = max(any_shale)
replace shale_ever_treated = max_shale

bysort circle_id (year): egen first_shale = min(cond(any_shale == 1, year, .))
gen post_shale = (year >= first_shale & !missing(first_shale))
gen shale_did = (shale_ever_treated == 1 & post_shale == 1)

gen shale_did_continuous = shale_ever_treated*c_shalewells
gen turbine_did_continuous = turbine_ever_treated*c_num_turbines



* Using regression (1) to estimate treatment effects in the bivariate and continuous settins

* Katovich variables for Turbines bird count 

xtset circle_id year

xtreg ihs_num_tot turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_grassland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_woodland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_wetland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_otherhabitat turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_urban turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_nonurban turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_resident turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_shortmigration turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_longermigration turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)




* Katovich variables for Turbines bird species

xtset circle_id year

xtreg ihs_spec_tot turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_grassland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_woodland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_wetland turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_otherhabitat turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_urban turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_nonurban turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_resident turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_shortmig turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_longermig turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Katovich controls for Shale Wells bird count

xtset circle_id year

xtreg ihs_num_tot shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_grassland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_woodland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_wetland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_otherhabitat shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_urban shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_nonurban shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_resident shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_shortmigration shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_longermigration shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Katovich variables for Shale Wells bird species

xtset circle_id year

xtreg ihs_spec_tot shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_grassland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_woodland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_wetland shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_otherhabitat shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_urban shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_nonurban shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_resident shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_shortmig shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_spec_longermig shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)




********************************************************************************

* A small note on average bird counts in untreated circles to better consider economic significance

mean num_tot if turbine_did == 0
mean num_tot if shale_did == 0



********************************************************************************

* Exteneded list of controls - Turbines on bird count

xtset circle_id year

xtreg ihs_num_tot turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_grassland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_woodland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_wetland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_otherhabitat turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_urban turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_nonurban turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_resident turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_shortmigration turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_longermigration turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)



* Exteneded list of controls - Turbines on bird species

xtset circle_id year

xtreg ihs_spec_tot turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_grassland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_woodland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_wetland turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_otherhabitat turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_urban turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_nonurban turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_resident turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_shortmig turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_longermig turbine_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)



* Exteneded list of controls - Shales Wells on bird count

xtset circle_id year

xtreg ihs_num_tot shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_grassland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_woodland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_wetland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_otherhabitat shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_urban shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_nonurban shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_shortmigration shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_num_longermigration shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)



* Exteneded list of controls - Shales Wells on bird species

xtset circle_id year

xtreg ihs_spec_tot shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_grassland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_woodland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_wetland shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_otherhabitat shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_urban shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_nonurban shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_resident shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_shortmig shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)

xtreg ihs_spec_longermig shale_did total_effort_counters Min_temp Max_temp Min_snow Max_snow Min_wind Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow stillwater_num movingwater_num winddirection_num latitude longitude i.year, fe cluster(circle_id)



********************************************************************************
* This part will try assess the paralell trends assumption by plotting trend lines



* Exploring the distribution curve of shale wells and turbine installments to determine the pseudo treatment year

tab first_shale if shale_ever_treated == 1
tab first_turbine if turbine_ever_treated == 1


* Generating aligned treatment event time (for Shales) - 2010 is chosed as preudo year since it lies in the middle of the distribution of installed plants throughout 2000 and 2020

gen pseudo_shale_year = 2010 if shale_ever_treated == 0
gen align_year_shale = first_shale
replace align_year_shale = pseudo_shale_year if missing(align_year_shale)
gen event_time_shale = year - align_year_shale
gen in_window_shale = event_time_shale >= -10 & event_time_shale <= 10

* Calculating average bird count by event year

egen avg_treated_shale = mean(ihs_num_tot) if shale_ever_treated == 1 & in_window_shale == 1, by(event_time_shale)
egen avg_control_shale = mean(ihs_num_tot) if shale_ever_treated == 0 & in_window_shale == 1, by(event_time_shale)

* Collapsing to one row per event time

preserve
keep if in_window_shale
keep event_time_shale avg_treated_shale avg_control_shale
collapse (mean) avg_treated_shale avg_control_shale, by(event_time_shale)

* Plotting

twoway (line avg_treated_shale event_time_shale, lcolor(red) lwidth(medthick)) (line avg_control_shale event_time_shale, lcolor(red) lpattern(dash) lwidth(medthick)), legend(order(1 "Treated - Shale" 2 "Control - Shale") ring(0) pos(1) region(lstyle(none))) xline(0, lcolor(black) lpattern(dot)) xtitle("Years Since Treatment", size(medsmall)) ytitle("Avg IHS Bird Count", size(medsmall)) title("Parallel Trends: Shale Wells", size(medlarge)) xlabel(-10(2)10, labsize(small)) graphregion(color(white)) plotregion(margin(zero))

restore



* Generating aligned treatment event time (for Turbines)

gen pseudo_turbine_year = 2010 if turbine_ever_treated == 0
gen align_year_turbine = first_turbine
replace align_year_turbine = pseudo_turbine_year if missing(align_year_turbine)
gen event_time_turbine = year - align_year_turbine
gen in_window_turbine = event_time_turbine >= -10 & event_time_turbine <= 10

* Calculating average bird count by event year

egen avg_treated_turbine = mean(ihs_num_tot) if turbine_ever_treated == 1 & in_window_turbine == 1, by(event_time_turbine)
egen avg_control_turbine = mean(ihs_num_tot) if turbine_ever_treated == 0 & in_window_turbine == 1, by(event_time_turbine)

* Collapsing to one row per event time

preserve
keep if in_window_turbine
keep event_time_turbine avg_treated_turbine avg_control_turbine
collapse (mean) avg_treated_turbine avg_control_turbine, by(event_time_turbine)

* Plotting

twoway (line avg_treated_turbine event_time_turbine, lcolor(blue) lwidth(medthick)) (line avg_control_turbine event_time_turbine, lcolor(blue) lpattern(dash) lwidth(medthick)), legend(order(1 "Treated" 2 "Control") ring(0) pos(1) region(lstyle(none))) xline(0, lcolor(black) lpattern(dot)) xtitle("Years Since Treatment", size(medsmall)) ytitle("Avg IHS Bird Count", size(medsmall)) title("Wind Turbines", size(medlarge)) xlabel(-10(2)10, labsize(small)) graphregion(color(white)) plotregion(margin(zero))

restore



********************************************************************************
* This part will add an interaction variable to allow for unique trends within each circle, hence relieving the prallel trends assumption


* The effect of Turbines on Bird count (revisited)

xtset circle_id year

xtreg ihs_num_tot turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year i.circle_id#c.year, fe cluster(circle_id)

display "Coef: " _b[turbine_did]
display "SE:   " _se[turbine_did]
display "P-val: " 2*ttail(e(df_r), abs(_b[turbine_did]/_se[turbine_did]))



* The effect of Shale Wells on Bird count (revisited)

xtset circle_id year

xtreg ihs_num_tot shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year i.circle_id#c.year, fe cluster(circle_id)

display "Coef: " _b[shale_did]
display "SE:   " _se[shale_did]
display "P-val: " 2*ttail(e(df_r), abs(_b[shale_did]/_se[shale_did]))



* The effect of Turbines on Species count (revisited)

xtset circle_id year

xtreg ihs_spec_tot turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year i.circle_id#c.year, fe cluster(circle_id)

display "Coef: " _b[turbine_did]
display "SE:   " _se[turbine_did]
display "P-val: " 2*ttail(e(df_r), abs(_b[turbine_did]/_se[turbine_did]))



* The effect of Shale Wells on Species count (revisited)

xtset circle_id year

xtreg ihs_spec_tot shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year i.circle_id#c.year, fe cluster(circle_id)

display "Coef: " _b[shale_did]
display "SE:   " _se[shale_did]
display "P-val: " 2*ttail(e(df_r), abs(_b[shale_did]/_se[shale_did]))



********************************************************************************
* This part will perform a Placebo test for a matter of robustness check


* Turbines

xtset circle_id year

* Running the actual model and storing true coefficient
xtreg ihs_num_tot turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)
scalar real_effect = _b[turbine_did]

* Saving the original dataset
tempfile original
save `original', replace

* Creating empty results dataset
clear
set obs 100
gen placebo_id = _n
gen placebo_effect = .
tempfile placebo_results
save `placebo_results', replace

* Looping over 100 placebo assignments
forvalues i = 1/100 {
    use `original', clear

    * Generating random placebo treatment
    gen rand = runiform()
    gen placebo_treat = 0
    quietly sum turbine_did
    local treat_share = r(mean)
    replace placebo_treat = 1 if rand < `treat_share'

    * Running placebo regression
    quietly xtreg ihs_num_tot placebo_treat total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)
    scalar b = _b[placebo_treat]

    * Saving result in the placeholder dataset
    use `placebo_results', clear
    replace placebo_effect = b in `i'
    save `placebo_results', replace
}

* Loading results and plotting histogram
use `placebo_results', clear

histogram placebo_effect, bin(20) color(gs13) xline(`=real_effect', lcolor(red) lwidth(medthick) lpattern(solid)) title("Placebo Distribution vs Real Effect") subtitle("Red line = True Turbine Effect") xtitle("Estimated Coefficient") ytitle("Frequency") note("Placebo test with 100 random assignments") legend(off)
display "True effect of turbine_did = " real_effect
display "Real effect of turbine_did = " real_effect



* Shale wells

xtset circle_id year

* Running the actual model and storing true coefficient
xtreg ihs_num_tot shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)
scalar real_effect = _b[shale_did]

* Saving the original dataset
tempfile original
save `original', replace

* Creating empty results dataset
clear
set obs 100
gen placebo_id = _n
gen placebo_effect = .
tempfile placebo_results
save `placebo_results', replace

* Looping over 100 placebo assignments
forvalues i = 1/100 {
    use `original', clear

    * Generating random placebo treatment
    gen rand = runiform()
    gen placebo_treat = 0
    quietly sum turbine_did
    local treat_share = r(mean)
    replace placebo_treat = 1 if rand < `treat_share'

    * Running placebo regression
    quietly xtreg ihs_num_tot placebo_treat total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)
    scalar b = _b[placebo_treat]

    * Saving result in the placeholder dataset
    use `placebo_results', clear
    replace placebo_effect = b in `i'
    save `placebo_results', replace
}

* Loading results and plotting histogram
use `placebo_results', clear

histogram placebo_effect, bin(20) color(gs13) xline(`=real_effect', lcolor(red) lwidth(medthick) lpattern(solid)) title("Placebo Distribution vs Real Effect") subtitle("Red line = True Shale Effect") xtitle("Estimated Coefficient") ytitle("Frequency") note("Placebo test with 100 random assignments") legend(off)
display "True effect of shale_did = " real_effect
display "Real effect of shale_did = " real_effect



********************************************************************************
* This part will investigate how the estimated effect changes for circles that had longer post-treatment period



* Generating Shale windows

gen post_shale_win1 = (year >= first_shale & year <= first_shale + 1 & !missing(first_shale))
gen post_shale_win2 = (year >= first_shale + 2 & year <= first_shale + 3 & !missing(first_shale))
gen post_shale_win3 = (year >= first_shale + 4 & year <= first_shale + 5 & !missing(first_shale))
gen post_shale_win4 = (year >= first_shale + 6 & year <= first_shale + 7 & !missing(first_shale))
gen post_shale_win5 = (year >= first_shale + 8 & !missing(first_shale))

gen shale_did_win1 = (shale_ever_treated == 1 & post_shale_win1 == 1)
gen shale_did_win2 = (shale_ever_treated == 1 & post_shale_win2 == 1)
gen shale_did_win3 = (shale_ever_treated == 1 & post_shale_win3 == 1)
gen shale_did_win4 = (shale_ever_treated == 1 & post_shale_win4 == 1)
gen shale_did_win5 = (shale_ever_treated == 1 & post_shale_win5 == 1)



* Generating Turbine windows

gen post_turbine_win1 = (year >= first_turbine & year <= first_turbine + 1 & !missing(first_turbine))
gen post_turbine_win2 = (year >= first_turbine + 2 & year <= first_turbine + 3 & !missing(first_turbine))
gen post_turbine_win3 = (year >= first_turbine + 4 & year <= first_turbine + 5 & !missing(first_turbine))
gen post_turbine_win4 = (year >= first_turbine + 6 & year <= first_turbine + 7 & !missing(first_turbine))
gen post_turbine_win5 = (year >= first_turbine + 8 & !missing(first_turbine))

gen turbine_did_win1 = (turbine_ever_treated == 1 & post_turbine_win1 == 1)
gen turbine_did_win2 = (turbine_ever_treated == 1 & post_turbine_win2 == 1)
gen turbine_did_win3 = (turbine_ever_treated == 1 & post_turbine_win3 == 1)
gen turbine_did_win4 = (turbine_ever_treated == 1 & post_turbine_win4 == 1)
gen turbine_did_win5 = (turbine_ever_treated == 1 & post_turbine_win5 == 1)



* Effect of Turbines on Bird Population (Katovich covariates)

xtreg ihs_num_tot turbine_did_win1 turbine_did_win2 turbine_did_win3 turbine_did_win4 turbine_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Effect of Turbines on Species Count (Katovich covariates)

xtreg ihs_spec_tot turbine_did_win1 turbine_did_win2 turbine_did_win3 turbine_did_win4 turbine_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Effect of Shales on Bird Population (Katovich covariates)

xtreg ihs_num_tot shale_did_win1 shale_did_win2 shale_did_win3 shale_did_win4 shale_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Effect of Shales on Species count (Katovich covariates)

xtreg ihs_spec_tot shale_did_win1 shale_did_win2 shale_did_win3 shale_did_win4 shale_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



********************************************************************************
* This part will check if human population acted as a mediator in affecting the bird count



* Regression of the human population on the turbine arrival (bivariate)

xtreg lnpop turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the shale arrival (bivariate)

xtreg lnpop shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the turbine arrival (continious)

xtreg lnpop turbine_did_continuous total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the shale arrival (continious)

xtreg lnpop shale_did_continuous total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the bird count on the population

xtreg ihs_num_tot lnpop total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the species count on the population

xtreg ihs_spec_tot lnpop total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)
