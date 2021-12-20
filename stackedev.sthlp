{smcl}
{* *! version 1.1 18dec2021}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "stacked##syntax"}{...}
{viewerjumpto "Description" "stacked##description"}{...}
{viewerjumpto "Options" "stacked##options"}{...}
{viewerjumpto "Examples" "stacked##examples"}{...}
{viewerjumpto "Author" "stacked##author"}{...}
{viewerjumpto "Acknowledgements" "stacked##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi: stackedev} {hline 2}}
implements the stacked event study estimator discussed in Cunningham (2021) and Baker (2021) and implemented in Cengiz et al. (2010). The package appends together individual datasets or stacks. Each stack includes all observations from a cohort of units that receive treatment in the same time period and all units that never received treatment. Effects are identified within each stack by comparing an individual cohort of treated units to never treated units. That approach avoids erroneous comparisons of late to early implementing units that may bias Two-Way Fixed Effects (TWFE) estimates if effects vary across treated cohorts (Goodman-Bacon, 2021). The stacked event study is estimated in three steps. First, individual stacks are created. Second, they are appended together. Finally the package estimates an event study via reghdfe that includes unit by stack fixed effects, time by stack fixed effects, and standard errors clustering on unit by stack.
{p_end}
{p2colreset}{...}

{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd: stackedev}
{outcome} {leads_lags_list} {ifin} {weight} {cmd:,} {opth absorb:(reghdfe##absvar:absvars)} {opth cohort:(stackedev##cohort:variable)}
            {opth control_cohort:(stackedev##cohort:variable)} 
 [{it:options} {opth covariates:(stackedev##cohort:varlist)}]
 
{pstd}
where {it:leads_lags_list}} is the list of relative time indicators as you would have included in the canonical two-way fixed effects regression, for example:
{p_end} 
		[{it:post2}] [{it:post3}] [{it:post2}] [{it:post0}] [{it:post1}] [{it:post3}] [...]] 


{pstd}
Users should shape their dataset to a long format where each observation is at the unit-time level. See {help stackedev##examples:illustration} for an example of specifying the syntax. The syntax is similar to {helpb reghdfe} in specifying fixed effects (with {help reghdfe##opt_absorb:absorb}) 
and the type of standard error reported (with {help reghdfe##opt_vce:vcetype}). Results stored in e(b), e(V), and e(dof_table).

{pstd}
{opt stackedev} requires {helpb avar} (Baum and Schaffer, 2013), {helpb fools} (Correia, 2017), {helpb reghdfe} (Correia, 2017) to be installed.
Installation of {opt stackedev} will install {helpb avar}, {helpb ftools}, {helpb reghdfe} (and its dependencies) from ssc if necessary.
Installation of {opt eventstudyinteract} will install {helpb avar} and {helpb reghdfe} (and its dependencies) from ssc if necessary.

{synopthdr :Options}
{synoptline}
{syntab :Must Specify}
{synoptset 22 tabbed}{...}
{synopt :{opth cohort(varname)}}A categorical variable equal to the time that the unit first received treatment. It must be missing for never treated units. {p_end}
{synopt :{opth time(varname)}}A numerical variable equal to time. {p_end}
{synopt :{opth never_treat(varname)}}A binary indicator that equals one if a unit never received treatment and zero if it did. {p_end}
{synopt :{opth unit_fe(varname)}}A variable indicating unit fixed effects. {p_end}
{synopt :{opth clust_unit(varname)}}A variable indicating the unit by which to cluster variances. {p_end}
{p2colreset}{...}

{syntab : Optional}
{synoptset 22 tabbed}{...}
{synopt :{opth covariates(varlist)}}A variable list of covariates. {p_end}
{synopt :{opth other_fe(varlist)}}A additional fixed effects added to reghdfe's absorb option. {p_end}
{synopt :{opth interact_cov(string)}}A indicate yes to interact covariates with stack. {p_end}
{p2colreset}{...}
{synoptline}

{title:Example}
{pstd}
Read in simulated state policy dataset.{p_end}
{pstd}
    . use https://github.com/joshbleiberg/stacked_event/raw/main/state_policy_effect.dta, clear{p_end}

{pstd}
Assigning treatment to states staggered across time. It must be missing for never treated units.{p_end}
    . gen treat_year=.
    . replace treat_year=2006 if inrange(state,13,20)
    . replace treat_year=2007 if inrange(state,21,25)
    . replace treat_year=2008 if inrange(state,26,40)
    . replace treat_year=2009 if inrange(state,40,50)
    . label variable treat_year "Cohort"

{pstd}
Creating ever treated indicator{p_end}
    . gen ever=0
    . replace ever=1 if inrange(state,13,50) 
    . label variable ever "Ever Treated"

{pstd}
Creating never treated indicator that equals one if a unit never received treatment and zero if it did.{p_end}
    . gen no_treat=ever
    . recode no_treat (0=1) (1=0)
    . label variable no_treat "Never Treated"

{pstd}
Creating leads and lags{p_end}
    . gen rel=(year-treat_year)+1
    . replace rel=0 if ever==0
    . tab rel, gen(rel_)
    . label variable rel "Relative Time"

    . rename rel_1 pre8
    . rename rel_2 pre7
    . rename rel_3 pre6
    . rename rel_4 pre5
    . rename rel_5 pre4
    . rename rel_6 pre3
    . rename rel_7 pre2
    . rename rel_8 ref
    . rename rel_9 post1
    . rename rel_10 post2
    . rename rel_11 post3
    . rename rel_12 post4
    . rename rel_13 post5

    . label variable pre8 "Pre 8"
    . label variable pre7 "Pre 7"
    . label variable pre6 "Pre 6"
    . label variable pre5 "Pre 5"
    . label variable pre4 "Pre 4"
    . label variable pre3 "Pre 3"
    . label variable pre2 "Pre 2"
    . label variable ref "Base Year"
    . label variable post1 "Post 1"
    . label variable post2 "Post 2"
    . label variable post3 "Post 3"
    . label variable post4 "Post 4"
    . label variable post5 "Post 5"

{pstd}
Run the stacked event study{p_end}
{pstd}
    . stackedev outcome pre8 pre7 pre6 pre5 pre4 pre3 pre2 post0 post1 post2 post3 post4 ref, cohort(treat_year) time(year) never_treat(no_treat) unit_fe(state) clust_unit(state) covariates(cov)
{p_end}


{title: Acknowledgements}
{pstd}
    Thanks to Liyang Sun author of eventstudyinteract, which served as a reference point for the code herein. Thanks also to Edward Jones who help patch a few bugs.
{p_end}

{title: References}
{pstd}
    Baker, A., Larcker, D. F., & Wang, C. C. (2021). How Much Should We Trust Staggered Difference-In-Differences Estimates?. Available at SSRN 3794018.
{p_end}

{pstd}
    Cengiz, D., Dube, A., Lindner, A., & Zipperer, B. (2019). The effect of minimum wages on low-wage jobs. The Quarterly Journal of Economics, 134(3), 1405-1454.
{p_end}

{pstd}
    Correia, S. 2017.  REGHDFE: Stata module for linear and instrumental-variable/gmm regression absorbing multiple levels of fixed effects.  Statistical Software Components s457874, Boston College Department of Economics.  https://ideas.repec.org/c/boc/bocode/s457874.html
{p_end}

{pstd}
    Cunningham, S. (2021). Causal inference: The mixtape. Yale University Press. https://mixtape.scunning.com/
{p_end}

{pstd}
    Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing. Journal of Econometrics.
{p_end}

{pstd}
    Sun, L., 2021.  eventstudyinteract: interaction weighted estimator for event study.  https://github.com/lsun20/eventstudyinteract.
{p_end}

{title: Author}
{pstd}
    Joshua Bleiberg{p_end}
{pstd}
    joshua_bleiberg@brown.edu{p_end}
