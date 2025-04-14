use "birds (1).dta", clear

* Preparing data 

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



* Winsorising data 

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
* This part assesses the parallel trends in data 

gen pseudo_shale_year = 2010 if shale_ever_treated == 0
gen align_year_shale = first_shale
replace align_year_shale = pseudo_shale_year if missing(align_year_shale)

gen event_time_shale = year - align_year_shale
gen in_window_shale = event_time_shale >= -10 & event_time_shale <= 10

egen avg_treated_shale = mean(ihs_num_tot) if shale_ever_treated == 1 & in_window_shale == 1, by(event_time_shale)
egen avg_control_shale = mean(ihs_num_tot) if shale_ever_treated == 0 & in_window_shale == 1, by(event_time_shale)

gen source_shale = "Shale" if in_window_shale
gen event_time_shale_plot = event_time_shale if in_window_shale
gen avg_treated_shale_plot = avg_treated_shale if in_window_shale
gen avg_control_shale_plot = avg_control_shale if in_window_shale

preserve
keep if in_window_shale
keep event_time_shale_plot avg_treated_shale_plot avg_control_shale_plot
duplicates drop

twoway (line avg_treated_shale_plot event_time_shale_plot, lcolor(red) lpattern(solid)) (line avg_control_shale_plot event_time_shale_plot, lcolor(red) lpattern(dash)), legend(order(1 "Treated - Shale" 2 "Control - Shale")) xline(0, lcolor(black) lpattern(dot)) xtitle("Years Since Treatment") ytitle("Avg IHS Bird Count") title("Parallel Trends: Shale Wells") xlabel(-10(2)10)

restore



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




* Effect of Turbines on Bird Population (Katovich covariates)

xtreg ihs_spec_tot turbine_did_win1 turbine_did_win2 turbine_did_win3 turbine_did_win4 turbine_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Effect of Turbines on Bird Population (Katovich covariates)

xtreg ihs_num_tot shale_did_win1 shale_did_win2 shale_did_win3 shale_did_win4 shale_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Effect of Turbines on Bird Population (Katovich covariates)

xtreg ihs_spec_tot shale_did_win1 shale_did_win2 shale_did_win3 shale_did_win4 shale_did_win5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



********************************************************************************
* Trying lagged regression with a lag between treatment and effect taking place

gen turbine_did_lag1 = L1.turbine_did
gen turbine_did_lag2 = L2.turbine_did
gen turbine_did_lag3 = L3.turbine_did
gen turbine_did_lag4 = L4.turbine_did
gen turbine_did_lag5 = L5.turbine_did

gen shale_did_lag1 = L1.shale_did
gen shale_did_lag2 = L2.shale_did
gen shale_did_lag3 = L3.shale_did
gen shale_did_lag4 = L4.shale_did
gen shale_did_lag5 = L5.shale_did



* Regression of the bird count on Turbines with lag involved

xtreg ihs_num_tot turbine_did_lag1 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot turbine_did_lag2 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot turbine_did_lag3 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot turbine_did_lag4 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot turbine_did_lag5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the bird count on Shale wells with lag involved

xtreg ihs_num_tot shale_did_lag1 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot shale_did_lag2 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot shale_did_lag3 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot shale_did_lag4 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)

xtreg ihs_num_tot shale_did_lag5 total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)




********************************************************************************
* This part will check if human population acted as a mediator in affecting the bird count



* Regression of the human population on the turbine arrival (bivariate)

xtreg lnpop turbine_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the shale arrival (bivariate)

xtreg lnpop shale_did total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the turbine arrival (continious)

xtreg ihs_num_tot turbine_did_continuous total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the human population on the shale arrival (continious)

xtreg ihs_num_tot shale_did_continuous total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)



* Regression of the bird count on the population

xtreg ihs_num_tot lnpop total_effort_counters Min_temp Max_temp Max_snow Max_wind ag_land_share past_land_share dev_share_broad dev_share_narrow i.year, fe cluster(circle_id)




















