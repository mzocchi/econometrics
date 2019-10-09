*** Mastering 'Metrics
*** Generates Table 3.3
*** Minneapolis Domestic Violence Experiment
*** Created by Jon Petkun (jbpetkun@mit.edu) on Feb 12, 2015

clear all
use MDVE.dta

* Generate action assignments (i.e. what are police assigned to do)
gen z_arrest=(T_RANDOM == 1)

* Generate actual outcomes (i.e. what action do the police actually take)
gen x_arrest=(T_FINAL == 1)

* Drop if actual outcome is "other"
drop if T_FINAL==4
gen total = 1

* Randomly determine outcome (acutal data not provided):
	* non-arrest = 47 with post tx episode of DV (21.1%)
	* arrested = 9 with post tx episode of DV (9.7%)
	set seed 10092019
	gen rand = runiform()
	gen y_postdv = 0
	bysort z_arrest x_arrest: replace y_postdv = 1 if z_arrest==0 & x_arrest==0 & _n<=38
	bysort z_arrest x_arrest: replace y_postdv = 1 if z_arrest==0 & x_arrest==1 & _n<=10
	bysort z_arrest x_arrest: replace y_postdv = 1 if z_arrest==1 & x_arrest==1 & _n<=9

* gen
	gen year = YEAR
	gen race = S_RACE
	replace race = 3 if race>3 & race!=.
	gen weapon = WEAPON
	recode weapon (2 3 = 0) (4/8 = 1)
	gen chem = S_CHEM
	
