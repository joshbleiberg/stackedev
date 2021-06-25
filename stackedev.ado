********************************************************************************
/*!version 0.0  24jun2021  Joshua Bleiberg, joshua_bleiberg@brown.edu
Note: Requires reghdfe
*/
capture program drop stackedev
program define stackedev, eclass

version 13

syntax varlist(min=2 numeric) [if] [in] [pweight aweight fweight], ///
	cohort(varname numeric) ///
	time(varname numeric) ///
	never_treat(varname numeric) ///
	unit_fe(varname numeric) ///
	clust_unit(varname numeric) ///
	[COVARiates(varlist numeric ts fv) ///
	other_fe(varlist numeric ts fv) ///
	interact_cov(string)]
	
********************************************************************************
//Checking for never treated units
qui sum `never_treat'
local max_var=r(max)
if `max_var'!=1{
di "Error: Stacked event study requires never treated comparison units. The never treated option (never_treat) should be a binary variable equal to 1 comparison units that do not receive treatment and 0 for units that do receive treatment."
exit
}
********************************************************************************
//Creating stacks for each treated cohort of units
qui levelsof `cohort'
	local t_val=r(levels)
foreach i of local t_val{
preserve
di "**** Building Stack `i' ****"

qui gen stack_keep=0
qui replace stack_keep=1 if `cohort' ==`i'
qui replace stack_keep=1 if `never_treat'==1
qui keep if stack_keep==1
qui drop stack_keep
qui gen stack=`i'
qui tempfile stack`i'
qui save "`stack`i''"
restore
}
********************************************************************************
//Appending together each stack
qui sum `cohort'
local stackmin=r(min)

qui levelsof `cohort' if `cohort'!=`stackmin'
	local t_val2=r(levels)
	
qui use "`stack`stackmin''", clear

qui tempfile all_stacks
qui save `all_stacks', emptyok

di "**** Appending Stacks ****"
foreach j of local t_val2{
    qui append using "`stack`j''"
    qui save `"`all_stacks'"', replace
}
********************************************************************************
//Creating variable to estimate unit by stack variances
qui gen unit_stack=stack*`clust_unit'
local clust_var unit_stack
********************************************************************************
//Allowing covariates to be interacted with stack
if "`interact_cov'"=="Yes"{
foreach i of local covariates{
qui replace `i'=`i'*stack
}
}
********************************************************************************
//Estimating model with reghdfe
di "**** Estimating Model with reghdfe ****"
reghdfe `varlist' `covariates', absorb(i.`unit_fe'##i.stack i.`time'##i.stack `other_fe') cluster(`clust_var')

qui drop stack unit_stack
end

	
