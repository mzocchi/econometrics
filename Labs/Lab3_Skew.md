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

#### One-part OLS model
```
regress mhvisct age-fmsize ivdrug-preg
estimates store ols1
```
