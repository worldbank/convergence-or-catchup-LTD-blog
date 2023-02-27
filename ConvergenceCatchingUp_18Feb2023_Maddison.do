/******************************************************************************/
// Replication code for "Converge or Catchup?"
// This version does the same calculations as in the blog, but uses the Maddison dataset
// This gives more countries (145 1950-2018) than the PWT (111 1960-2019)
// Overall results are similar.  Only substantial difference is that the first
// period 1950-1979 features no convergence and modest catchup.  This is consistent
// with a flat growth incidence curve during this period and slightly higher growth
// in rest of world relative to the USA
// Let's Talk Development Blog
// February 2023
// Aart Kraay
// Do file requires Maddison Project data mpd2020.dta, available at:
// https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2020?lang=en
/******************************************************************************/

/******************************************************************************/
// Preliminaries
/******************************************************************************/
clear
set more off
graph drop _all
use "C:\Users\wb74439\OneDrive - WBG\Kraay\DATA\Maddison\mpd2020.dta"

// tsset the data
egen numcode=group(countrycode)
tsset numcode year
sort numcode year

// GDP Per Capita
// log real GDP per capita at PPP
gen lny=ln(gdppc)
// level of real GDP per capita
gen y=gdppc

/******************************************************************************/
// Construct balanced panel of countries starting starting in 1950
/******************************************************************************/
drop if year<1950
egen zzz=count(y), by(countrycode)
gen ybal=y if zzz>=69 & year>=1950
drop zzz


/******************************************************************************/
// Measure of "Convergence"
// Standard deviation of log GDP per capita and Mean Log Deviation over time
// in the balanced sample 
/******************************************************************************/
gen lnybal=log(ybal)					// log GDP per capita 
egen sdlnybal=sd(lnybal), by(year)		// standard deviation of log GDP per capita
egen muybal=mean(ybal), by(year)		// mean of GDP per capita
gen lnyrmubal=ln(muybal/ybal)			// log of mean GDP per capita relative to GDP per capita in each country
egen mldbal=mean(lnyrmubal), by(year)	// mean log deviation

// Quick graph to confirm that patterns look the same if we consider the mean log deviation instead of just standard deviation of log y
// Not shown in blog, supports claim in footnote 1 of blog that two measures show the same pattern
// twoway (line sdlnybal year, yaxis(1)) (line mldbal year, yaxis(2)) if countrycode=="USA" & year>=1960

/******************************************************************************/
// Consider average of income relative to the US to measure 
/******************************************************************************/
// Per capita GDP of USA
gen xx=y if countrycode=="USA"
egen yusa=mean(xx), by(year)
drop xx
gen yrusabal=ybal/yusa
egen avyrusabal=mean(yrusabal), by(year)

/******************************************************************************/
// Figure 1 in blog
/******************************************************************************/
twoway (line mldbal year, yaxis(1) lwidth(thick)) (line avyrusabal year, yaxis(2) lwidth(thick)) if countrycode=="USA" & year>=1950, ///
		xtitle("Year") ytitle("", axis(1)) ytitle("", axis(2)) ///
		title("Figure 1: Convergence and Catch-up") ///
		legend(label(1 "Convergence: Mean Log Deviation of GDP Per Capita (Left Axis)") label(2 "Catch-up: Average GDP Per Capita Relative to USA (Right Axis)") rows(2)) ///
		note("Note: Per capita GDP is measured in constant 2011 USD at PPP.  Balanced panel of 111 countries." "Source: Maddison Project Database 2020") xline(1980) xline(2000) 		


/******************************************************************************/
// Generate Figure 2 showing beta-convergence regressions for three 20-year 
// sub-samples, 1950-79, 1980-99, 2000-18. First produce graph for each period
// followed by "graph combine" to generate combined figure 
/******************************************************************************/
gen gr5079=(F29.lnybal-lnybal)/29 if year==1950
twoway (scatter gr5079 lnybal) (lfit gr5079 lnybal, lwidth(thick))  if year==1950, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("1950-1979") name(conv5079fig)

gen gr8099=(F19.lnybal-lnybal)/19 if year==1980
twoway (scatter gr8099 lnybal if countrycode~="NGA" & countrycode~="COD") (lfit gr8099 lnybal, lwidth(thick))  if year==1980, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("1980-1999") name(conv8099fig) 

gen gr0018=(F18.lnybal-lnybal)/18 if year==2000
twoway (scatter gr0018 lnybal if countrycode~="VEN") (lfit gr0018 lnybal, lwidth(thick))  if year==2000, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("2000-2019") name(conv0018fig)

graph combine conv5079fig conv8099fig conv0018fig, ///
	rows(1) cols(3) ysize(3) xsize(6) xcommon ycommon title("Figure 2: Growth and Initial Income") ///
	note("Notes: Very low growth rates are suppressed from graph for Nigeria and DRC (1980-99) and Venezuela (2000-2018) " "Source:  Maddison Project Database 2020")

/******************************************************************************/
// Table 1 in blog:  average growth rates by sub-period 
/******************************************************************************/
su gr5079 if year==1950
su gr5079 if year==1950 & countrycode=="USA"

su gr8099 if year==1980
su gr8099 if year==1980 & countrycode=="USA"

su gr0018 if year==2000
su gr0018 if year==2000 & countrycode=="USA"

/******************************************************************************/
// End of code
/******************************************************************************/