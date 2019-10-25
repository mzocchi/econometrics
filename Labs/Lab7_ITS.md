# HS 409A Lab 6: Interrupted Time Series (ITS) Analysis
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

***
* This lab uses Stata code and tutorial from the the paper: *Interrupted time series regression for the evaluation of public health  interventions: a tutorial* (J. Lopez Bernal, S. Cummins, A. Gasparrini; IJE 2016).
***

#### Goal
1. Learn the requirements for an ITS design and how to use ITS to estimate the impact of an intervention.

#### Objectives
1. Review the requirements for an ITS design
2. Hypothesize how the intervention may impact the outcome
3. Descriptive analysis
4. Regression analysis 

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
|  Variable | Description  |
|:----------|:-------------|
| year  
| month
| time      |  elapsed time since the start of the study |
| aces      |  count of acute coronary episodes in Sicily per month (the outcome) |
| smokban   |  smoking ban (the intervention) coded 0 before the intervention and 1 after | 
| pop       |  the population of Sicily (in 10000s) |
| stdpop    |  age standardised population |


* Here we convert the counts into a rate and examine a scatter plot of the pre-intervention data

```
gen rate = aces/stdpop*10^5  
twoway (scatter rate time) if smokban==0, ///
  title("Sicily, 2002-2006") ytitle(Std rate x 10000) yscale(range(0 .)) ylabel(#5, labsize(small) angle(horizontal)) ///
xtick(0.5(12)60.5) xlabel(6"2002" 18"2003" 30"2004" 42"2005" 54"2006", noticks labsize(small)) xtitle(year)
```
