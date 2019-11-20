# HS 409A Lab 40: Multilevel Models
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

#### Goal:
To estimate multilevel linear regression models in Stata

#### Objectives: 
1.	Assessing the Need for a Multilevel Model
2.	Estimate several multilevel equations in Stata to answer various research questions

#### Research Questions: 
1. Does pro-tobacco voting behavior vary by state? 
2. Does pro-tobacco voting behavior vary by state, controlling for party and money?
3. Does the effect of party on pro-tobacco voting behavior vary by state, controlling for money?
4. Does the amount of tobacco harvested (state level variable) strengthen the effects of party and money on voting behavior?

#### Dataset:
Data on voting related tobacco legislations of 527 congressmen across 50 states. Below are the variables that we will use to estimate several models. The dependent variable is *Voting %*, the percentage of time that a senator or representative voted in a "pro-tobacco" direction between 1997 and 2000. The variable can range from 0.0 (never voted pro-tobacco) to 1.0 (always voted pro-tobacco).

| Name   | Label                                                                                                         |
|--------|---------------------------------------------------------------------------------------------------------------|
| state  | state abbreviation                                                                                            |
| party  | party affiliation 1=Republican                                                                                |
| votepc | the ratio of the total number of times that a congressman voted in a pro-industry                             |
| money  | the amount of money that the congressman received from tobacco industry political action committee (PAC) ($K) |
| acres  | the number of harvested acres of tobacco in 1999 ($K).     |

#### Data preparation

In multilevel modeling, it is important to know the variables that belong to the group level (level-2) and those that are at the individual level (level-1).  Also, in order to use Stata’s mixed command for multilevel modeling, we need to change any string data to numeric format in order for Stata to read it.

```
cd ". . . "
use luke_tob.dta, clear

codebook, compact
browse id lastname state house party votepct money

encode state, gen(state1)
````
***
### Part I. Assessing the Need for a Multilevel Model

There are two ways to assess if multilevel modeling is necessary.  We can examine the intercepts of each group (i.e. state) by fitting a null model and calculate the interclass correlation coefficient. Another approach is to graph the data points and examine the fitted line of each group.

* Approach 1: Graphical Techniques

  **Scatter plots with linear fits**
```
twoway  (scatter votepct money if state1==5, msize(small) mcolor(black) msymbol(oh)) (lfit votepct money if state1==5, lcolor(black) lwidth(medium) lpattern(solid)) (scatter votepct money if state1==9, msize(small) mcolor(cranberry) msymbol(dh)) (lfit votepct money if state1==9, lcolor(cranberry) lwidth(medium) lpattern(solid)) (scatter votepct money if state1==14, msize(small) mcolor(blue) msymbol(th)) (lfit votepct money if state1==14, lcolor(blue) lwidth(medium) lpattern(solid)) (scatter votepct money if state1==34, msize(small) mcolor(pink) msymbol(sh)) (lfit votepct money if state1==34, lcolor(pink) lwidth(medium) lpattern(solid)) (scatter votepct money if state1==43, msize(small) mcolor(orange) msymbol(pipe)) (lfit votepct money if state1==43, lcolor(orange) lwidth(medium) lpattern(solid)), ytitle("Pro-Tobacco Voting (%)") ytitle(, size(medsmall)) ylabel(0(.2)1, labsize(small)) xtitle("Money received from PACs ({c $|}K) ") xtitle(, size(medsmall)) xscale(range(0 80)) xlabel(, labsize(small)) legend(order(1 "CA" 3 "FL" 5 "IL" 7 "NY" 9 "TX")) title("Relationship of Money and Voting % for 5 Large States", size(med))
```
  **trellis plot**
```
  twoway (scatter votepct money) (lfit votepct money), by(state1, legend(off) note(" ")) xtitle(PAC Money, size(small)) ytitle(Vote %, size(small)) ylabel(0(.2)1)
```
* Approach 2: Intraclass Correlation Coefficient (ICC)

  **Random intercepts model with no level 1 or level 2 predictors (null model)**
  * In multilevel modeling, a null model is a model that does not include any independent variables.  It is strictly to examine the random intercepts to detect if there is any clustering.  Below is the equation of the null model followed by Stata commands to test the model.

**Micro level:**  <img src="http://latex.codecogs.com/gif.latex?votepct_ij%20%3D%20%5Cbeta_0_j%20&plus;%20r_i_j"/>  
**Macro level:**  <img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cmu_0_j"/>  
**Full model:** <img src="http://latex.codecogs.com/gif.latex?votepct_i_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cmu_0_j%20&plus;%20r_i_j"/>  
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j"/> = % of pro-tobacco voting for the ith legislator in particular state (jth state)  
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j"/> = mean outcome (votepct) for the jth state   
<img src="http://latex.codecogs.com/gif.latex?r_i_j"/> = level-1 error, normally distributed with mean of zero and variance σ<sup>2</sup> (person effect)  
<img src="http://latex.codecogs.com/gif.latex?%5Cmu_0_j"/> = random effect associated with state j, with mean of zero and variance τ00 (group effect)

```
mixed votepct || state1:
est store m0
```
**Interpret the parameter estimates from Stata output**
* _cons  = coefficient and CI of the constant and is the grand mean.
* var(_cons)  = represents the variance group of intercepts (between states).
* var(Residual) = is the variance within groups (comparing legislators within states).


Because we have no predictors there is only one fixed effect, the grand mean (_cons), whose estimate is 0.53, we interpret it as the average value of the dependent variable across all subjects. That is, a typical representative or senator is expected to vote pro-tobacco slightly more than half of the time. Another way of saying this is -- the grand mean is the expected value of the voting behavior score for a random legislator in a randomly drawn state.

* The likelihood ratio test at the bottom of the output compares the random intercept model we ran to a linear model with only one intercept. The chi-sq test indicates that our data do not support the single-intercept model (we reject the null hypothesis).   

* After fitting a null model, we want to examine the intraclass correlation (ICC), which is the proportion of the variance of voting behavior that is accounted for by states. The total variance can be decomposed as the sum of the level 1 and level 2 variances.

 <img src="http://latex.codecogs.com/gif.latex?%5Ctextup%7BICC%7D%3D%20%5Cfrac%7Bvar%28%5Cmu_o_j%29%7D%7Bvar%28%5Cmu_o_j%29&plus;%20var%28r_i_j%29%7D"/>  

* In Stata, var(_cons) is the estimate of var(u0j) and var(residual) is the estimate of var(rij) . 

```
* manual calc = var(_cons) / var(Residual) + var(_cons)
di  0.0353/(0.0353+0.0926)
```
```
* postestimation command
estat icc
```
* If the ICC of the null model is zero (or very close to it, e.g. <0.1), that means the observations within clusters are no more similar than observations from different clusters and you can use a simpler analysis technique (e.g. regular OLS)   
***
### Part II. Random intercept model with level 1 predictors

**Research question:** Does voting behavior vary by state, controlling for party affiliation and money?

* For this question, we will used two level-1 predictors (party & money), and no level-2 predictors.  We allow the intercept to vary by state and assume that the other effects are fixed. Therefore the model has 3 fixed effects and 2 random effects. The γ’s are the fixed effects (intercept, party, money) and the μ’s and r’s are the random effects. 

<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMicro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%3D%5Cbeta_0_j%20&plus;%20%5Cbeta_1_j%28party%29_i_j%20&plus;%20%5Cbeta_2_j%28money%29_i_j%20&plus;%20r_i_j"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMacro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cmu_0_j"/>  
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_1_j%20%3D%20%5Cgamma_1_0"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_2_j%20%3D%20%5Cgamma_2_0"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BFull%20Model%3A%20%7D"/>  
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_1_0%28party%29_i_j%20&plus;%20%5Cgamma_2_0%28money%29_i_j%20&plus;%20%5Cmu_0_j%20&plus;%20r_i_j"/>  
<p>

```
mixed votepct party money || state1:
est store m1
estat icc
```

**Interpret the model results**  
* _cons (γ00) = 0.200. This is no longer interpreted as the grand mean of voting percentage, but rather as the expected value of voting percentage when all of the predictors (party and money) are zero. So according to these data Democratic legislators (Party=0) who have received no money from tobacco industry PACs are expected to vote pro-tobacco 20% of the time. 
* party (γ10) = 0.496, which tells us that the effect of being Republican is to vote pro-tobacco 49.6% more often compared to Democrats. 
* money (γ20) = 0.00447, which means that for every $1000 received by a legislator we would expect to see an increase in pro-tobacco voting of approximately 0.45%.
* The random effect part of the model is concerned with the variance components. The random variables u0j should be interpreted as residuals at the group level or group effects that are unexplained by level-1 variables. This information should be used to decide whether we should add more variables to the model or to stop adding variables at the particular level.
* The intraclass correlation indicates that states account for about 17% of the variability of voting behavior among legislators.  We can use this as evidence that we should add more predictors to the model.  Also note that the level-1 and level-2 variance components are smaller than the null model, mainly due to the predictors added in this model.

**Compare models**
* We can run a likelihood ratio test to compare models.  The null hypothesis is that there is no significant differences between the models.  Here, we can reject the null and conclude that model #1 is better that the null model.

  ```
lrtest m0 m1, stats
```
***
### Part III. Random slope model with level 1 predictors
**Research question:** Does the effect of party on voting behavior vary by state, controlling for money? 

<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMicro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%3D%5Cbeta_0_j%20&plus;%20%5Cbeta_1_j%28party%29_i_j%20&plus;%20%5Cbeta_2_j%28money%29_i_j%20&plus;%20r_i_j"/>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMacro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cmu_0_j"/>  
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_1_j%20%3D%20%5Cgamma_1_0%20&plus;%20%5Cmu_1_j"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_2_j%20%3D%20%5Cgamma_2_0"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BFull%20Model%3A%20%7D"/>  
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_1_0%28party%29_i_j%20&plus;%20%5Cgamma_2_0%28money%29_i_j%20&plus;%20%5Cmu_0_j%20&plus;%20%5Cmu_1_j%28party%29_i_j%20&plus;%20r_i_j"/>
<p>

Where: 
>γ00 = average of the state means on voting percent across the population of states  
γ10 = the average party regression slope across states  
γ20 = the average money regression slope. We do not allow this to vary across states.  
μ0j = the unique deviation of the intercept of each state from the overall intercept γ00.  
μ1j = the unique deviation of the slope within each group from the overall slope γ10. We allow the slope for party to vary across states. In other words, we are stipulating that individual voting behavior is related to party AND that the relationship between party and voting can vary from state to state.  
rij = level-1 error, normally distributed with mean of zero and variance σ2 (person effect)


We may want to graph the relationship between voting behavior and money by party to have a sense  if the effect of party affiliation on voting vary by state.
```
twoway (scatter votepct money) (lfit votepct money),by(party, legend(off) note(" ")) xtitle(PAC Money) ytitle (Pro-Tobacco Vote %)
twoway (scatter votepct money) (lfit votepct money) if inlist(state1,5,9,14,34,43), by(state1 party, legend(off) note(" ")) xtitle(PAC Money) ytitle (Pro-Tobacco Vote %)
```
From the graphs, we have some evidence to support that the effect of party on voting behavior  vary by state.
```
mixed votepct party money || state1: party, cov(uns) var
est store m2
estat icc
```
* **Note:** The command above includes the “covariance” component.  It is good practice to include this option and not assume that the random effects terms are independent, which is Stata’s default.  Instead, we assume that there ***is*** a correlation between the intercepts and the slopes of party.

**Interpret the model results**  
*Fixed effects: Note changes from model 1*  
* _cons(γ00) = 0.213. This is the expected value of voting percentage when all of the predictors are zero. So according to these data, Democratic legislators (Party=0) who received no money from tobacco industry PACs are expected to vote pro-tobacco 21.3% of the time.
* party (γ10) = 0.489, which tells us that the effect of being Republican is to vote pro-tobacco 48.9 percentage-points more often compared to Democrats. 
* money (γ20)= 0.0042, which means that for every $1000 received by a legislator we would expect to see an increase in pro-tobacco voting of approximately 0.42 percentage points.

*Random effects:*
* var(_cons) represents the variance of voting behavior across states, after controlling for the effects of party and money.  It is a measure of deviation of each state’s intercept from the overall intercept
* Var(party) tells us the variation of the effect of party on voting across states, controlling for money. In other words, it measures the deviation of each state’s slope from the overall slope for party.

**Compare models**  
```
lrtest m1 m2
```

After running the model, we can ask Stata to calculate the fitted values for each state.  Stata will include both the fixed and random effects in the calculation.

```
predict yhat_m2, fitted 
```
We can then graph the fitted values against the observed values
```
twoway (line yhat_m2 money) (lfit votepct money, lpattern(dash)) (scatter votepct money, msize(small) msymbol(oh) mcolor(gray)) if inlist(state1,5,9,14,34,43), by(state1 party, note("")) xtitle(PAC Money) ytitle (Pro-Tobacco Vote %) legend(order(1 "Fitted Slope" 2 "Observed Slope" 3 "Obeserved Values"))
```
* Predict the group-level error u for both the intercept (u2) and slope (u1)
  ```
  predict u*, reffects
	```
* Examine the predicted values for the five largest states:
	```
  sort state1 party
  browse state1 lastname party votepct money yhat_m2 u2 u1 if inlist(state1,5,9,14,34,43)
  ```


***
### Part IV. Random slope, random coefficient model with level-two and level-one predictors
**Research question:** Does the amount of tobacco harvested (acre-state-level variable) affect pro-tobacco voting behavior? 
<br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMicro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%3D%5Cbeta_0_j%20&plus;%20%5Cbeta_1_j%28party%29_i_j%20&plus;%20%5Cbeta_2_j%28money%29_i_j%20&plus;%20r_i_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMacro%20Level%3A%20%7D"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_0_1%28acres%29_j&plus;%20%5Cmu_0_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_1_j%20%3D%20%5Cgamma_1_0%20&plus;%20%5Cmu_1_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_2_j%20%3D%20%5Cgamma_2_0"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BFull%20Model%3A%20%7D"/> <br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_0_1%28acres%29_j%20&plus;%20%5Cgamma_1_0%28party%29_i_j%20&plus;%20%5Cgamma_2_0%28money%29_i_j%20&plus;%20%5Cmu_0_j%20&plus;%20%5Cmu_1_j%28party%29_i_j%20&plus;%20r_i_j"/> <br>
<p>

Where: 
> γ01(acres) = effect of state-level tobacco acreage on pro-tobacco voting.

Note that in this model, acres only influences the intercept (B<sub>0j</sub>)

* Model 3. Random slope + level-2 predictor (acres)
```
mixed votepct party money acres || state1: party, cov(un)
est store m3
estat icc
lrtest m2 m3, stats
```

**Interpret the results**  
*Fixed effects:*  
Political party and PAC contributions are highly significant level-1 predictors (p<0.001), tobacco acreage is significant at the 90% level but its effect appear to be small (for every additional 1,000 acres of tobacco harvested in a state, we would expect to see an increase of pro-tobacco voting of about 0.06%. 
  
*Random effects:*  
Var(_cons): like in the previous models, this variance component represents the variation  or the deviation of each state’s intercept from the overall intercept.  
Var(party): this represents the deviation of each state’s slope from the overall slope term for party, controlling for all other variables in the model.  

***
### Part V. Random slope model with cross-level interactions

**Research question:** Does the amount of tobacco harvested (acre- state level variable) strengthen the effects of party and money on voting behavior? 

The next logical extension of this model is to allow tobacco acreage to include the slopes of the two level-1 predictors, party and money:  

<br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMicro%20Level%3A%20%7D"/>
<br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%3D%5Cbeta_0_j%20&plus;%20%5Cbeta_1_j%28party%29_i_j%20&plus;%20%5Cbeta_2_j%28money%29_i_j%20&plus;%20r_i_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BMacro%20Level%3A%20%7D"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_0_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_0_1%28acres%29_j&plus;%20%5Cmu_0_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_1_j%20%3D%20%5Cgamma_1_0%20&plus;%20%5Cgamma_1_1%28acres%29_j%20&plus;%20%5Cmu_1_j"/> <br>
<img src="http://latex.codecogs.com/gif.latex?%5Cbeta_2_j%20%3D%20%5Cgamma_2_0%20&plus;%20%5Cgamma_2_1%28acres%29_j"/> <br>

<img src="http://latex.codecogs.com/gif.latex?%5Ctextbf%7BFull%20Model%3A%20%7D"/> <br>
<img src="http://latex.codecogs.com/gif.latex?votepct_i_j%20%3D%20%5Cgamma_0_0%20&plus;%20%5Cgamma_0_1%28acres%29_j%29&plus;%5Cgamma_1_0%28party%29_i_j%20&plus;%20%5Cgamma_1_1%28acres%29_j%28party%29_i_j"/>
<img src="http://latex.codecogs.com/gif.latex?&plus;%20%5Cgamma_2_0%28money%29_ij%20&plus;%20%5Cgamma_2_1%28acres%29_j%28money%29_i_j%20&plus;%20%5Cmu_0_j%20&plus;%20%5Cmu_1_j%28party%29_i_j%20&plus;%20r_i_j"/><br>

* Looking at the full model, we see that we have to include two interaction terms to examine the cross-level effects: 1) party and acres, and 2) money and acres:

```
mixed votepct acres party c.acres#i.party money c.acres#c.money || state1: party, cov(un) var
```

**Interpret the results**

**Fixed effects:**  
Tobacco acreage (acres) significantly affects the average voting level in a state (remember that we have acres in the intercept equation), but there are also significant cross-level interactions. The negative coefficient for the two interactions indicate that the presence of tobacco farming ‘dampens’ or reduces the effect of being Republican and the effect of receiving money.  

It can be difficult to interpret all the effects in a complex multi-level model. A simple plot of the predicted values can be helpful.  

As an example, this graph shows the expected voting percentages for Democratic legislators for three different levels of tobacco acreage. 

```
twoway (lfit yhat_m4 money if state1==14, range(0 100)) (lfit yhat_m4 money if state1==10, range(0 100)) (lfit yhat_m4 money if state1==27, range(0 100)) if party==0, legend(order(1 "Low acreage (IL)" 2 "Moderate acreage (GA)" 3 "High acreage (NC)")) ylabel(0(.2)1) xtitle("PAC Money") ytitle("Predicted Voting-Democrat (%)")
```

* The solid line shows the relationship of tobacco PAC money (in $1000s) on voting in a state like Illinois, where there is no tobacco acreage. 
* The dashed line in the middle shows the relationship of tobacco money in a state like Georgia, which has a moderate level of tobacco acreage (33,000 acres).
* The dotted line at the top shows the effect of tobacco money in a state like North Carolina, which has a high level of tobacco acreage (200,000 acres).
* In general, the more money accepted by Democratic legislators, the more likely they are to vote pro-tobacco. However, this figure shows that the relationship is *mediated* by the amount of tobacco acreage in that legislator's state. States with more tobacco acres are more likely to vote pro-tobacco (higher intercepts), but at the same time, the effect of tobacco PAC money is lessened.

***
### Part VI. Model Diagnostics

Two of the most important assumptions of a multi-level model can be empirically tested:  
1. the level-1 (within-group) errors are independent and normally distributed with a mean of zero.  
2. the random effects are normally distributed with a mean of zero, and are independent across groups. 

**Boxplot of level-1 residuals**  
This plot can be used to determine if the residuals are centered at 0 and the the variances are constant across groups.
```
graph hbox r4, over(state1, sort(gsp) descending label(labsize(vsmall))) intensity(0) medtype(cline) medline(lcolor(black)) yline(0, lcolor(black)) scheme(s1mono) xsize(4) ysize(8)
```
* One interesting finding from this plot is that it appears that the outliers (i.e most likely to vote differently than expected) are from the states with the largest population.

**Scatter plot of level-1 standardized residuals**
```	
twoway  (scatter rs4 yhat_m4, msymbol(oh)) (scatter rs4 yhat_m4 if rs>2, msymbol(none) mlabel(state1)) (scatter rs4 yhat_m4 if rs<-2, msymbol(none) mlabel(state1)) (lfit rs4 yhat_m4), by(party, legend(off) note("")) scheme(s1mono) xtitle(Fitted values) ytitle(Standardized residuals) ylabel(,angle(horiz))
```
* The residuals appear to be centered at zero and there may be some problems with heteroskedasicity among the democrats. Residuals increase as the predicted values increase.

**Normal QQ-plot of level-1 residuals**  
```
qnorm r4 if party==0
qnorm r4 if party==1
```

**Normal QQ-plot of level-2 residuals**
```
qnorm u1
qnorm u2
```
* These plots are not as smooth as before, because there are only 50 level-2 residuals (50 states) opposed to 527 level-1 residuals (members of congress). 
