# HS 409A Lab 6: Regression Discontinuity
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

#### Goal:
Apply OLS estimation for regression-discontinuity research design 

#### Objectives:
1.	Identify treatment cutoff and create a treatment variable for regression-discontinuity design
2.	Analyze data using various bandwidths

#### Research Question:
1. Does legal access to alcohol increase mortality in young adults (ages 19-23)?

Ho: Legal access to alcohol has no effect on mortality in young adults.

#### Dataset: 
Aggregated mortality data by age (in year-months) for adults between ages 19-23.

> Background regarding dataset (from Mastering Metrics, Chapter 4):  
> Americans over the age of 21 can drink legally. Of course, those under age drink as well. Some have advocated returning the minimum legal drinking age (MLDA) to 18 will discourage binge drinking and promote a culture of mature alcohol consumption. This contrasts with the traditional view that the age-21 MLDA, while a blunt and imperfect tool, reduces youth access to alcohol, thereby preventing some harm.  
>
> Research has shown that mortality risks shoots up on and immediately following a 21st birthday (and considerably more so than on 20th and 22nd birthdays). It remains to be seen, however, whether the age-21 effect can be attributed to the MLDA, and whether the increased risk persists long after a person's 21st birthday.

#### Objective I: Identify treatment cutoff & create treatment variable

* Regression discontinuity is a research design that can address endogeneity issues.  Endogeneity occurs when an explanatory variable is correlated with the error term, a situation that may result from omitted variables, measurement error, or model misspecification.  For example, when we investigate the effect of treatment, we want to make sure that our estimate is not overestimated due to unobserved factors that are highly associated with the treatment.  

* Regression discontinuity can address endogeneity when treatment assignment is achieved by using some cutoff indicator (e.g. providing enrichment program to students who score below 50% on a test). Such assignment affords us the opportunity to look at drastic changes (a.k.a. discontinuities) in the outcome variable between individuals with the treatment and those without the treatment around the cutoff point.  So, even if the treatment may be associated with other factors that we cannot account for, we know that these factors do not change/jump at the cutoff. 

#### Preliminary Analysis:
* Particularly for regression discontinuity design, descriptive analysis should include examination of the distribution of treatment ("cutoff") variable.

* First, we are going to generate a few variables to use for our analyses:
```
gen age = agecell - 21
gen over21 = agecell >= 21
gen age2 = age^2
gen over_age = over21*age
gen over_age2 = over21*age2
```

* Next, we will run a couple of simple OLS regression to generate a predicted values for mortality. (Note: the variable All is the "all cause" mortality rate per 100,000).
```
reg all age over21
eststo simple
predict allfitlin  
```
* Looking at the first model (without the interaction term), we see that mortality declines with age (although, not significant in this dataset). In the second model (with an interaction term) we see that mortality increases with age from 19-21, jumps up quite a lot at 21, but then decreases with age after 21.
* Let's plot the results from the first model using the observed and predicted values
``` 
twoway  (scatter all agecell) ///
		(line allfitlin agecell if age < 0, lcolor(black) lwidth(medthick)) ///
        (line allfitlin agecell if age >= 0, lcolor(black red) lwidth(medthick medthick)) ///
		, xline(21, lcolor(black) lpattern(dash)) legend(off) ylabel(80(5)115, angle(horiz))
```
* In *sharp* RD designs, treatment switches cleanly off or on as the the running variable (e.g. age) passes a cutoff. The MLDA is a sharp function of age, so investigation of MLDA effects on mortality is a sharp RD study.

* We know that mortality changes with age for reasons unrelated to the MLDA (e.g. cancer, homicide, suicide, motor vehicle crashes, etc.). Is it safe to assume that there are no other effects on mortality other than the MLDA at age 21?

**Limitations**
* For our estimate to be accurate, we assumed that mortality is a linear function of age. If age and mortality is a nonlinear function but we model it as a linear function, we may perceive a jump in the data that is not actually there. 
* Let's try putting a quadratic function of age into the model (age and age-squared).
* We can also allow for a different slope coefficient to the left and right of the cutoff by adding in an interaction term.
```
esto: reg all age age2 over21 over_age over_age2  
eststo fancy
predict allfitqi
```

* Now, let's compare the two models.
```
esttab simple fancy
```
* The fancy quadratic model generate a larger estimate of the MLDA effect at the cutoff than does the simple linear model, equal to about 9.5 deaths per 100,000 ()





   
