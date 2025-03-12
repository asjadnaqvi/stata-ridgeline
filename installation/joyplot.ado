*! ridgeline v1.81 (12 Mar 2025)
*! Asjad Naqvi (asjadnaqvi@gmail.com)


* v1.81 (12 Mar 2025): sumstat now add mean and sd statistics (still beta)
* v1.8  (07 Jan 2025): Port to new syntax. multiple variables are now allowed. ylab etc is now just lab. Many improvements to default variables
*                      ylabposition is now labalt. time dimension now need the time() option. Backend data is now stacked resulting in a much faster drawing.
*					   code is now many time faster. peaks renamed to mark()
* v1.71 (03 Oct 2023): Fixed a bug in single density joyplots for incorrect locals. Fixed a bugs in lines. Added n() option.
* v1.7  (14 Jul 2023): xline(), saving(), peaks, peaksize() options added. ridgeline duplicates joyplot.
* v1.62 (28 May 2023): change over() to by() to align it with other packages. added offset() and laboffset()
* v1.61 (01 Mar 2023): ylabel in densities fixed. normalize in densities fixed.
* v1.6  (05 Nov 2022): bug fixes
* v1.5  (03 Sep 2022): bandwidth fixed. xlabel is now passthru. defaults updated.
* v1.42 (22 Jun 2022): y-axis was bugged in the over plot
* v1.41 (20 Jun 2022): installations fix, numerical over fix.
* v1.4  (26 Apr 2022): axes reverse options added. various optimizations
* v1.3  (24 Apr 2022): stacked densities added. label placement optimized. 
* v1.21 (15 Apr 2022): xsize/ysize added. ylabels on right option added.
* v1.2  (13 Apr 2022): xlabel angle, local normalization, lines only option added
* v1.1  (07 Apr 2022): several options added
* v1.0  (13 Dec 2021): first release

**********************************
* Step-by-step guide on Medium   *
**********************************

// This program is based on the following guide:
// COVID-19 visualizations with Stata Part 8: Ridgeline plots (Joy plots) (30 Oct, 2020)
// https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d


cap program drop joyplot


program joyplot, rclass sortpreserve 

version 15
 
	syntax varlist(numeric) [if] [in], by(varname) [ Time(varname numeric) overlap(real 6) BWIDth(real 0.5) palette(string) alpha(real 80) lines	] ///
		[ LColor(string) LWidth(string) 	] ///
		[ YLine YLColor(string) YLPattern(string) YLWidth(real 0.04) YREVerse XREVerse 	] ///
		[ NORMalize(str) rescale droplow  ] ///  // v1.6 options
		[ LABOFFset(real 0) OFFset(real 0)  n(real 100) ]  ///  // v1.62 and v1.7 options
		[ * LABColor(string) LABSize(string) labalt LABAngle(string) LABPOSition(string) LEGPOSition(real 6) LEGCOLumns(real 3) LEGSize(real 2.2) ] ///   			// v1.8
		[ mark(string) peaksize(real 0.2) ]  ///
		[ asis steps showstats ] // todo
	
	/* TODO
	add binning.
	add over() to allow splits varlists.
	add ability to sort by peaks.
	*/
		
		
		
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "The palettes package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	
	capture findfile labmask.ado
	if _rc != 0 {
		qui ssc install labutil, replace
		exit
	}
	
	if `overlap' < 1 {
		display as error "overlap() should be >= 1"
		exit
	}

	// local options

	if "`lcolor'" 	 == "" local lcolor 	white
	if "`lwidth'" 	 == "" local lwidth 	0.15
	if "`ylcolor'"	 == "" local ylcolor  	black	
	if "`ylpattern'" == "" local ylpattern  solid
	if "`xreverse'"  != "" local xreverse 	xscale(reverse)		

	if "`palette'" == "" {
		local palette tableau	
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}	
	
	if "`mark'"!="" {			
		tokenize "`mark'", p(",")
		
		local mark1 `1'
		local mark2 `3'
		
		if "`mark1'" == "median" local mark1 p50

	}
	
	marksample touse, strok
	
quietly {
preserve	
	
	
////////////////////////
// prepare the data  ///
////////////////////////		


	keep if `touse'
	keep `varlist' `by' `time'

	local length : word count `varlist'
	
	// rename v1.8
	
	local i = 1
	foreach x of local varlist  {
		gen raw`i' = `x' 
		
		if "`: var label `x''" != "" {
			local varlab`i' : var label `x'
		}
		else {
			local varlab`i' `x'
		}		

		local ++i
	}
	
	
	//////
	
	gen ones = 1
	bysort `by': egen counts = sum(ones)
	egen tag = tag(`by')
	summ counts, meanonly
	
	if r(min) < 10 {
		if "`droplow'" == "" {	
			count if counts < 10 & tag==1
			di as error "Groups with errors:"
			noi list `by' if counts < 10 & tag==1
			di as error "`r(N)' over group(s) (`by') have fewer than 10 observations. Either clean them manually or use the {it:droplow} option to automatically filter them."
			exit
		}	
		else {
			count
			local obstot = r(N)
			
			count if counts < 10
			local obsdrop = r(N)
			
			drop if counts < 10
			
			local obsdiff = `obstot' - `obsdrop'
			di in yellow "Out of `obstot' observations, `obsdrop' dropped. `obsdiff' observations remaining."
			
		}
	}
	
	count
	if r(N) == 0 {
		di as error "All observations dropped. No {bf:by()} groups fulfill the criteria for {stata help joyplot:joyplot}."
		exit
	}
	
	drop ones tag counts
	
	cap confirm numeric var `by'
		if _rc!=0 {
			encode `by', gen(_by)
			local by _by
		}
		else {
			tempvar tempov 
			egen   _by = group(`by')
			
			if "`: value label `by''" != "" {
				decode `by', gen(`tempov')		
				labmask _by, val(`tempov')
			}
			local by _by
		}
	
	
	if "`yreverse'" != "" {
					
		clonevar over2 = `by'
		
		summ `by', meanonly
		replace `by' = r(max) - `by' + 1
		
		if "`: value label over2'" != "" {
			tempvar group2
			decode over2, gen(`group2')			
			replace `group2' = string(over2) if `group2'==""
			labmask `by', val(`group2')
		}
		else {
			labmask `by', val(over2)
		}
	}	
	

	
////////////////////
// time variable  //
////////////////////	
**# with time


if "`time'" != "" {

	foreach x of local varlist {
		replace `x' = 0 if `x' < 0   // TODO: see how to deal with negative values. v1.6: Suggest rescale option
	}
	
	sort `by' `time' 
	cap drop _fillin
	fillin `by' `time' 

	cap drop _fillin

	// rescale v1.6 added
	if "`rescale'" != "" {
		local i = 1
		
		foreach x of local varlist {
			summ `x', meanonly
			
			local gmin = r(min)
			local gmax = r(max)
			
			return local min`i' `"`gmin'"'
			return local max`i' `"`gmax'"'
		
			replace `x' = `x' - `gmin'
			local ++i
		}
	}
	
	
	// normalization v1.6 fix
	if "`normalize'" == "global" |  "`normalize'" == ""  {
		levelsof `by', local(lvls)
		
		local i = 1
		
		foreach x of local varlist {
			
			gen double norm`i' = .
			
			foreach y of local lvls {
				 summ `x' if !missing(`x'), meanonly
				 replace norm`i' = `x' / r(max) if `by'==`y'   // this needs to be checked
			}
			local ++i	
		}
	}	
	else  {
		levelsof `by', local(lvls)
	
		local i = 1
	
		foreach x of local varlist {
			
			gen double norm`i' = .
			
			foreach y of local lvls {
				 summ `x' if `by'==`y' & !missing(`x') , meanonly
				 replace norm`i' = `x' / r(max) if `by'==`y'
			}
			local ++i	
		}
	}	
	
	
	// y labels 
	gen y0 = 0
	
	egen tag = tag(`by')
	
	// location of x-labels

	gen double xpoint = .
	gen double xstat = .
	
	if "`labalt'" == ""  {
		summ `time', meanonly
		replace xpoint = r(min) + `laboffset' if tag==1
		replace xstat  = r(max) - `laboffset' if tag==1

	}
	else  {	
		summ `time', meanonly
		replace xpoint = r(max) + `laboffset' if tag==1
		replace xstat  = r(min) - `laboffset' if tag==1
	}
	

	gen double ypoint = .
	
	levelsof `by', local(lvls)
	local items = `r(r)'

	forval z = 1/`length' {
	
		gen double ybot`z' = .
		gen double ytop`z' = .
		gen double peakx`z' = .
		gen double peaky`z' = .
		
		gen double _mean`z' = .
		gen double _sd`z' = .	

		foreach x of local lvls {
		
			summ `by', meanonly
			local newx = r(max) + 1 - `x'   
			
			lowess norm`z' `time' if `by'==`newx', bwid(`bwidth') gen(y`z'_`newx') nograph

			replace ybot`z' =  `newx' / `overlap'  	if `by'==`newx'
			replace ytop`z' = y`z'_`newx' + ybot`z'	if `by'==`newx'
			 
**# mark1 time
			
			if "`mark'"!= "" {
				if "`mark1'"!="max" & "`mark1'"!="peak" {

					summ ytop`z' if `by'==`newx', d
					summ ytop`z' if ytop`z' >= r(`mark1') & `by'==`newx', meanonly
					
					replace peaky`z'= ytop`z' if `by'==`newx' & ytop`z'==r(max)
					replace peakx`z'= `time'  if `by'==`newx' & !missing(peaky`z')
				}
				else {
					
					summ ytop`z' if `by'==`newx'
					 
					replace peaky`z' = ytop`z' if ytop`z'==r(max) &  `by'==`newx'
					replace peakx`z' = `time'  if ytop`z'==r(max) &  `by'==`newx'
				}
			}
			
			
			if "`showstats'"!= "" {
				qui summ ytop`z' 				if `by'==`newx'
				replace _mean`z' 	= r(mean) 	if `by'==`newx'
				replace _sd`z' 		= r(sd) 	if `by'==`newx'
			}
		
			drop y`z'_`newx'
		}		
	}
	
	forval z = 1/`length' {
		summ ybot`z' if `by'==1, meanonly
		local shift = r(mean)
		
		replace ybot`z'  = ybot`z'  - `shift'
		replace ytop`z'  = ytop`z'  - `shift'
		replace peaky`z' = peaky`z' - `shift'
	}
}	




///////////////////////
// no time variable  //
///////////////////////	
**# without time

	if "`time'"=="" {

		// counters
		local dmax  = 0
		local xrmin = .
		local xrmax = 0

		foreach x of local varlist {
			summ `x', meanonly
			if `xrmin' < `r(min)'  local xrmin = `r(min)'
			
			summ `x', meanonly
			if `xrmax' < `r(max)'  local xrmax = `r(max)'
		}
		

		levelsof `by', local(lvls) 
		local items = `r(r)'
	
		local i = 1
		
		foreach z of local varlist {
		
			foreach x of local lvls {
			
				summ `by', meanonly
				local newx = r(max) + 1 - `x'   // reverse the sorting

				kdensity `z' if `by'==`x', generate(_x`i'_`x' _y`i'_`x') bwid(`bwidth') n(`n') nograph
				
				summ _y`i'_`x', meanonly
				if r(max) > `dmax' local dmax = r(max)   // global max
			
			
				summ _x`i'_`x', meanonly	
					if r(min) < `xrmin' local xrmin = r(min)
					if r(max) > `xrmax' local xrmax = r(max)
				
				
				gen double _peakx`i'_`x' = .
				gen double _peaky`i'_`x' = .
				

**# mark1 no time
				
				if "`mark'"!= "" {
					if "`mark1'"!="max" & "`mark1'"!="peak" {
						qui summ `z' if `by'==`x', d
						replace _peakx`i'_`x'= r(`mark1') in 1
						replace _peaky`i'_`x' = .
					}
					else {
						summ _y`i'_`x', meanonly
						replace _peaky`i'_`x' = _y`i'_`x' if _y`i'_`x'==r(max)
						replace _peakx`i'_`x' = _x`i'_`x' if _y`i'_`x'==r(max)
					}
				}
				
				gen double _mean`i'`x' = .
				gen double _sd`i'`x' = .				
				
				if "`showstats'"!= "" {
					qui summ `z' if `by'==`x'
					replace _mean`i'`x' = `r(mean)' in 1 
					replace _sd`i'`x' = `r(sd)'	 in 1
				}
				
			}
			
			local rshplist `rshplist' _x`i'_ _y`i'_ _peakx`i'_ _peaky`i'_ _mean`i' _sd`i'
			
			local ++i
		}
		
		// stack	
		

		keep  _y* _x* _peakx* _peaky* _mean* _sd* 
		drop if _y1_1 ==.
		
		
		
		// add dummy line
		
		set obs `= _N + 1'
		
		gen _id = _n
		
		reshape long `rshplist', i(_id) j(_myvar)
		
		local by _myvar
		
		lab val `by' _by
		sort `by' _id
		
		ren _y*_ y*
		ren _x*_ x*
		ren _peakx*_ peakx*
		ren _peaky*_ peaky*
		
		// normalization 
		if "`normalize'" == "" | "`normalize'" == "global"  {
			forval x = 1/`length' {
				 replace y`x' = y`x' / `dmax'
			}
		}	
			
		if "`normalize'" == "local"  {
			forval x = 1/`length' {
				summ y`x', meanonly
				replace y`x' = y`x' / r(max) 
			}
		}

		// y labels 
		gen double xpoint = .
		gen double ypoint = .
		gen double xstat = .
		
		gen y0 = 0
		
		egen tag = tag(_myvar)

		levelsof `by', local(lvls)
		local items = `r(r)'
		
		forval z = 1/`length' {
			
			gen double ybot`z' = .
			gen double ytop`z' = .
			gen double wgt`z' = .
			
			foreach x of local lvls {

				local newx = `i'
				replace ybot`z' =  `x' / `overlap'      if `by'==`x'
				replace ytop`z' = y`z' + ybot`z'		if `by'==`x'
                
				if "`mark'"!="" & ("`mark1'"!="max" | "`mark1'"!="peak") {
					summ peakx`z' if `by'==`x' & !missing(peakx`z'), meanonly
					summ ytop`z'  if x`z' >= r(mean) & `by'==`x', meanonly
					replace peaky`z' = r(max) if `by'==`x' & !missing(peakx`z')
				}
			}
		}
		
		
		summ ybot1, meanonly
		local shift = r(mean)
		
		forval x = 1/`length' {
			replace ybot`x'  = ybot`x' - `shift'
			replace ytop`x'  = ytop`x' - `shift'
			replace peaky`x' = peaky`x' - `shift'
		}
		

		local mymin = 1e20
		local mymax = 0
		
		forval x = 1/`length' {
			
			summ x`x', meanonly
				if `mymin' > `r(min)' local mymin = `r(min)'			
		
			summ x`x', meanonly
				if `mymax' < `r(max)' local mymax = `r(max)'
		}
			

		if "`labalt'" == ""  {
			replace xpoint = `mymin' + `laboffset' if tag==1
			replace xstat  = `mymax' - `laboffset' if tag==1
		}
		else  {	
			replace xpoint = `mymax' + `laboffset' if tag==1	
			replace xstat  = `mymin' - `laboffset' if tag==1
		}	
		
	}	// end if block
	
	
	
///////////////
// Compile  ///
///////////////


	if `length'==1 {
		
		levelsof `by', local(lvls)
		local items = `r(r)'	

		foreach x of local lvls {

			summ `by', meanonly
			local newx = r(max) + 1 - `x'   
		
			forval z = 1/`length' {
		
				if "`lines'" != "" {
					
					colorpalette `palette', n(`items') nograph `poptions'
					local mygraph `mygraph' line ytop`z' `time' if `by'==`newx', lc("`r(p`newx')'") lw(`lwidth') || 
					
				}
				else {
					
					if "`time'"!= "" {
						
						colorpalette `palette', n(`items') nograph `poptions'
						local mygraph `mygraph' rarea  ytop`z' ybot`z' `time' if `by'==`newx', fc("`r(p`newx')'%`alpha'") fi(100) lw(none) ||  line ytop`z' `time' if `by'==`newx', lc(`lcolor') lw(`lwidth') ||
					
					}
					else {
											
						colorpalette `palette', n(`items') nograph `poptions'
						local mygraph `mygraph' rarea  ytop`z' ybot`z' x`z' if `by'==`newx', fc("`r(p`newx')'%`alpha'") fi(100) lw(none) ||  line ytop`z' x`z' if `by'==`newx', lc(`lcolor') lw(`lwidth') ||
						
					}				
				}	
			}
		}
	} 
	else {  // if more than one item

		levelsof `by', local(lvls)

		local items = `length'
		
		foreach x of local lvls {
		
			summ `by', meanonly
			local newx = r(max) + 1 - `x'   
			
			forval z = 1/`length' {

				if "`lines'" != "" {
					
					colorpalette `palette', n(`items') nograph `poptions'
					local mygraph `mygraph' line ytop`z' `time' if `by'==`newx', lc("`r(p`z')'") lw(`lwidth') || 
					
				}
				else {
					
					if "`time'"!= "" {
	
						colorpalette `palette', n(`items') nograph `poptions'
						local mygraph `mygraph' rarea  ytop`z' ybot`z' `time' if `by'==`newx', fc("`r(p`z')'%`alpha'") fi(100) lw(none) ||  line ytop`z' `time' if `by'==`newx', lc(`lcolor') lw(`lwidth') ||
					
					}
					else {
											
						colorpalette `palette', n(`items') nograph `poptions'
						local mygraph `mygraph' rarea  ytop`z' ybot`z' x`z' if `by'==`newx', fc("`r(p`z')'%`alpha'") fi(100) lw(none) ||  line ytop`z' x`z' if `by'==`newx', lc(`lcolor') lw(`lwidth') ||
						
					}				
				}										
			}
		}
	}		
	
	
	// yline entries

	local byitems = 0
	
	if "`yline'" != "" {			
		local byitems = 1
		
		gen double yli0 = ybot1 if tag==1
		gen double yli1 = ybot1 if tag==1


		if "`time'"!= "" {		
			summ `time', meanonly
			
			gen double xli0 = r(min) if tag==1
			gen double xli1 = r(max) if tag==1				
		}
		else {
			
			local mymin = .
			local mymax = 0
			
			forval i = 1/`length' {
			
				summ x`i', meanonly
				
				if r(min) < `mymin' local mymin = r(min)
				if r(max) > `mymax' local mymax = r(max)
			
			}
			
			gen double xli0 = `mymin' if tag==1
			gen double xli1 = `mymax' if tag==1			
		}
		
		local ylines `ylines' (pcspike yli0 xli0 yli1 xli1, lp(`ylpattern') lc(`ylcolor') lw(`ylwidth')) 
	}			
		
		
	// get the ypoint in order
	
	replace ypoint = ( ybot1) if tag==1	
		
	// legend entries	
	if `length' > 1 {
		forval z = 1/`length' {
				local j = `byitems' + `z' + (`z' - 1)   
				local entries `" `entries' `j'  "`varlab`z''"  "'
		}
			
		local mylegend legend(order("`entries'") pos(`legposition') size(`legsize') col(`legcolumns')) 
	}	
	else {
		local mylegend legend(off)
	}
	

	if "`mark'"!= "" {	
		
		if `length'==1 {
			
			levelsof `by', local(lvls)
			local items = `r(r)'	
			
			forval z = 1/`items' {
				if "`mark2'"!="line" {
					colorpalette `palette', n(`items') nograph `poptions'
					local mypeaks `mypeaks' (scatter peaky1 peakx1 if !missing(peakx1) & `by'==`z' , msym(circle) msize(`peaksize') mcolor("`r(p`z')'")) 
				}
				else {
					colorpalette `palette', n(`items') nograph `poptions'
					local mypeaks `mypeaks' (pcspike peaky1 peakx1 ybot1 peakx1 if !missing(peakx1) & `by'==`z', lcolor("`r(p`z')'") lw(0.3)) 
				}
			}		
		}
		else {
			
			local items = `length'
			
			forval z = 1/`length' {
				if "`mark2'"!="line" {		
					colorpalette `palette', n(`items') nograph `poptions'
					
					local mypeaks `mypeaks' (scatter peaky`z' peakx`z' if !missing(peakx`z') , msym(circle) msize(`peaksize') mcolor("`r(p`z')'")) 
				}
				else {
					colorpalette `palette', n(`items') nograph `poptions'
					local mypeaks `mypeaks' (pcspike peaky`z' peakx`z' ybot`z' peakx`z' if !missing(peakx`z') , lcolor("`r(p`z')'") lw(0.3)) 
				}
			}				
		}
	}
	
	
	
	if "`labcolor'" == ""  local labcolor 	black	
	if "`labsize'"  == ""  local labsize 	2
	
	
	if "`labalt'" == ""  {
		summ `time', meanonly
		local x1 = r(min) - ((r(max) - r(min)) * (`offset' / 100)) + `laboffset'
		local x2 = r(max)
		
		if "`labposition'"=="" local labposition 10
		
		local mylabels (scatter ypoint xpoint if tag==1, mcolor(none) mlabcolor(`labcolor') mlabel(`by') mlabsize(`labsize') mlabposition(`labposition') ) 
		
	}
	else {
		summ `time', meanonly
		local x1 = r(min) 
		local x2 = r(max) + ((r(max) - r(min)) * (`offset' / 100))  + `laboffset'
	
		if "`labposition'"=="" local labposition 2
		
		local mylabels (scatter ypoint xpoint if tag==1, mcolor(none) mlabcolor(`labcolor') mlabel(`by') mlabsize(`labsize') mlabposition(`labposition') ) 
			
	}
	
	
	if "`showstats'" != "" {
		
		generate _sumstat = "({&mu}=" + string(_mean1, "%7.2f") + " , {&sigma}=" + string(_sd1, "%7.2f") + ")"
		
		local statsize = `labsize' * 0.75
		
		local mystats (scatter ypoint xstat if tag==1, mcolor(none) mlabcolor(`labcolor') mlabel(_sumstat) mlabsize(`statsize') mlabposition(11) ) 		
	}
	

	// draw 
	
	twoway 				///
		`ylines'		///
		`mygraph'		///
		`mypeaks'		///
		`mylabels'  	///
		`mystats'		///
		, 				///
			`xreverse' 	///
			ylabel(, nolabels noticks nogrid) yscale(noline) ///
				`mylegend' `options'
				
				
	*/
restore			
}

end



*********************************
******** END OF PROGRAM *********
*********************************



