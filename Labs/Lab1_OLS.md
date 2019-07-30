# HS 409A Lab 1: OLS Review
August XX, 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

#### Goal:
To test assumptions for OLS using a dataset in Stata

#### Objectives: 
1.	Review Stata codes for descriptive statistics and linear regression
2.	Check OLS assumptions

#### Research Question:
What factors are associated with deaths due to coronary heart disease?

#### Dataset:
Annual mortality rates due to heart disease and other potentially related variables from 1947-1980. (N=34 years)

#### Model:  
<img src="https://latex.codecogs.com/gif.latex?Chd&space;=&space;\beta_{0}&plus;\beta_{1}Cal&plus;\beta_{2}Unemp&plus;\beta_{3}Cig&plus;\beta_{4}Edfat&plus;\beta_{5}Meat&plus;\beta_{6}Spirits&plus;\beta_{7}Beer&plus;\beta_{8}Wine&plus;\mu" title="Chd = \beta_{0}+\beta_{1}Cal+\beta_{2}Unemp+\beta_{3}Cig+\beta_{4}Edfat+\beta_{5}Meat+\beta_{6}Spirits+\beta_{7}Beer+\beta_{8}Wine+\mu" />

#### Preliminary steps in Stata:  
* **Download/unzip** LAB1_OLS folder from LATTE  
* **Open** Lab1.do  
* **Set working directory** and import "raw" data

```
  cd "C:\Heller\409A\Lab1_OLS"  
  import delimited coronary.csv, clear
```
* **Label** the dataset and variables

```
  label data "US rates of mortality due to heart disease"
  label var chd "Deaths due to coronary heart disease"
  label var cal "Per capita consumption of calcium per day"
  label var unemp "Percentage of civilian labor force unemployed"
  label var cig "Per capita consumption of cigarettes in pounds of Tobacco"
  label var edfat "Per capita intake of edible fats and oil, in pounds"
  label var meat "Per capita intake of meat in pounds"
  label var spirits "Per capita consumption of distilled spirits, in gallons"
  label var beer "Per capita consumption of malted liquor in gallons"
  label var wine "Per capita consumption of wine in gallons"

```  
* **Save** data in Stata format (.dta):
  save "OLS.dta", replace
```

#### Objective 1:
Review Stata codes for descriptive statistics and linear regression

* Codes for univariate and bivariate statistics
* *Describe*, *summarize*, and *codebook* are some Stata commands that will provide a general illustration of your dataset.  Information such as the averages, min, max, and standard deviations may be obtained from summarize and codebook. Describe will give you a general sense of the variable types and variable definitions as recorded in the dataset.

```
  describe  
  summarize  
  codebook, compact  
```
* For continuous variables, it may be helpful to explore their correlations with one another using *pwcorr*.  You can also obtain a graph of the correlations and use the half option to avoid redundant output.  

```
    pwcorr edfat meat, sig  
    graph matrix chd-wine, half
```
* Codes for linear regression and saving estimates, residuals, & predicted values
* The common command for OLS regression is *regress* ("reg"), which is followed by the dependent variable then independent variables. 

```
    reg chd cal-wine  
```
* *Estimates* ("est") is a post-estimation command, meaning that you must run a model before using this command. Here, we want to save the estimates of the regression model we previously ran under the name “m1”.  

```
    est store m1
```
* ***Hint:*** If you ever receive the error message, <span style="color:red">last estimates not found</span>, simply restore the estimates you wish to make active.

```
    est restore m1
```
* Obtain & label the residuals for the observations that are used in the regression model.
* The residuals will be important for testing OLS assumptions later. We restrict this prediction to only include observations used in the current model, as indicated by the *e(sample)* option.

```
  predict r if e(sample), resid
  label var r “residuals”
```
* Obtain & label the standardized residuals for the observations that are used in the regression model.  
* We obtain the standardized residuals by dividing them by the standard error.  Standardization sets the mean of the residuals at zero and standard deviation at 1.0.  Thus, if the distribution of the residuals is normal, then we can expect that 95% of the residuals fall between two standard deviations of the mean on both sides. Likewise, we expect that approximately 5% of the residuals will be beyond this region.

```
  predict rstd if e(sample), rstandard
```
* Obtain & label predicted values of the dependent variable (chd)  

```    
  predict yhat  
  label var yhat "predicted values of Chd from m1"  
```
#### Objective 2: Check OLS Assumptions

* **Assumption 1:**   
* Linearity (the relationships between the predictors and the outcome variable should be linear):  
* If there is only one predictor, we can use a scatterplot to detect if the relationship between X1 and Y is linear.  We can use the *lfit* command to show a linear fit.  Adding a lowess (locally weighted scatterplot smoothing) curve can help us detect for nonlinearity.

```
  twoway (scatter chd cal) (lfit chd cal) (lowess chd cal)  
```
* If we are interested in testing the linearity of a multivariate regression (more than one independent variables), we would plot the standardized residuals against each of the independent variables in the model. Ideally, we want to see a random scatter of points. If the scatter plot shows a nonlinear pattern, then there is a problem of nonlinearity. Some of the graphs from Stata output indicate nonlinearity, which may be due to influential points.  
```
    scatter rstd cal  
    scatter rstd unemp  
```

**Assumption 2: Random Sampling**  
* This is not directly testable in Stata. This assumption is satisified (or not) based on the sampling design of our data.  

**Assumption 3: No perfect collinearity (no multicollinearity)**
* This assumption refers to perfectly correlated independent variables.  We simply test this assumption by examining the correlations between the independent variables in our data.  A similar issue is multicollinearity, which is when independent variables are highly correlated but not perfectly correlated.  We can examine the variance inflation factor (VIF) of each variable to determine if multicollinearity is an issue.  VIF values greater than 10.0 suggests multicollinearity.  Remember that different nonlinear functions of the same variables can appear in the model and would not violate this assumption (e.g. income and income^2; income^2 is not a perfect linear function of income).  

```
  est restore m1
  estat vif
```

**Assumption 4: Zero conditional mean**
* The three main problems that cause the zero conditional mean assumption to fail in a regression model are: 1) improper specification of the model, such as omitted variables 2) endogeneity of one or more independent variables, and 3) measurement error of one or more independent variables.  Explanatory variables are “exogenous” if they do not correlate with the error term, which is a good thing.  If they do, they are considered endogenous.  
* *Linktest* command detects model misspecification by regressing the dependent variable on the predicted values (yhat) and the predicted values squared (hatsq).  The idea is that if the model was specified correctly, then no other additional independent variables should be significant except by chance. Thus, we should expect the predicted value (yhat) to be significant because it was predicted from the model and the squared variable (hatsq) to be insignificant if the model is specified properly. If hatsq is significant, then the linktest concludes that there may be omitted variables.

```
  linktest
```
Equivalent to the *linktest*

```
  gen yhat2 = yhat^2
  reg chd yhat yhat2
```

* *Ovtest* is used to test if there may be omitted squared, cubic, or other nonlinear explanatory variables. In summary, Stata regresses the explanatory variable on all predictors and standardized predicted values raised to the 2nd, 3rd, and 4th powers. It then conducts a F-test with the null hypothesis being that the model has no omitted variables. Stata output indicates that we should reject the null hypothesis (P=0.0137); there may be omitted variables in our model. 

```
  estat ovtest
```

**Assumption 5: Homoskedasticity**
* One of the main assumptions for OLS is the homogeneity of variance of the residuals. If the model is well-fitted, there should be no pattern to the residuals plotted against the fitted values. For example:
![Example of homoskedasticity](https://stats.idre.ucla.edu/wp-content/uploads/2016/02/statar38.gif)

* We can detect heteroskedasticity by plotting the residuals against the predicted values.  If the model is well-fitted, there should be no obvious pattern in the graph, indicating that the variance of the residuals is constant.

```
  rvfplot, yline(0)
```
Equivalent to *rvfplot*

```
  scatter yhat r, yline(0)
```
* Two other popular tests for heteroskedasticity are White’s test (*imtest*) and Breusch-Pagan test (*hettest*). Both test the null hypothesis that the variance of the residuals are homogenous.  Thus, if the tests are significant, there is evidence of heteroskedasticity.

```
  estat hettest
  estat imtest
```
**Assumption 6: Normality of errors**
* Kernal density plot is similar to a histogram, except that it has narrow bins and uses moving averages to create a smooth curve. The *pnorm* command graphs a standardized normal probability (P-P) plot while *qnorm* plots the quantiles of a variable against the quantiles of a normal distribution. *Pnorm* is sensitive to non-normality in the range of data; *qnorm* is sensitive to non-normality near the tails. Stata output indicates some minor level of non-normality, but the residuals are quite close to a normal distribution.

```
  kdensity r, normal
  hist rstd, norm
  pnorm r
  qnorm r
```
Here are some examples of what normally distributed errors look like:
**kernal density plot:**  
![Example of Normality of Errors 1](https://stats.idre.ucla.edu/wp-content/uploads/2016/02/statar35.gif)  
**standardized normal probability (P-P) plot:**  
![Example of Normality of Errors 2](https://stats.idre.ucla.edu/wp-content/uploads/2016/02/statar36.gif)  

Another test available is the Shapiro-Wilk W test for normality. The p-value is based on the assumption that the distribution of the residuals is normal. A large pvalue (>0.05) indicates that we cannot reject the assumption that r is normally distributed.

```
  swilk r
```
