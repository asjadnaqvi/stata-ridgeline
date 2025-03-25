![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-joyplot) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-joyplot) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-joyplot) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-joyplot) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-joyplot)


[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

![banner_ridgeline](https://github.com/user-attachments/assets/dececcfc-d194-40ce-9770-60c442efd20d)





# ridgeline v1.9
(24 Mar 2025)

This package provides the ability to draw ridgeline or joyplots in Stata. It is based on the [Ridgeline Guide](https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d) that I wrote in October 2020.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The package (**v1.81**) is available on SSC and can be installed as follows:
```
ssc install ridgeline, replace
```

Or it can be installed from GitHub (**v1.9**):

```
net install ridgeline, from("https://raw.githubusercontent.com/asjadnaqvi/stata-ridgeline/main/installation/") replace
```

The following dependencies are required:

```
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace
ssc install labutil, replace
```

Even if you have the package installed, make sure that it is updated `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
ridgeline varlist [if] [in], by(variable) 
                [ time(numvar) overlap(num) bwidth(num) palette(str) alpha(num) offset(num) lines droplow normalize(local | global) 
                  rescale offset(num) laboffset(num) lwidth(num) lcolor(str) ylabsize(num) ylabcolor(str) ylabposition(str)
                  yline ylcolor(str) ylwidth(str) ylpattern(str) xreverse yreverse n(num) mark(options) stats(options) 
                  legposition(num) legcolumns(num) legsize(num) * ]

```

See the help file `help ridgeline` for details.

The most basic use is as follows:

```stata
ridgeline varlist, by(variable) time(variable)
```

or

```stata
ridgeline varlist, by(variable)
```


## Examples

Set up the data:

```stata
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-ridgeline/blob/main/data/OWID_data.dta?raw=true", clear

drop if date < 22460
keep if group10==1
cap drop _m
format date %tdDD-Mon-yy
```


## With time variable

We can generate basic graphs as follows:

```stata
ridgeline new_cases, by(country) time(date)
```

<img src="/figures/joyplot1.png" width="100%">


```stata
ridgeline new_cases, by(country) t(date) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_0.png" width="100%">


```stata
ridgeline new_cases, by(country) t(date) yline bwid(0.1) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_1.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) alpha(100) bwid(0.1) norm(local) palette(CET C7) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_2.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) lc(black) palette(white) alpha(100) bwid(0.1) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_3.png" width="100%">


```stata
ridgeline new_cases, by(country) t(date) lc(white) palette(black) alpha(50) lw(0.05) bwid(0.1) norm(local)  plotregion(margin(l+10))
```

<img src="/figures/joyplot1_4.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) lines lw(0.2) bwid(0.1) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_5.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) lines lw(0.2) palette(black) bwid(0.1) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_6.png" width="100%">


```stata
ridgeline new_cases, by(country) t(date) lines lw(0.2) bwid(0.1) labalt norm(local) offset(8) plotregion(margin(r+10))
```

<img src="/figures/joyplot1_7.png" width="100%">


```stata
ridgeline new_cases, by(country) t(date) lw(0.2) bwid(0.1) labalt xsize(2) ysize(1) norm(local)yline offset(10) ///
	plotregion(margin(r+10)) xlabel(#10, format(%tdDD-Mon-yy) angle(90))
```

<img src="/figures/joyplot1_8.png" width="100%">


Reverse the y-axis

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) yrev norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot1_9.png" width="100%">


Here we reverse both axes, but it is highly advisable not to do so with the x-axis:

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) yrev xrev norm(local) yline labpos(2)
```

<img src="/figures/joyplot1_10.png" width="100%">


### Normalization

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot2.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) overlap(15) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot2_1.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) overlap(12) lines norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot2_2.png" width="100%">

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) off(-20) overlap(10) lw(none) norm(local) plotregion(margin(l+10))
```

<img src="/figures/joyplot3.png" width="100%">


We can customize some more:

```stata
summ date, meanonly

local xmin = r(min)
local xmax = r(max)


ridgeline new_cases, by(country) t(date) overlap(8) bwid(0.1) palette(CET C1) alpha(100) ///
	lc(white) lw(0.2) xlabel(`xmin'(120)`xmax', labsize(2)) off(-30) norm(local) ///
	xtitle("Date") plotregion(margin(l+10)) ///
	title("{fontface Arial Bold:My ridgeline plot}") subtitle("Some text here")  ///
	note("Some text here", size(vsmall)) 
```

<img src="/figures/joyplot4.png" width="100%">


Next we modify the scheme and make sure the colors are passed correctly. We use `neon` from [schemepack](https://github.com/asjadnaqvi/Stata-schemes) which has a black background:

```stata
summ date, meanonly

local xmin = r(min)
local xmax = r(max)
	
ridgeline new_cases, by(country) t(date) overlap(8) bwid(0.1) palette(CET C1) alpha(90) ///
	lc(black) lw(0.1) xlabel(`xmin'(120)`xmax') off(-30)  norm(local) labc(white) /// 
	xtitle("Date")  plotregion(margin(l+10)) ///
	title("{fontface Arial Bold:My ridgeline plot}") subtitle("subtitle", color(white)) ///
	note("Some text here", size(vsmall)) scheme(neon)
```

<img src="/figures/joyplot5.png" width="100%">


### The Joy Division look, since this plots get their name from the band:

```stata
summ date if date > 22425, meanonly

local xmin = r(min)
local xmax = r(max)
	
ridgeline new_cases if date > 22425, by(country) t(date) overlap(10) bwid(0.1) palette(black) alpha(100) norm(local)  ///
	lc(white) lw(0.2) xlabel(none) laboff(40) labc(none)   /// 
	xtitle("") ytitle("") ///
	title("{fontface Arial Bold:The Joy Division look}") scheme(neon)
```

<img src="/figures/joyplot6.png" width="100%">


### v1.7 options

Peaks can be added to the ridges using the `mark(max)` option, and reference lines can be added using the `xline()` option:

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) off(-20) overlap(3) mark(max, line) norm(local)  ///
	palette(CET C6) plotregion(margin(l+10)) alpha(40)
```

<img src="/figures/joyplot6_1.png" width="100%">

Sort:

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) overlap(3) mark(max, line sort) norm(local) format(%tdDD-Mon-yy)  ///
	palette(CET C6) plotregion(margin(l+10)) alpha(40)
```

<img src="/figures/joyplot6_1_1.png" width="100%">


Add summary statistics to the figure:

```stata
ridgeline new_cases, by(country) t(date) bwid(0.1) overlap(3) mark(max, line sort) norm(local) stats format(%tdDD-Mon-yy)  ///
	palette(CET C6) plotregion(margin(l+10)) alpha(40)
```

<img src="/figures/joyplot6_1_2.png" width="100%">

### v1.8 multiple variables

```stata
ridgeline new_cases_per_million hosp_patients_per_million, by(country) t(date) alpha(50) bwid(0.1) rescale norm(local) overlap(1)  
```

<img src="/figures/joyplot6_2.png" width="100%">

```stata
gen year = year(date)
drop if year >= 2023

lab var new_cases_per_million "New cases per million"
lab var hosp_patients_per_million "Hospital patients per million"


summ date, meanonly

local xmin = r(min)
local xmax = r(max)


ridgeline new_cases_per_million hosp_patients_per_million, by(country) t(date) alpha(30) bwid(0.1) rescale norm(local) overlap(1) mark(max, line) ///
	xlabel(`xmin'(120)`xmax', format(%tdDD-Mon-yy) angle(90) labsize(2) nogrid)  plotregion(margin(l+8))
```

<img src="/figures/joyplot6_3.png" width="100%">




```stata
ridgeline new_cases_per_million hosp_patients_per_million, by(country) t(date) alpha(30) bwid(0.1) rescale norm(local) overlap(1) ///
	xlabel(, format(%tdDD-Mon-yy) angle(90) labsize(2) nogrid)  plotregion(margin(l+8)) ///
	mark(max, line sort ) ///
	stats(mlabcolor(gs6) mlabsize(1.2) mlabpos(12) mlabgap(0)) format(%tdDD-Mon-yy)
```

<img src="/figures/joyplot6_4.png" width="100%">




## Without time variable

Load the data that contains average USA state-level monthly temperatures for the period 1991-2020:

```stata
use us_meantemp.dta, clear

lab de month 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec", replace
lab val month month
```

```stata
ridgeline meantemp, by(month)  
```

<img src="/figures/ridgeline7_0.png" width="100%">


```stata
ridgeline meantemp, by(month) yline bwid(1.2)
```

<img src="/figures/joyplot7_1.png" width="100%">

```stata
ridgeline meantemp, by(month) yline yrev bwid(1.2)
```

<img src="/figures/joyplot7_2.png" width="100%">

```stata
ridgeline meantemp, by(month)  yline ylw(0.2) ylc(blue) ylp(dot) labpos(right) bwid(1.2) laboffset(-3)
```

<img src="/figures/joyplot7_3.png" width="100%">

```stata
ridgeline meantemp, by(month) bwid(1.5) labs(3) overlap(3) yline yrev palette(CET C6) ///
	xlabel(-20(10)30) ///
	xtitle("degrees Centigrade") ///
	title("Mean average temperature in the USA") subtitle("2009-2020 average") ///
	note("Source: World Bank Climate Change Knowledge Portal (CCKP).", size(vsmall)) ///
		xsize(4) ysize(5)
```

<img src="/figures/joyplot7_4.png" width="100%">

```stata
qui summ meantemp 

local xmin = r(min)
local xmax = r(max)

ridgeline meantemp, by(month) bwid(1.5) labs(3) overlap(3) yline palette(scico corkO) alpha(100) ///
	xtitle("degrees Centigrade") xlabel(`xmin'(5)`xmax') ///
	title("Mean average temperature in the USA") subtitle("2009-2020 average") ///
	note("Source: World Bank Climate Change Knowledge Portal (CCKP).", size(vsmall)) ///
		xsize(3) ysize(5)
```

<img src="/figures/joyplot7_5.png" width="100%">


### v1.7 options

```stata
ridgeline meantemp, by(month) bwid(1.5) labs(3) overlap(3) lc(black) yline yrev palette(CET C6) alpha(20) ///
	xlabel(-20(10)30, nogrid) xtitle("degrees Centigrade") ///
	title("Mean average temperature in the USA") subtitle("2009-2020 average") ///
	note("Source: World Bank Climate Change Knowledge Portal (CCKP).", size(vsmall)) ///
		xsize(4) ysize(5) xline(0, lp(solid) lw(0.1) lc(gs12)) mark(max, line)
```

<img src="/figures/joyplot7_6.png" width="100%">

### v1.9 options

Add summary statistics

```stata
ridgeline meantemp, by(month) bwid(1.5) labs(3) overlap(1) lc(black) yline yrev palette(CET D13) alpha(30) ///
	xlabel(-20(10)30, nogrid) xtitle("degrees Centigrade") ///
		xsize(4) ysize(5) mark(mean, line) ///
		xline(0, lp(solid) lw(0.1) lc(gs12)) stats
```

<img src="/figures/joyplot7_7.png" width="100%">


```stata
ridgeline meantemp, by(month) bwid(1.5) labs(3) overlap(1) lc(black) yline yrev palette(CET D13) alpha(30) ///
	xlabel(-20(10)30, nogrid) xtitle("degrees Centigrade") ///
		xsize(4) ysize(5) mark(max, line) ///
		xline(0, lp(solid) lw(0.1) lc(gs12)) stats
```

<img src="/figures/joyplot7_7_max.png" width="100%">



```stata
ridgeline meantemp, by(month) bwid(1.3) labs(3) overlap(1) yline alpha(30) palette(CET D13) ///
	xlabel(-20(5)30) xtitle("degrees Centigrade") ///
		xsize(4) ysize(5) ///
		xline(0, lp(solid) lw(0.1) lc(gs12)) ///
		mark(mean2, line sort) ///
		stats(mlabcolor(gs6) mlabsize(1.8) mlabpos(12) mlabgap(0))
```


<img src="/figures/joyplot8_7.png" width="100%">



### v1.8 additions

```stata
sysuse citytemp.dta, clear

ridgeline tempjan, by(region) 
```

<img src="/figures/joyplot8_1.png" width="100%">


```stata
ridgeline tempjan, by(region) bwid(1.5) overlap(2) yline
```

<img src="/figures/joyplot8_2.png" width="100%">

```stata
ridgeline tempjan tempjuly, by(region) bwid(1.5) overlap(2) yline
```

<img src="/figures/joyplot8_3.png" width="100%">

```stata
ridgeline tempjan tempjuly, by(region) bwid(1.3) overlap(2) yline mark(max) alpha(50)
```

<img src="/figures/joyplot8_4.png" width="100%">

```stata
ridgeline tempjan tempjuly, by(region) bwid(1.3) overlap(2) yline mark(max, line) alpha(50)
```

<img src="/figures/joyplot8_5.png" width="100%">

```stata
ridgeline tempjan tempjuly, by(region) bwid(1.3) overlap(1) yline mark(max, line) alpha(50)
```

<img src="/figures/joyplot8_6.png" width="100%">


Try another dataset:


```stata
sysuse bpwide.dta, clear

ridgeline bp_before bp_after, by(sex) overlap(1) yline bwid(5) mark(peak, line) alpha(20) palette(okabe)
```

<img src="/figures/joyplot9.png" width="100%">

```
ridgeline bp_before bp_after, by(sex) overlap(1) yline bwid(5) ///
	mark(max, line sort) alpha(20) ///
	stats(mlabcolor(gs6) mlabsize(1.8) mlabpos(12) mlabgap(0))
```

<img src="/figures/joyplot9_1.png" width="100%">

### Rescale and error checks (v1.6)

Load a dummy data set

```stata
use "https://github.com/asjadnaqvi/stata-ridgeline/blob/main/data/rescale_test.dta?raw=true", clear

drop if inlist(country, "Cambodia", "Myanmar", "Lao PDR")
tab country
```

Do a vanilla ridgeline:

```stata
ridgeline socMob, by(country) time(year)  ///
	lc(white) lw(0.2) xlabel(1990(5)2020) plotregion(margin(l+8))
```

<img src="/figures/joyplot_rescale_0.png" width="100%">

Get rid of the overlaps. Here `overlap(1)` gives each country it's own box:

```stata
ridgeline socMob, by(country) time(year)  overlap(1) rescale  ///
	lc(white) lw(0.2) xlabel(1990(5)2020) plotregion(margin(l+8))
```

<img src="/figures/joyplot_rescale_1.png" width="100%">

Let's make a country unusable:

```stata
drop if year < 2015 & country=="Vietnam"	

ridgeline socMob, by(country) time(year)  overlap(1)     ///
	lc(white) lw(0.2)  off(-2) xlabel(1990(5)2020) plotregion(margin(l+8))
```


The above code will produce an error message, highlighting where the error(s) exist. Let's throw these out using the `droplow` option:

```stata
ridgeline socMob, by(country) time(year)  overlap(1) droplow   ///
	lc(white) lw(0.2)  off(-2) xlabel(1990(5)2020) plotregion(margin(l+8))
```

<img src="/figures/joyplot_rescale_3.png" width="100%">

And we rescale the data further to the minimum and maximum values:

```stata
ridgeline socMob, by(country) time(year) overlap(1) droplow rescale   ///
	lc(white) lw(0.2)  off(-2) xlabel(1990(5)2020) plotregion(margin(l+8))
```

<img src="/figures/joyplot_rescale_4.png" width="100%">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-ridgeline/issues) to report errors, feature enhancements, and/or other requests. 


## Change log

**v1.9 (24 Mar 2025)**
- Option `showstats()` is now just `stats()`.
- Complete rework of `mark()` and `stats()` for better control and display.
- If `time()` is specified, then only `mark(max)` is allowed. This is because time series data does not have a mean on the vertical axis but on the horizontal axis.
- Special option `mark(mean2)` will display summary statistics as "(\mu = mean, \sigma = standard deviation)".
- Option `stats()` now allows all mark customization options for better fine tuning.
- Option `mark(<statistic>, sort)` added. If multiple variables are specified in `varlist`, then the first variable will be used for sorting. This option was highly requested. 
- Several code fixes.

**v1.81 (12 Mar 2025)**
- Command is fully ported to `ridgeline` as the primary name. Option `joyplot` is still available.
- Added option `showstats` to show mean and sd on the opposite side of the y-axis labels (requested by Kit Baum). This option is still beta and currenly only shows the summary statistics of the first variable in `varlist`.
- Various code optimizations.

**v1.8 (07 Jan 2025)**
- Rewrite of base routines to make the code much faster.
- Users can now specify a variable list rather than just one variable (requested by Yann de Mey). If more than one variable is specified, then the legend is enabled and colors are defined by the variables rather than `by()` groups. New legend options added `legcolumns()`, `legsize()`, `legposition()`. 
- Time option now requires specifying `time()` option.
- All `ylab...()` options are now just `lab...()`.
- Option `peak` has been removed. Instead a new option `mark()` has been added, where `mark(max)` will mark the peaks. Additional options will be added soon. Users can now also display a dropline by specifying the `mark(max, line)` option which looks better than markers. These options are still beta and further enhancements will be added soon including customizing markers and lines.
- `laboffset()` now works correctly.
- `offset()` that extended the margins has been removed. Instead use the default `plotregion(margin(xxxx))` option to extend the margins.
- Default scheme is now tableau in line with other packages.
- Labels are now right aligned on the left axis, and left aligned on the right axis.
- Several bug fixes, minor enhancements, and improvements to defaults. 


**v1.71 (03 Oct 2023)**
- Fixed a bug where locals were passing incorrectly (reported by osnofas).
- Fixed a bug for the `lines` option in single density joyplots (reported by osnofas).
- Added the `n()` option to evalute densities using a higher number of points  (requested by osnofas).
- Improved the error messages in the help file to better reflect the issues.

**v1.7 (14 Jul 2023)**
- `peaks` and `peaksize()` option added to mark highest point on ridges and modify their size. This option is currently beta.
- `xline()` option added to allow users to plot reference lines on the x-axis (requested by Glenn Harrison).
- `saving()` option added (requested by Glenn Harrison). 
- `joyplot` is now fully mirrored by the `ridgeline` command. Several users requested this.
- Several bug fixes and better arrangement of the helpfile.

**v1.62 (28 May 2023)**
- Changed `over()` to `by()` to align it with other similar packages: `streamplot`, `bumpline`, `bumparea`.
- Added `laboffset()` to displace labels in pixels.
- Added `offset()` to extend the x-axis.
- Minor fixes to code, help file, and updates to defaults.

**v1.61 (01 Mar 2023)**
- Fixed a bug where y-labels were reversed.
- Fixed a bug where `norm()` was not passing correctly to densities.

**v1.6 (05 Nov 2022)**
- `color` renamed to `palette` to align it with the other packages
- Errors checks now halt the program if `over` groups have fewer than 10 observations. This is to prevent density functions from crashing with low data points.
- New option `norm(global)` or `norm(local)` allows users to draw lines normalized to global or local group-wise maximum values.
- New option `droplow` drops the groups that do not need the above observation criteria.
- New option `rescale` rescales the data to start from 0. This allows users to rebase values that start at very high or negative values.

**v1.5 (03 Sep 2022)**
- Code clean up.
- Default values updated.
- Error checks added.

**v1.42 (22 Jun 2022)**
- Values were wrongly assigned on the y-axis if the over variable was numeric (reported by Barry Burden).
- Fixes to "over" variable. It can now take on numeric, string, and labeled numeric values.

**v1.41 (20 Jun 2022)**
- Fix to labmask installation
- over now takes numerical values

**v1.4 (26 Apr 2022)**
- option to reverse x and y axes added
- option save graph names added
- optimization to x-axis scales
- various bug fixes

**v1.3 (24 Apr 2022)**
- option to add y-axis lines.
- the syntax is now allows for variable level densities.
- label placement optimized.

**v1.21 (15 Apr 2022)**
- y label position option added. It can now be position on the left or right.
- xsize and ysize options added to change the graph dimensions.

**v1.2 (14 Apr 2022)**
- x-axis angle option added.
- Global normalization option added.
- Draw lines only option added.
- Major fixes to syntax, defaults values, and how lines and areas are drawn.

**v1.1 (08 Apr 2022)**
- Public release. Several options and features added.

**v1.0 (13 Dec 2021)**
- Beta version.





