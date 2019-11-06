# HS 409A Lab 8: Fixed Effects
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

#### Goal
1. To estimate a fixed effects regression model in Stata

#### Objectives
1. Preliminary analysis for panel data
2. Estimate a fixed effects model

#### Research Question
1. What deterrent factors are associated with lower crime rates?

#### Dataset:
Panel data consisting of crime data rates and other related variables of 90 North Carolina counties from 1981-1987. (N= 630 observations)

| <br>  Variable Name<br>   | <br>  Description<br>                                                                                                                 |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| <br>  lcrmrte  <br>       | <br>  Log of the number of crimes per person (dependent variable)<br>                                                            |
| <br>  d82-d87<br>         | <br>  Dummy variables indicating years 1982-1987<br>                                                                             |
| <br>  lprbarr<br>         | <br>  Log probability of arrest (ratio of arrests to offenses)<br>                                                               |
| <br>  lprbconv<br>        | <br>  Log probability of conviction (ratio of convictions to arrests)<br>                                                        |
| <br>  lprbpris<br>        | <br>  Log probability of serving time given a conviction (proportion of total convictions resulting in prison sentencing) <br>   |
| <br>  lavgsen<br>         | <br>  Log of average sentence (sanction severity)<br>                                                                                 |
| <br>  lpolpc<br>          | <br>  Log of police officers per capita<br>                                                                                           |


#### Objective 1. Preliminary Analysis for Panel Data
```
cd ". . ."
use crime.dta, clear
```

**A.	Estimate an OLS model for model comparison purposes**
Because we have a log DV and log IVs we interpret the coefficients to mean that a 1% increase in probability of arrest lowers the crime rate by 0.72%. The coefficient of police per capita predicts that a 1% increase in police per capita increases the crime rate by about 0.4%.
```
reg lcrmrte d82-d87 lprbarr lprbconv lprbpris lavgsen lpolpc
estimates store ols1
```

One common problem with this regular OLS approach is that we can’t control for things if we can’t measure them (and there are lots of things we can’t measure or don’t have data for!). For example, anything that impacts any of the deterrent factors and crime will bias our estimates (e.g. poverty increases crimes per person and increases probability of conviction and serving time given a conviction). IF we had a measure of poverty by county-year, we could just control for it; however, this could include other things more difficult to measure than poverty, such as the trust a community has with law enforcement, liklihood of witnesses testifying, etc. 

If we can observe each person/firm/county/country multiple times, then we don't need to control for the actual variable(s) of interest (e.g. poverty, trust of law enforcement) and just control for person/firm/county/country identity instead. This will control for EVERYTHING unique to that individual/firm/county, whether we can measure it or not! Essentially we compare the counties *to themselves* at different periods of time.

We are ignoring all differences between counties and looking only at differences *within* counties. Fixed Effects is sometimes also referred to as the “within” estimator.

**B. Set up dataset for panel data analysis in Stata**
Stata includes a set of “xt” commands to summarize and analyze panel and clustered data.  Before any analysis, however, we must indicate that we will be working with a panel/clustered data set by running the xtset command followed by the group ID variable then the time variable. Stata output indicating that the panel is strongly balanced means that there isn’t any missing observation per group.
```
xtset county year
```
Use xtdescribe to verify the set up of the panel data.  Lower case “n” indicates the number of counties, and “T” denotes the number of time observations per county. 
```
xtdescribe
```
**C. Examine how data varies between counties and within counties**
xtsum is similar to summarize. It reports descriptive statistics (mean, SD, min, and max) for the overall dataset, compares the average of each group (i.e. county) in relation to others, and calculates the deviations of each time observation to its group mean. It decomposes the standard deviation into between groups (variation from one county to the next) and within groups (variation within each county over time) components. For example, if the within standard deviation is zero, it indicates that the variable does not vary over time. 
```
xtsum  county year crmrte prbarr prbconv prbpris avgsen polpc
```

#### Objective 2. Estimate a fixed effects model
**A.	Estimate a two-way fixed effects model**
We begin by estimating a two-way fixed effects model.  It is called two-way because we are assuming that there is a 1) group effect (county) and a 2) time effect (over the years) on the dependent variable.  

Fixed effects models remove the *time-invariant* variables that are unobservable from our model (e.g. policing culture of a county). It removes the synergistic effects between the unobservable variables with the other independent variables on the outcome variable, giving us unbiased estimates. For example, if we assume that the unobservable characteristics of each county influence its arrest rates, which in turn affect crime rates, we must account for this association. 
```
xtreg lcrmrte d82 d83 d84 d85 d86 d87 lprbarr lprbconv lprbpris lavgsen lpolpc,fe 
estimates store fe2way
```
Some statistics to consider from the FE Stata output:
- corr(u_i, Xb) = Correlation between ai and the regressors in the fixed effects model
rho = variance not explained by differences across entities. Also known as the intraclass correlation.  This  is how much of the total variance is due to the fixed effects.
- sigma_u = variance associated with the unobserved effect ai
- sigma_e = variance associated with the idiosyncratic error ui

At the bottom of the output you see a line that starts with “F test that all u_i=0”. When all the fixed effects are zero, the fixed effects model collapses to a normal regression, so this test compares the fixed effects model with the OLS model. The null (OLS) is rejected, in favor of FE. Unobserved heterogeneity effect exists.

**B.	OLS regression with dummy variables for each county**
Fixed-effects two-way model in part A did not include a dummy variable for each county.  Through the “de-meaning” transformation for fixed effects estimates, the time-constant unobservable county-level variables were removed.  If we were to include a dummy variable for each county and estimate a pooled OLS model, we would get the same results as the two-way fixed effects model.  In other words, the unobservable characteristics of each county are captured in its dummy variable.
```
reg lcrmrte d82 d83 d84 d85 d86 d87 lprbarr lprbconv lprbpris lavgsen lpolpc i.county
estimates store lsdv
esttab fe2way lsdv,drop(*county) b(%7.2f) star stats(N) se
```

The F test below tests if the county parameters are jointly significant, which is equivalent to the F test provided in the fixed effects model output. Note that both testparm and test commands conduct Wald tests. Testparm is more flexible when we want to conduct an F-test on a list of variables (e.g. dummy variables for counties). Note:  You may need to run the dummy variable regression again before using this command.
```
testparm i.county*
```
Compare the models:
```
esttab ols1 fe2way lsdv,drop(*county) b(%7.2f) star stats(N r2 r2_a)
```
**One-way fixed effects model**
If we run a model without the year dummies, we are only accounting for the group effects.  This means that we assume that there is no time effect on the dependent variable.
```
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, fe
estimates store fe1way
esttab ols1 fe2way fe1way, b(%7.2f) star stats(N r2 r2_a) se
```
To determine if the time effect may be important in the model, we can conduct an F test.  If the F test indicates that the time dummies are jointly significant, we should keep them in the model.
```
xtreg lcrmrte d82-d87 lprbarr lprbconv lprbpris lavgsen lpolpc, fe
test  d82 d83 d84 d85 d86 d87
```
