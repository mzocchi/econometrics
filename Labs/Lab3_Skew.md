# HS 409A Lab 3: Skewed Data: Log Transformations, GLM, and 2-part Models
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)  

#### Goal: 
Practice working with regression models for dependent variables that have skewed/non-normal distributions.

#### Objectives: 
1. To develop models for estimating the number of mental health treatment visits individuals had during a given year. 

#### Dataset: 
HMLS

#### Preliminary steps in Stata:  
* Download and unzip the "Lab3_Skew" folder from LATTE  
* Open the do file "Skew.do" in Stata  
* Set your working directory to the unzipped "Lab3_Skew" folder
* Import the HMLS dataset from Excel and save in Stata.

```
import excel "hmls_data.xlsx", sheet("Sheet1") firstrow case(lower) clear
save "hmls_data.dta",replace
```
**Descriptive Statistics** 

```
summarize
```
**Missing Data Table**

```
mdesc
```
#### Address missing data
* Generate new variable (misscount) that will count how many missing values there are for each observation. 
```
egen misscount = rowmiss(fid-preg)
```
* View a table showing the results
```
tab misscount
```
* There are many ways of dealing with missing data. One option is to delete observations that have a lot of missing data or missing data on key variables of interest (e.g. the main dependent variable). 

*	Our dependent variable is going to be number of mental health visits ("mhvisct"). Let's drop all observations for which data is missing on "mhvisct"
```
drop if mhvisct == .
```
*	Lets also drop all observations for which there was no data available
(i.e. missing values for all 27 vars in dataset)
```
drop if misscount == 27)
```

* Is dropping all observations a good idea?
* Alternatives for handling missing values?

#### Descriptive Statistics
* Examine dependent variable and assess it for skewness
  * Look at mean vs. median in summary statistics
  * Look at skewness (symmetry) and kurtosis (spread)
  * Use a skewness/kurtosis test for normality (Ho: data is normally distributed)

  ```
  summarize mhvisct, detail
  sktest mhvisct
  ```
* Generate a histogram overlaid with normal distribution
* Generate a normal quantiles plot
```
hist mhvisct, norm
qnorm mhvisct
```

#### One-part OLS model:
<img src="http://latex.codecogs.com/gif.download?%5Cinline%20MentalHlthVisit%20%3D%20%5Cbeta%20_0%20+%20X%5Cbeta%20+%20%5Cmu" />  

```
regress mhvisct age-fmsize ivdrug-preg
estimates store ols1
```
* Generate residuals and predicted values for outcome (MH visits)

```
predict r1 if e(sample), resid
predict yhat1 if e(sample), xb
label var r1 "Residuals from model OLS1"
label var yhat1 "Predicted values from model OLS1"
```

* Test MLR.6: Normality of errors  
  * Are errors non-normally distributed?
```
summarize r1, detail
histogram r1, normal
qnorm r1
```	

* Test MLR.5: Constant variance (homoskedasticity)
	* First, inspect graphically
```
rvfplot, yline(0)
scatter r1 mhvisct, yline(0)
```
	
  * Next, run heteroskedasticity tests (Breusch-Pagan and White's test)
    * Breusch-Pagan test Ho: no heteroskedasticity
    * *Note: For non-normal data, B-P test does not work well. White's test is better.*
    * White's test Ho: no heteroskedasticity 

    ```
estat hettest 
estat imtest
```

* Test MLR.4: Zero-conditional mean
  * Assumption could be violated if dependent var is skewed
  * Use a link test and look at estimate for "_hatsq". A significant t-stat indicates that the dependent variable may need to be transformed.
```
	linktest
```

#### One-part OLS model with log transformation of dependent variable:
* Transform the DV (MH visits) with the log function 
  * We have lots of zeros; can't take log of zero
  * "Nudge" the data over a little bit to lose zeros
```
	gen log_mhvisct = ln(.01+mhvisct)
	label var log_mhvisct "Log of MH visits"
```

* How does the distribution of "log_mhvsict" look?
  * Any better than without log transformation?
```
	summarize log_mhvisct, detail
	histogram log_mhvisct, norm
	qnorm log_mhvisct
```

* Run new OLS model with log-transformed DV
```
regress log_mhvisct age-fmsize ivdrug-preg
est store ols2
```

* Generate residuals and predicted values
```
predict r2 if e(sample), resid
predict yhat2 if e(sample), xb
label var r2 "Residuals from model OLS2"
label var yhat2 "Predicted values from model OLS2"
```

* Test MLR.6: Normality of errors
  * Are errors non-normally distributed?
```
estimates restore ols2
summarize r2, detail
qnorm r2, saving(r2qnorm)
```
  * Compare to non-transformed model
```
histogram r2, norm saving(r2hist)
histogram r1, norm name(r1hist, replace)
graph combine r1hist.gph r2hist.gph r1qnorm.gph r2qnorm.gph, rows(2)
```

* Test MLR.5: Constant variance (homoskedasticity)
  * Inspect graphically
```
rvfplot, yline(0) saving(r2rvf)
graph combine r1rvf.gph r2rvf.gph, rows(2) holes(2 3)
scatter r2 logmhvisct, yline(0)
```
  * Run heteroskedasticity tests
```
estat hettest
estat imtest
```
* Test MLR.4: Zero-conditional mean
  * Assumption could be violated if dependent var is skewed
  * Use a link test and look at estimate for "_hatsq" 
```
linktest
```

#### Two-part model: Probit and OLS
