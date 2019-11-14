# HS 409A Lab 9: Random Effects
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)


#### Goal:
To estimate a random effects regression model in Stata

#### Objectives: 
1.	Preliminary analysis for panel data
2.	Estimate a random effects model
3.	Compare pooled OLS, fixed effects, and random effects

#### Research Questions: 
1)	What are the predictors of airfare? 

#### Dataset:
Panel data consisting of airfare data and other related variables of 1,149 air routes from 1997-2000. (N= 4,596 observations)

* **Load** the dataset:
```
bcuse airfare, clear
```
* **Examine** the data
```
codebook, compact
browse
```

### Part I: Preliminary Analysis for Panel Data
* The xt syntax provides descriptive summaries for panel data.  However, we must indicate that the data is in panel format using xtset before using any other xt command.

* **Set and examine** panel data:
```
xtset id year
xtsum id year fare passen dist
```

#### A.	Tables and graphs for preliminary analysis
* **Table of means** for airfare, # of passengers, and distance by route ID for route id <=10
```
table id, contents(mean fare mean passen mean dist), if id<=10
```

* **Scatter plot** of airfare and number of passengers  
```
twoway  (scatter fare passen if id==1, mcolor(blue) msymbol(circle) mfcolor(blue) mlcolor(blue)) /// 
		(scatter fare passen if id==2, mcolor(green) msymbol(circle)) ///
		(scatter fare passen if id==3, mcolor(magenta) msymbol(circle)) ///
		(scatter fare passen if id==4, mcolor(yellow) msymbol(circle)), ///
		ytitle(Average One-way Fare ($)) xtitle(Average Number of Passengers per Day) xtitle(, size(medium)) ///
			legend(on order(1 "Akron,OH to Atlanta, GA" 2 "Akron, OH to Orlando, FL" 3 "Albany, NY to Atlanta, GA" 4 "Albany, NY to Chicago, IL"))
```

* **Scatter plot** of airfare by route ID
```
bysort id: egen yi_mean=mean(fare)
twoway scatter fare id, msymbol(circle_hollow) || connected yi_mean id, msymbol(diamond) || , xlabel(1 "Route 1" 2 "Route 2" 3 "Route 3" 4 "Route 4"), if id<=4
```
* **Scatter plot** of airfare by year 
```
bysort year: egen yt_mean=mean(fare)
twoway scatter fare year, msymbol(circle_hollow) || connected yt_mean year, msymbol(diamond) || , xlabel(1997(1)2000)
```
* **Line graph** of airfare across the years for route id <=10
```
xtline fare if id<=10, overlay
```

#### B. Estimate a pooled OLS model for model comparison

* **Estimate a pooled OLS model** with **robust standard errors** for model comparison 

* In a “naïve” OLS model, we assume that the observations are independent of one another.  This **assumption is unsupported** when we are working with panel data because observations from the same group/cluster are at least partially dependent.  
```
reg lfare lpass ldist ldistsq y98 y99 y00, robust
estimates store OLS
```
* Since this is a log-log model , we interpret the coefficients as percentage changes (elasticities).  For example, a 1% increase in the average number of passengers is associated with a 0.09% decrease in airfare.

* According to the pooled OLS model with the robust option, the CI is -0.097 to -0.075. This means that there is a 95% probability that a 1% increase in the average number of passengers per day is associated with a 0.097% to 0.075% decrease in one-way airfare.  However, because we are **not accounting** for the repeated measures nature of the data, which is susceptible to serial correlation, the test statistics and standard errors estimates are **invalid**.  Consequently, the confidence intervals are **unreliable**. The robust option is often used to correct for heteroskedasticity.  However, compared to an OLS without robust standard errors (not shown), the change is very small.  

#### C. Calculate the turning point for the quadratic using:
<p align="center"> ldist = -b2/(2b3) </p>

* From the pooled OLS model, note that as the log of distance increases, airfare decreases.  However, it does so at a decreasing rate until a minimum is reached, at which point the airfare starts to increase (U-shaped curve).   It is helpful to find the minimum or maximum value of a quadratic relationship between an independent variable (X and X2) and the dependent variable (Y) for more meaningful interpretation. Below shows the Stata commands to calculate the turning point of when distance will began to **increase** airfare.
```
scalar turn=-1*(_b[ldist]/(2*_b[ldistsq]))
display turn
display exp(turn)
```
* We should make sure that the turning point is within our data range. We should also focus on the range that is relevant to our research when we interpret the model coefficients.  Considering that 97 is the turning point, we can say that airfare increases when the distance is greater than 97 miles.
```
sum  dist
```

### Part II. Estimate a random effects model
#### A.	Identify panel data in Stata and estimate a random effects model.
* Note that the procedure and commands are similar to the ones used for fixed effects. The difference is indicating that we want random effects estimates by including “re” at the end of the xtreg command.    Recall that theoretically, a major difference between FE and RE is that RE assumes that the unobserved effects (ai) is uncorrelated with the independent variables. 
```
xtset id year
xtreg lfare lpass ldist ldistsq y98 y99 y00, re
estimates store re
esttab re OLS, b(%7.2f) star stats(N r2 r2_a) se
```

#### B. Compare pooled OLS and random effects models using Breusch and Pagan Lagrangian multiplier test for random effects
* The Breusch-Pagan statistic tests the null hypothesis that var(u)=0 (that is, that the between-units variation is 0). Under the null condition, OLS is consistent. If you accept the null (test not significant), you should use OLS. If you reject the null (test is significant), you should consider using random effects because there is evidence of clustering.
```
estimates restore re
xttest0
```

#### C. Calculate lambda
* Lambda specifies how much weight is given to the mean for the unit (across time-periods), as opposed to the individual observation. I generally think of lambda as the degree of the variations between groups/clusters. So if there isn’t variation across groups, then OLS is appropriate.  Otherwise, we should consider fixed or random effects.

  >Note: Wooldrige refers to the between variance as σa, which is denoted as sigma_u in Stata. Woodridge refers to the within variance as σu, which is demoted as sigma_e in Stata.

* Lambda formula: λ = 1 –   [σ2u  / (σ2u + Tσa^2)]^0.5  
> If λ =0, there is no or negligible variance between units, relative to the variance within units.  
If λ =1, there is a lot of variance between units, relative to the variance within units.

````
scalar sig_u=e(sigma_e)
scalar sig_a=e(sigma_u)
scalar T=4
scalar lambda=1-sqrt(sig_u^2/(sig_u^2+(T*sig_a^2)))
display lambda
````

### Part III. Compare pooled OLS, fixed effects, and random effects

#### A. Run a fixed effects regression model to compare with random effects
* Notice from the output that both *ldist* and *ldistsq* are dropped from the fixed effects model.  This is because distance between two cities will not change over time.  From the output, we estimate that a 1% increase in the average number of passengers is associated with a 0.37% decrease in airfare.  
```
xtreg lfare lpass ldist ldistsq y98 y99 y00, fe
estimates store fe
esttab fe re OLS, b(%7.2f) star stats(N r2 r2_a) se mtitle("FE" "RE" "OLS")
```
* When we compare the estimates of FE, RE, and pooled OLS, we should keep in mind what each approach assumes about the unobserved effect, ai, and how the assumptions may cause bias in the estimates.  To review, pooled OLS assumes that all observations are independent and thus leaves ai entirely in the error term.  Fixed effects assumes that ai is associated with the independent variables and thus, partial out ai.  RE assumes that ai is not associated with the independent variables, and through the RE transformation, ai is partially left in the error term.  

#### B. Compare fixed effects with random effects using the Wu-Hausman test
* The Wu-Hausman test can be used to determine if we should use fixed effects or random effects.  The null hypothesis (H0: cov(ai, xit)=0) is that the RE estimator provides consistent/unbiased estimates. If we accept the null hypothesis(test is insignificant), then RE should be used. If we reject the null (test is significant), then RE provides biased estimates so we should use FE. 
```
hausman fe re
```
