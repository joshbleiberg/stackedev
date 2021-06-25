# stackedev

**stackedev**     Implements the stacked event study estimator discussed in Cunningham (2021) and Baker (2021) and implemented in Cengiz et al. (2010). The package appends together individual datasets or stacks. Each stack includes all observations from a cohort of units that receive treatment in the same time period and all units that never received treatment. Effects are identified within each stack by comparing an individual cohort of treated units to never treated units. That approach avoids erroneous comparisons of late to early implementing units that may bias Two-Way Fixed Effects (TWFE) estimates if effects vary across treated cohorts (Goodman-Bacon, 2021). The stacked event study is estimated in three steps. First, individual stacks are created. Second, they are appended together. Finally the package estimates an event study via reghdfe that includes unit by stack fixed effects, time by stack fixed effects, and standard errors clustering on unit by stack.

## Installation
**stackedev** can be installed easily via the `github` package, which is available at [https://github.com/haghish/github](https://github.com/haghish/github).  Specifically execute the following code in Stata:

`net install github, from("https://haghish.github.io/github/")`

To install the **stackedev** package , execute the following in Stata:

`github install joshbleiberg/stackedev'

See the help_file.txt for support for how to implement the command and an illustrative example. A .sthlp is currently not available. 

## Authors
Joshua Bleiberg
