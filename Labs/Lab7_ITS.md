# HS 409A Lab 7: Interrupted Time Series (ITS) Analysis
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

* This lab uses Stata code and tutorial from the the paper: *Interrupted time series regression for the evaluation of public health  interventions: a tutorial* (J. Lopez Bernal, S. Cummins, A. Gasparrini; IJE 2016. Available at: https://academic.oup.com/ije/article/46/1/348/2622842).

#### Goal
1. Learn the requirements for an ITS design and how to use ITS to estimate the impact of an intervention.

#### Objectives
1. Review the requirements for an ITS design
2. Hypothesize how the intervention may impact the outcome
3. Descriptive analysis
4. Regression analysis
5. Addressing methodological issues 

#### Research Question
1. Did the 2005 indoor public smoking ban reduce hospital admissions for acute coronary events (ACE)?

>**Background:**  
The example dataset used in this lab is taken from a
study by Barone-Adesi et al. on the effects of the Italian
smoking ban in public places on hospital admissions
for acute coronary events (ACEs, ICD10 410-411). In
January 2005, Italy introduced regulations to ban smoking
in all indoor public places, with the aim of limiting
the adverse health effects of second-hand smoke. The
subset used here are ACEs in the Sicily region between
2002 and 2006 among those aged 0-69 years. Further details on the dataset can be found in the original publication by Barone-Adesi et al. 2011.16

**Objective 1: Requirements for an ITS**
* Is there a clear break point for the pre- and post-intervention periods?
  * In Italy, the indoor smoking ban started in January 2005.
* What is the outcome?
  * ITS works best with short-term outcomes that are expected to change either relatively quickly after an intervention is implemented or after a clearly defined lag.
  * ACEs are a short-term outcome with a rapid onset after being exposed to smoke and disappear quickly when the exposure is removed.
* Data Requirements
  * ITS requires sequential measures of the outcome before and after the intervention. Studies with few time points or with small expected effect sizes should be interpreted with caution.
  * Pre-intervention data should be visualized to make sure that the historical (pre-intervention) trend is consistent over the pre-intervention time period.
  * The example dataset has **59 months** of routine hospital
admissions data with **600-1100** ACEs at each time point.
The **large number of time points** and **minimal variability** within the data provides enough power to detect relatively small changes in the hospital admission rate.

**Objective 2: Hypothesizing how the intervention impacts the outcome**
* If the intervention was effective, would it cause: 1) a gradual change in the *slope* of the trend; 2) a change in the *level*; or 3) both?
* Will the change follow the intervention immediately or will there be a lag period before any effect is seen?
* Barone-Adesi et al. assumed a **level change** in ACEs
occurring with **no lag**. This assumption was based on
existing evidence suggesting that the acute cardiovascular
risks from passive smoking disappear within a short time.

**Objective 3: descriptive analysis**  
* Examining the data is an important first step. Looking at the pre-intervention trend can give an indication of how stable the trend is over time, whether a linear model is likely to be appropriate and whether there appears to be a seasonal trend


```
cd " . . . "
import delimited "sicily.csv"
```
* This dataset includes the following variables:   
Variable | Description  
year    
month  
time |  elapsed time since the start of the study  
aces |  count of acute coronary episodes in Sicily per month (the outcome)  
smokban |  smoking ban (the intervention) coded 0 before the intervention and 1 after  
pop |  the population of Sicily (in 10000s)  
stdpop |  age standardised population  

* Here we convert the counts into a rate and examine a scatter plot of the pre-intervention data
```
gen rate = aces/stdpop*10^5  
twoway (scatter rate time) if smokban==0, ///
  title("Sicily, 2002-2006") ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year)
```

* It is also useful to produce summary statistics for before and after the intervention
```
summ, detail
bysort smokban: summ aces
bysort smokban: summ rate
```

#### Objective 4: regression analysis  

* A minimum of three variables are required for an ITS
analysis:  
i. T: the time elapsed since the start of the study in with
the unit representing the frequency with which observations
are taken (e.g. month or year);  
ii. Xt : a dummy variable indicating the pre-intervention
period (coded 0) or the post-intervention period (coded 1);  
iii. Yt : the outcome at time t.

* In standard ITS analyses, the following segmented regression
model is used:  

- Yt =  B0 +B1T + B2Xt + B3TXt  
B0 = baseline level at T=0  
B1 = change in the outcome associated with a one-unit increase in time in T=0 (pre-intervention trend)  
B2 = the level change following the intervention  
B3 = indicates the slope change following the intervention
(using the interaction between time and intervention:
TXt ).

**Poisson regression model**  
* In step 2, we chose a level change model and we also use a Poisson model as we are using count data
* In order to do this we model the count data directly (rather than the rate which doesn't follow a Poisson distribution)
* We then use the population (log transformed) as an offset variable in order to transform back to rates

```
* log transform the standardised population:
gen logstdpop = log(stdpop)
glm aces smokban time, family(poisson) link(log) offset(logstdpop) eform

* We generate predicted values based on the model in order to create a plot of the model:
predict pred, nooffset
```
* This can then be plotted along with a scatter graph:

```
gen rate1 = aces/stdpop /*to put rate in same scale as count in model */

twoway (scatter rate1 time) (line pred time, lcolor(red)) , title("Sicily, 2002-2006") ///
ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year) ///
xline(36.5)
```

* Generate the counterfactual by removing the effect of the intervention (_b[smokban]) for the post-intervention period
```
gen pred1 = pred/exp(_b[smokban]) if smokban==1
```
* Add the counterfactual to the plot
```
twoway (scatter rate1 time) (line pred time, lcolor(red)) (line pred1 time, lcolor(red) lpattern(dash)), title("Sicily, 2002-2006") ///
ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year) ///
xline(36.5)
```

#### Objective 5: addressing methodological issues

There are a number of distinctive issues with time series data that may need to be addressed in order to improve the robustness of the analysis.

**Seasonality**

* Seasonality can cause two problems: first, if there is an uneven distribution of months before and after the intervention, such as a higher proportion of winter months, this could bias the results, especially in the analysis of short series. 
* Second, outcomes in one month tend to be more similar to those in neighbouring months within the same time of year, leading to *autocorrelation* and *over-dispersion*.

* (a) Allowing for overdispersion
  * In the model above we have not allowed for overdispersion - in order to do this we can add
the scale(x2) parameter to the model which allows the variance to be proportional rather than 
equal to the mean.
```
glm aces smokban time, family(poisson) link(log) offset(logstdpop) scale(x2) eform
```

* (b) Model checking and autocorrelation
  * Check the residuals by plotting against time
```
predict res, r
twoway (scatter res time)(lowess res time),yline(0)
```

* Further check for autocorrelation by examining the autocorrelation and partial autocorrelation functions
```
tsset time
ac res
pac res, yw
```

* (c) Adjust for seasonality

/* installation of the "circular" package. o find packages select Help > SJ and User-written Programs, 
and click on search */

* we need to create a degrees variable for time divided by the number of time points in a year (i.e. 12 for months)
```
gen degrees=(time/12)*360
```
* we then select the number of sine/cosine pairs to include:
```
fourier degrees, n(2)
```

* these can then be included in the model
```
glm aces smokban cos* sin* time, family(poisson) link(log) offset(logstdpop) scale(x2) eform
```

* we can again check for autocorrelation
```
predict res2, r
twoway (scatter res2 time)(lowess res2 time),yline(0)
tsset time
ac res2
pac res2, yw
```

* predict and plot of seasonally adjusted model**
```
predict pred2, nooffset
twoway (scatter rate1 time) (line pred2 time, lcolor(red)), title("Sicily, 2002-2006") ///
ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year) ///
xline(36.5)
```

* it is sometimes difficult to clearly see the change graphically in the seasonally adjusted model
therefore it can be useful to plot a straight line as if all months were the average to produce a
'deseasonalised' trend.
```
egen avg_cos_1 = mean(cos_1)
egen avg_sin_1 = mean(sin_1)
egen avg_cos_2 = mean(cos_2)
egen avg_sin_2 = mean(sin_2)
//
drop cos* sin*
//
rename avg_cos_1 cos_1
rename avg_sin_1 sin_1
rename avg_cos_2 cos_2
rename avg_sin_2 sin_2
```

* this can then be added to the plot as a dashed line 
```
predict pred3, nooffset
twoway (scatter rate1 time) (line pred2 time, lcolor(red)) (line pred3 time, lcolor(red) lpattern(dash)), title("Sicily, 2002-2006") ///
ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year) ///
xline(36.5)
```
#### additional material
* add a change in slope

* generate interaction term between intervention and time centered at the time of intervention
```
gen inter_smokbantime = smokban*(time-36)
```

* restore fourier variables that were previously changed
```
drop cos* sin* degrees
gen degrees=(time/12)*360
fourier degrees, n(2)
```

* add the interaction term to the model
```
glm aces smokban inter_smokbantime cos* sin* time, family(poisson) link(log) offset(logstdpop) scale(x2) eform
```
* the coefficient and CI for the interaction term suggests that there is very little slope change)

* plot seasonally adjusted model with deseasonalised trend**
```
predict pred4, nooffset
//
egen avg_cos_1 = mean(cos_1)
egen avg_sin_1 = mean(sin_1)
egen avg_cos_2 = mean(cos_2)
egen avg_sin_2 = mean(sin_2)
drop cos* sin*
rename avg_cos_1 cos_1
rename avg_sin_1 sin_1
rename avg_cos_2 cos_2
rename avg_sin_2 sin_2
//
predict pred5, nooffset
//
twoway (scatter rate1 time) (line pred4 time, lcolor(red)) (line pred5 time, lcolor(red) lpattern(dash)), title("Sicily, 2002-2006") ///
ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year) ///
xline(36.5)
```
