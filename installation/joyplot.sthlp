{smcl}
{* 13May2025}{...}
{hi:help ridgeline/joyplot}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-ridgeline":ridgeline/joyplot v1.91 (GitHub)}}

{hline}

{title:ridgeline}: A Stata module for ridgeline or joyplots. 

This package is derived from the following guide on Medium: {browse "https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d":Ridgeline plots (Joy plots)}.

The command {cmd:ridgeline} is also mirrored as {cmd:joyplot} and these can be used interchangeably.

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:ridgeline} {it:varlist} {ifin}, {cmd:by}({it:variable}) 
                {cmd:[} {cmdab:t:ime}({it:numvar}) {cmd:overlap}({it:num}) {cmdab:bwid:th}({it:num}) {cmd:palette}({it:str}) {cmd:alpha}({it:num}) {cmdab:off:set}({it:num}) {cmd:lines} {cmd:droplow}
                  {cmdab:norm:alize}({it:local}|{it:global}) {cmd:rescale} {cmdab:off:set}({it:num}) {cmdab:laboff:set}({it:num}) {cmdab:labyoff:set}({it:num}) 
                  {cmdab:lw:idth}({it:num}) {cmdab:lc:olor}({it:str}) {cmdab:ylabs:ize}({it:num}) {cmdab:ylabc:olor}({it:str}) {cmdab:labpos:ition}({it:str})
                  {cmdab:yl:ine} {cmdab:ylc:olor}({it:str}) {cmdab:ylw:idth}({it:str}) {cmdab:ylp:attern}({it:str}) {cmdab:xrev:erse} {cmdab:yrev:erse} {cmd:n}({it:num}) {cmdab:mark}({it:options}) {cmd:stats}({it:options}) 
                  {cmdab:legpos:ition}({it:num}) {cmdab:legcol:umns}({it:num}) {cmdab:legs:ize}({it:num}) {cmd:*} {cmd:]}
{p 4 4 2}


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt ridgeline varlist}}The command requires a set of numerical {it:variable(s)} that can be split over {opt by()} variables. 
If the option {opt time()} is specified, the command will draw lowess curves for each {it:varlist} and {opt time()} variable combination.
Otherwise, kernel densities for {it:varlist} are drawn. If more than one variable is specified, then the legends are enabled.
Legends will prioritize variable labels, otherwise variable names will be used. Here, {cmd:joyplot} can be used as a substitute for {cmd:ridgeline}.{p_end}

{p2coldent : {opt t:ime(num var)}}Define a numerical time variable (if required).{p_end}

{p2coldent : {opt by(variable)}}This variable defines the layers that split the data into layers. If there are fewer than 10 observations per {opt by()} group,
the program will throw a warning message. This is important to flag since the program might not be able to generate density functions for very few observations.
Either clean these groups manually or use the {opt droplow} option to automatically drop these groups.{p_end}

{p2coldent : {opt droplow}}Automatically drop the {opt by()} groups with fewer than 10 observations.{p_end}

{p2coldent : {opt bwid:th(num)}}A higher bandwidth value will result in higher smoothing. The default value is {opt bwid(0.1)}.
This value might need adjustment depending on the data. Note that if you use {cmd:ridgeline} and the ridges do not appear, then the bandwidth might need adjustment.
In this case try changing the bandwidth value using option {opt bwid()}.{p_end}

{p2coldent : {opt overlap(num)}}A higher value increases the overlap, and the height of the ridgelines. The default value is {opt overlap(6)} and the minimum allowed value is 1.
A value of {opt overlap(1)} implies that each {opt by()} group is drawn in its own horizontal space without overlaps.{p_end}

{p2coldent : {opt palette(str)}}{opt palette} uses any named scheme defined in the {stata help colorpalette:colorpalette} package.
Default is {stata colorpalette tableau:{it:tableau}}. Here, one can also pass single colors, such as {opt palette(black)}.{p_end}

{p2coldent : {opt alpha(num)}}Transparency of the area fills. Default value is {opt alpha(80)} for 80% transparency.{p_end}

{p2coldent : {opt lines}}Draw colored lines instead of area fills.
The option {opt lcolor()} does not work here. Instead use the {opt palette()} option. Option {opt lwidth()} is permitted.{p_end}

{p2coldent : {opt norm:alize(local|global)}}Normalize by the local or global maximum of the {it:varlist} variable. The default is set to {opt norm(global)}, but in certain circumstances,
users might want to look at the distribution of a variable within the {opt by()} group. In this case use {opt norm(local)}.{p_end}

{p2coldent : {opt rescale}}This option is used to rescale the data such that the global minimum value is set to 0.
This is helpful if the data contains large starting values that can create a large vertical gap from the zero axis. 
While this can be fine in some cases, in others it can squish the variations in the data. 
It can also make the labels look displaced.
Here, {opt rescale} can partially eliminate the gap by recentering the data to the global minimum. 
The minimum and maximum values are stored in locals. See {it:return list}. 
This options can also be used if the data contains negative values as the lowess option
automatically drops negative values which might not make sense in some cases but then this
does not generate a ridgeline plot.{p_end}

{p2coldent : {opt xrev:erse}, {opt yrev:erse}}Reverse the x and y axes. While reversing the y-axis might be desireable, for example, to change the alphabetical 
order of the categories, it is not recommended to use {opt xrev} unless absolutely required.{p_end}


{p 4 4 2}
{it:{ul:Ridgelines}}

{p2coldent : {opt lc:olor(str)}}The outline color of the area fills. Default is {opt lc(white)}.{p_end}

{p2coldent : {opt lw:idth(num)}}The outline width of the area fills. Default is {opt lw(0.15)}.{p_end}


{p 4 4 2}
{it:{ul:Markers and statistics} (beta)}

{p2coldent : {opt mark(statistic [, line sort])}}Defining {opt mark(statistic)} will mark the desired statistic on each ridge. If option {opt time()} is specified, then only {opt mark(max)} is allowed.
Otherwise common options are {opt mark(max)}, {opt mark(mean)}, {opt mark(median)}, etc. or whatever is return from {opt summary}. 
Option {opt mark(max, line)} will show droplines for the desired statistic.
Option {opt mark(max, sort)} will sort the ridges according to the desired statistic. If multiple variables are specified, then sort will be based on the first variable in {it:varlist}.
Option {opt mark(, sort)} can be combined with {opt yrev} to reverse the sorting. Option {opt mark(mean2)} is a special case, that shows both mean and standard deviation if option {opt stats()} is specified.

{p2coldent : {opt stats([options])}}Show the statistics for the option specified in {opt mark()}. These will be text markers above the 
desired statistics. Additionally, the option {opt mark(mean2)} will show {opt stats()} as "(\mu = <mean>, \sigma = <sd>").
The markers can be customized using standard twoway options, e.g. {opt stats(mlabcolor(gs6) mlabsize(1.8) mlabpos(12) mlabgap(0))}.{p_end}


{p 4 4 2}
{it:{ul:Horizontal lines}}

{p2coldent : {opt yl:ine}}Shows base reference lines for each {opt by()} group.{p_end}

{p2coldent : {opt ylc:olor(str)}}The color of the y-axis grids lines. Default is {opt ylc(black)}.{p_end}

{p2coldent : {opt ylw:idth(num)}}The width of the y-axis grids lines. Default is {opt ylw(0.04)}.{p_end}

{p2coldent : {opt ylp:attern(str)}}The pattern of the y-axis grids lines. Default is {opt ylp(solid)}.{p_end}


{p 4 4 2}
{it:{ul:Labels}}

{p2coldent : {opt labalt}}Place the labels on the righthand-side of the axes.{p_end}

{p2coldent : {opt labpos:ition(str)}}The position of the labels. The default is {opt labpos(9)} or {opt labpos(3)} if {opt labalt} is used.{p_end}

{p2coldent : {opt labs:ize(str)}}Label size. Default is {opt labs(1.6)}.{p_end}

{p2coldent : {opt labc:olor(str)}}Label color. Default is {opt labc(black)}.{p_end}

{p2coldent : {opt laboff:set(num)}}Label offset on the x-axis. Positive values move the labels left while negative values move them right.
Default is {opt laboff(0)}.{p_end}

{p2coldent : {opt labyoff:set(num)}}Label offset on the y-axis. Positive values move the labels up while negative values move them down.
Default is {opt laboff(0)}.{p_end}


{p 4 4 2}
{it:{ul:Legend options}}

{p2coldent : {opt legpos:ition(num)}}Clock position of the legend. Default is {opt legpos(6)}.{p_end}

{p2coldent : {opt legcol:umns(num)}}Number of legend columns. Default is {opt legcol(3)}.{p_end}

{p2coldent : {opt legs:ize(num)}}Size of legend entries. Default is {opt legs(2.2)}.{p_end}



{p2coldent : {opt n(num)}}Advanced option for increasing the number of observations for generating ridgeline densities when {opt time()} is not specified. Default is {opt n(100)}.{p_end}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified.{p_end}


{synoptline}
{p2colreset}{...}


{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}


{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-ridgeline":GitHub} for examples.


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459061.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:Feedback and issues}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-ridgeline/issues":GitHub} by creating a new issue.


{title:Package details}

Version      : {bf:ridgeline} v1.91
This release : 13 May 2025
First release: 13 Dec 2021
Repository   : {browse "https://github.com/asjadnaqvi/ridgeline":GitHub}
Keywords     : Stata, graph, ridgeline, joyplot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter/X    : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}
BlueSky      : {browse "https://bsky.app/profile/asjadnaqvi.bsky.social":@asjadnaqvi.bsky.social}


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: An update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb alluvial}, {helpb arcplot}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, 
	{helpb geoboundary}, {helpb geoflow}, {helpb graphfunctions}, {helpb marimekko}, {helpb polarspike}, {helpb ridgeline}, 
	{helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit},
	{helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}.

or visit {browse "https://github.com/asjadnaqvi":GitHub}.
