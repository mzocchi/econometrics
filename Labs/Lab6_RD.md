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
gen ext_oth = external - homicide - suicide - mva
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

**Non-linear model**
* For our estimate to be accurate, we assumed that mortality is a linear function of age. If age and mortality is a nonlinear function but we model it as a linear function, we may perceive a jump in the data that is not actually there. 
* Let's try putting a polynomial function of age into the model (age, age-squared, over_age, and over_age21).
* A polynomial function is just like the quadratic function we've seen before, but this time we allow the curve to change it's shape before and after the cutoff.
```
reg all age age2 over21 over_age over_age2  
eststo fancy
predict allfitqi
```

* Now, let's compare the two models.
```
esttab simple fancy, se
```
* The "fancy" polynomial model generate a larger estimate of the MLDA effect at the cutoff than does the simple linear model, equal to about 9.5 deaths per 100,000 (SE=1.99).
* Now let's look at the graph of these results
```
twoway  (scatter all agecell) ///
		(line allfitlin allfitqi agecell if age < 0,  lcolor(red black) lwidth(med medthick) lpattern(dash)) ///
        (line allfitlin allfitqi agecell if age >= 0, lcolor(red black) lwidth(med medthick) lpattern(dash)) ///
		, xline(21, lcolor(black) lpattern(dash)) legend(off) ylabel(80(5)115, angle(horiz))
```
* The fancy model seems to fit the data better than the linear model: Death rates jump sharply at age 21, but then recover somewhat quickly in the first few months.

* Both the fancy and simple model show a large jump at the cutoff. However, what is interesting is that the effect seem to sustain at least though to age 23. The jump in death rates at the cutoff shows that drinking behavior responds to alcohol access, but the treatment effect to age 23 is still visible.

**Robustness Checks**
* How do we know that the jump in mortality at the cutoff is due to drinking specifically? A skeptic might point out that we do not have individual-level data about drinking habits and we are just assuming that people drink more from 21-23 than from 19-21. 

* We do have data on mortality rates from specific causes of death, which might help us make our case. Alcohol-related diseases (e.g. cirrhosis of the liver) are normally found in much older adults, but motor vehicle accidents (MVA) are plausibly closely tied to alcohol-related deaths in young adults. If true, we should see a large jump in MVA mortality and little jump in internal causes of death (e.g. cancer). We might also expect that external causes of death (suicide, homicide, unintentional injuries) would also be sensitive to alcohol consumption. 

* The following Stata code will generate the "simple" and "fancy" models for MVA and internal causes of death.

```
* "Motor Vehicle Accidents" on linear, and quadratic on each side
reg mva age over21
eststo mva_simple
predict exfitlin

reg mva age age2 over21 over_age over_age2
eststo mva_fancy
predict exfitqi

* "Internal causes" on linear, and quadratic on each side
reg internal age over21
eststo internal_simple
predict infitlin

reg internal age age2 over21 over_age over_age2
eststo internal_fancy
predict infitqi

label variable mva  "Mortality rate (per 100,000)"
label variable infitqi  "Mortality rate (per 100,000)"
label variable exfitqi  "Mortality rate (per 100,000)"
```

* First we examine the results visually:

<p style="text-align: center;">Figure 3. <br> RD Estimates of MLDA effects on mortality by cause of death</p>  

```
twoway (scatter  mva internal agecell) ///
		(line exfitqi infitqi agecell if agecell < 21) ///
        (line exfitqi infitqi agecell if agecell >= 21), ///
		text(28 20.1 "Motor Vehicle Fatalities") text(17 22 "Deaths from Internal Causes") ///
		xline(21, lcolor(black) lpattern(dash)) legend(off) ylabel(10(5)40, angle(horiz))
```
* Now, let's look at the results from the regression:
```
esttab mva_simple internal_simple mva_fancy internal_fancy, b(2) se(2)
```
* The figure and regression results should help convince the skeptic. We see a clear jump in mortality at the MLDA cutoff for MVA, with no evidence of a non-linear trend. We also do not see much of a change in mortality from internal causes at the cutoff - the jump is insignificant.

**Bandwidths**
* The smaller the bandwidth, the less a concern of a nonlinear trend. However, a smaller bandwidth will reduce the sample size we have to work with and less data means less precision in our estimates. There are statistical methods to choose an optimal bandwidth, but most importantly you want to make sure that your choice of bandwidth does not change your findings substantially. 

* Let's go back to the simple all-cause model but this time restrict the age range to 20-22:
```
reg all age over21 if agecell>=20 & agecell<=22
eststo simple2021
predict allfitlin2021
```
```
twoway	(scatter all agecell) ///
				(line allfitlin2021 agecell if age <0, lcolor(black) lwidth(medthick)) ///
				(line allfitlin2021 agecell if age >=0, lcolor(black red) lwidth(medthick medthick)) ///
				 if agecell>=20 & agecell<=22 ///
				 , xline(21, lcolor(black) lpattern(dash)) legend(off) ylabel(80(5)115, angle(horiz))
```
```
esttab simple simple2021 fancy, b(2) se(2)
```
* The results from the restricted bandwidth are still significant and are closer to the "fancy" model estimates.

**Extra**
* We can run code to get the estimates on all the causes of death we have. The foreach command runs a loop for each variable specified. We use the outreg2 command to export the results to a plain text file.   
You may need to install outreg2 first: ``` ssc install outreg2 ```
```
// Simple Model:
foreach x in all mva suicide homicide ext_oth internal alcohol {
reg `x' age over21, robust
if ("`x'"=="all"){
	outreg2 over21 using "table_simple.txt", replace bdec(2) sdec(2) keep(over21) nocons
}
else{
	outreg2 over21 using "table_simple.txt", append  bdec(2) sdec(2) keep(over21) nocons
}
// Fancy Model:
}
foreach x in all mva suicide homicide ext_oth internal alcohol {
reg `x' age over21, robust
if ("`x'"=="all"){
	outreg2 over21 using "table_fancy.txt", replace bdec(2) sdec(2) keep(over21) nocons
}
else{
	outreg2 over21 using "table_fancy.txt", append  bdec(2) sdec(2) keep(over21) nocons
}
}
```  


   
