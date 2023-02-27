/******************************************************************************/
// Replication code for "Converge or Catchup?"
// Let's Talk Development Blog
// February 2023
// Aart Kraay
// Do file requires PennWorldTables10.0, available at:
// https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt100?lang=en
/******************************************************************************/

/******************************************************************************/
// Preliminaries
/******************************************************************************/
clear
set more off
graph drop _all

/******************************************************************************/
// Load data
/******************************************************************************/
// Use this option if your firewall lets you point directly to the dataset on the 
// Groningen Growth and Development Center Website
//use "https://www.rug.nl/ggdc/docs/pwt100.dta"

// Otherwise, download the dataset using the URL above, and adjust your filepath 
// appropriately in the line below
use "C:\Users\wb74439\OneDrive - WBG\Kraay\DATA\PennWorldTables\PWT10\pwt100.dta"

// tsset the data
egen numcode=group(countrycode)
tsset numcode year
sort numcode year

// GDP Per Capita
// log real GDP per capita at PPP
gen lny=ln(rgdpe/pop)
// level of real GDP per capita
gen y=rgdpe/pop

/******************************************************************************/
// Construct balanced panel of countries starting starting in 1960
/******************************************************************************/
// Balanced panel of GDP per capita since 1960
egen zzz=count(y), by(countrycode)
gen ybal=y if zzz>=60 & year>=1960
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
twoway (line mldbal year, yaxis(1) lwidth(thick)) (line avyrusabal year, yaxis(2) lwidth(thick)) if countrycode=="USA" & year>=1960, ///
		xtitle("Year") ytitle("", axis(1)) ytitle("", axis(2)) ///
		title("Figure 1: Convergence and Catch-up") ///
		legend(label(1 "Convergence: Mean Log Deviation of GDP Per Capita (Left Axis)") label(2 "Catch-up: Average GDP Per Capita Relative to USA (Right Axis)") rows(2)) ///
		note("Note: Per capita GDP is measured in constant 2017 USD at PPP.  Balanced panel of 111 countries." "Source: Penn World Tables v.10") xline(1980) xline(2000) 		

/******************************************************************************/
// Generate Figure 2 showing beta-convergence regressions for three 20-year 
// sub-samples, 1960-79, 1980-99, 2000-19. First produce graph for each period
// followed by "graph combine" to generate combined figure 
/******************************************************************************/
gen gr6079=(F19.lnybal-lnybal)/19 if year==1960
twoway (scatter gr6079 lnybal) (lfit gr6079 lnybal, lwidth(thick))  if year==1960, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("1960-1979") name(conv6079fig)

gen gr8099=(F19.lnybal-lnybal)/19 if year==1980
twoway (scatter gr8099 lnybal if countrycode~="NGA" & countrycode~="COD") (lfit gr8099 lnybal, lwidth(thick))  if year==1980, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("1980-1999") name(conv8099fig) 

gen gr0019=(F19.lnybal-lnybal)/19 if year==2000
twoway (scatter gr0019 lnybal if countrycode~="VEN") (lfit gr0019 lnybal, lwidth(thick))  if year==2000, ///
	legend(off) ytitle("Average Annual Growth") xtitle("Log Initial GDP Per Capita") title("2000-2019") name(conv0019fig)

graph combine conv6079fig conv8099fig conv0019fig, ///
	rows(1) cols(3) ysize(3) xsize(6) xcommon ycommon title("Figure 2: Growth and Initial Income") ///
	note("Notes: Very low growth rates are suppressed from graph for Nigeria and DRC (1980-99) and Venezuela (2000-2019) " "Source:  Penn World Tables Version 10.0")

/******************************************************************************/
// Table 1 in blog:  average growth rates by sub-period 
/******************************************************************************/
su gr6079 if year==1960
su gr6079 if year==1960 & countrycode=="USA"

su gr8099 if year==1980
su gr8099 if year==1980 & countrycode=="USA"

su gr0019 if year==2000
su gr0019 if year==2000 & countrycode=="USA"

/******************************************************************************/
// End of code
/******************************************************************************/