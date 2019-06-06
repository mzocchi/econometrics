# HS 409A Lab: OLS Review

**Goal:** To test assumptions for OLS using a dataset in Stata

### Objectives: 
1.	Review Stata codes for descriptive statistics and linear regression
2.	Check OLS assumptions

**Research Question:** What factors are associated with deaths due to coronary heart disease?
Dataset: Annual mortality rates due to heart disease and other potentially related variables from 1947-1980. (N=34 years)

**Model:**  
<img src="https://latex.codecogs.com/gif.latex?Chd&space;=&space;\beta_{0}&plus;\beta_{1}Cal&plus;\beta_{2}Unemp&plus;\beta_{3}Cig&plus;\beta_{4}Edfat&plus;\beta_{5}Meat&plus;\beta_{6}Spirits&plus;\beta_{7}Beer&plus;\beta_{8}Wine&plus;\mu" title="Chd = \beta_{0}+\beta_{1}Cal+\beta_{2}Unemp+\beta_{3}Cig+\beta_{4}Edfat+\beta_{5}Meat+\beta_{6}Spirits+\beta_{7}Beer+\beta_{8}Wine+\mu" />

#### Preliminary steps in Stata:  
* Download "raw" data from LATTE or [here](coronary-3.csv)
* <a href="https://youtu.be/60RBNsqzL6I" target="_blank">Import</a> raw data into Stata
* Save Stata dta file in a folder
* Begin a “Do-file” by clicking on the icon on the top center panel; save the do-file in the designated folder.

### Objective 1: Review Stata codes for descriptive statistics and linear regression
**A. Codes for univariate and bivariate statistics**
* *Describe*, *summarize*, and *codebook* are some Stata commands that will provide a general illustration of your dataset.  Information such as the averages, min, max, and standard deviations may be obtained from summarize and codebook. Describe will give you a general sense of the variable types and variable definitions as recorded in the dataset.   
    describe  
    summarize  
    codebook, compact  
* For continuous variables, it may be helpful to explore their correlations with one another using pwcorr.  You can also obtain a graph of the correlations and use the half option to avoid redundant output.  
    pwcorr edfat meat, sig  
    graph matrix chd-wine, half

**B. Codes for linear regression and saving estimates, residuals, & predicted values**
* The common command for OLS regression is *reg* ("regression"), which is followed by the dependent variable then independent variables. 
    reg chd cal-wine
* *Est* ("estimates") is a post-estimation command, meaning that you must run a model before using this command. Here, we want to save the estimates of the regression model we previously ran under the name “m1”.
    est store m1
* Obtain & label the residuals for the observations that are used in the regression model.  
The residuals will be important for testing OLS assumptions later.  We restrict this prediction to only observations used in the current model, as indicated by the e(sample) option.  
    predict r if e(sample), resid
    label var r “residuals”
* Obtain & label the standardized residuals for the observations that are used in the regression model.  
We obtain the standardized residuals by dividing them by the standard error.  Standardization sets the mean of the residuals at zero and standard deviation at 1.0.  Thus, if the distribution of the residuals is normal, then we can expect that 95% of the residuals fall between two standard deviations of the mean on both sides.  Likewise, we expect that approximately 5% of the residuals will be beyond this region.  
    predict rstd if e(sample), rstandard

