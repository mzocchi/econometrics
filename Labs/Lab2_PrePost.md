# HS 409A Lab 2: Pre-Post Study Designs
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)  

#### Goal: 
To estimate OLS regression models in Stata for pre-post study designs

#### Objectives: 
1. Estimate and interpret a regression model for a pre-post study
2. Complete a difference-in-differences table using Stata and by hand

#### Research Questions: 
1. Was there a wage difference between 1978 and 1985, controlling for other factors? Did this difference differ by gender?

#### Dataset: 
Pooled cross sectional dataset of individuals’ hourly wages and related predictors of two time periods, 1978 and 1985. (N= 1,084 observations)

####  Model:
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29_i_t%20%3D%20B_0_i%20&plus;%20B_1y85_i%20&plus;%20B_2female_i%20&plus;%20B_3y85*female_i%20&plus;%20B_4educ_i%20&plus;%20B_5exper_i%20&plus;%20B_6expersq_i%20&plus;%20B_7union_i%20&plus;%20e_i" />

#### Preliminary steps in Stata:  
* Download and unzip the "Lab2_PrePost" folder from LATTE  
* Open the do file "PrePost.do" in Stata  
* Set your working directory to the unzipped "Lab2_PrePost" folder
* Open the Wages.dta dataset:

```
cd "/Volumes/GoogleDrive/My Drive/Heller/TA Courses/Econometrics/Labs/Lab2_PrePost" 
use "Wages.dta", clear 
```
#### Descriptive Statistics
```
summarize  
codebook, compact  
bysort year: sum wage  
sdtest wage, by(year)  
ttest wage, by(year) unequal  
```
#### Log Transformation
* Do wages follow a normal distribution?  

```
hist wage, norm
qnorm wage
```
* If data were normally distributed, but variances were unequal (as determined by the sdtest), you could do a ttest for unequal variances (ttest with unequal option).  

```
ttest wage, by(year) unequal
```
* However, there are alternatives that are preferred in the case of skewed data.  
Log-transformation of the skewed variable, check for normality and equal variance, conduct t-test:

```
qnorm lwage
sdtest lwage, by(year)
ttest lwage, by(year)
```
#### Pooled model design for pre-post analysis
* Start with an overall model pooling both years together (i.e. do not put year in the model)
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1female%20&plus;%20B_2educ%20&plus;%20B_3exper%20&plus;%20B_4expersq%20&plus;%20B_5union%20&plus;%20u" />  

```
regress lwage female educ exper expersq union
estimates store m1
```
* Interpret the coefficient for education (edu):
> For every additional year of eduction, wages are expected to increase by approximately 9 percent (95% CI 7.7% to 9.9%).

* for larger coefficients, eg female, exponentiate the coefficient and subtract to interpret a percentage change. 
  
```
di exp(-.251)-1
```    
> On average, wages for females are 22.2% lower than males holding experience, education, and union status constant.

* Interpret the constant (B0):
> The average wage for males (female = 0), with zero years of education (edu = 0), zero experience (exper = 0 , expersq=0), and who are not in a union (union = 0) was approximately $1,550 (exp(.443) = 1.55)

* Now add in a covariate to control for survey year (y85)
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1y85%20&plus;%20B_2female%20&plus;%20B_3educ%20&plus;%20B_4exper%20&plus;%20B_5expersq%20&plus;%20B_6union%20&plus;%20u" /> 

```
regress lwage y85 female educ exper expersq union
estimates store m2
```
* Let's compare models in a table  

```
esttab m1 m2, b(%7.4f) se star stats(N r2 r2_a)
```
* How does the interpretation of the coefficients change with y85 added to the model?
  
* We might hypothesize that the wage gap between females and males changed between 1978 and 1985

```
table year female, c(mean lwage)
```
* It appears that the difference may have declined between 1978 and 1985. To test this formally, we include an interaction term:
* Let's create an interaction term

```
gen y85fem = y85*female
label var y85fem "Females in 1985"
```
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1y85%20&plus;%20B_2female%20&plus;%20B_3y85fem%20&plus;%20B_4educ%20&plus;%20B_5exper%20&plus;%20B_6expersq%20&plus;%20B_7union%20&plus;%20u" />

```
regress lwage y85 female y85fem educ exper expersq union 
estimates store m3
```
* Now compare all three models:

```
esttab m1 m2 m3, b(%7.4f) se star stats(N r2 r2_a)
```
* Interpret the interaction term, B3(y85fem)
> Between 1978 and 1985, wages for females increased by 8.8% relative to males.  
> Or you could say-  Wages for females increased 8.8% more than males between 1978 and 1985.

#### Differences-in-differences table
* Let's focus on Model 3
* Predicted means (in log-wages) for each group
* Use these values to find the D-i-D effect (B3 from Model 3):

```
* Men in '78 -- reference group:
	margins, at(y85=0 female=0 y85fem=0)

* Women in '78
	margins, at(y85=0 female=1 y85fem=0)

* Men in '85
	margins, at(y85=1 female=0 y85fem=0)

* Women in '85
	margins, at(y85=1 female=1 y85fem=1)
	
* difference between men and women in 1978:
	di 1.487 - 1.807
	
* difference between men and women in 1985:
	di 1.929 - 2.160
	
* difference-in-difference 1985 v 1978: 
	di -0.231 - -0.32
```

<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1female%20&plus;%20B_2y85%20&plus;%20B_3y85*fem%20&plus;%20B_4educ%20&plus;%20B_5exper%20&plus;%20B_6expersq%20&plus;%20B_7union%20&plus;%20u" />

<img src = "https://github.com/mzocchi/econometrics/blob/master/IMG_8451.JPG />  
<img src = "https://github.com/mzocchi/econometrics/blob/master/IMG_2744.JPG />  

#### Margins and Margins Plots
* Another equivalent option to get the same values: use Stata's factor notation. Factor notation will help when using margins.

```
reg lwage i.y85##i.female educ c.exper##c.exper union 
margins i.y85#i.female
```
* Margins plot is a nice way to visualize the results from the margins table.

```
marginsplot 
```
* If you want to create an interaction term with a continious variable (e.g. experience), you will need to put a 'c.' in front (we will remove the quadratic term to simplify):

```
regress lwage female c.exper##y85 educ union 
```
* for margins, specify what levels of the continous variable you are interested in. Note: any covariates ommitted will be set at their means by default.

```
margins y85, at(exper=(1 4 10 20))
```
* we may also want set another variable in the model at a specific value, e.g., union members

```
margins y85, at(exper=(1 4 10 20) union=1)
marginsplot
```
* From the plot, it looks like the effect of experience on wages is about the same in 1978 as it was in 1985. This is confirmed by the fact that our interaction term in the regression model is very small and not signficant.

#### Regression with centered variables
* Sometimes, we center variables on a meaningful value for easier interpretation of the constant.  For instance, we may center a “years of education” variable at 12 years. Below is an example of generating a new education variable centered at the 12th year. You could also center the variable "experience" at the average (e.g. 18 years). We will just center education for this example.

```
gen c_educ= (educ-12)
regress lwage y85 female y85fem c_educ exper expersq union
```
* Now, the constant (B0) is more interpretable. We interpret the constant as when y85=0, y85fem = 0 , c_educ = 0, exper = 0, and expersq = 0. eg, the average log wages of males in 1978 (y85=0 and y85fem = 0) *for people with a high school education* (c_educ=0) without any experience (exper = 0 and expersq = 0).

#### Extra
* Helpful video on interactions using Stata and interpreting coefficients: https://www.youtube.com/watch?v=9dNZJziERHw 

* Why do we have an experience squared term in the model?

```
twoway (scatter lwage exper) (qfit lwage exper) (lfit lwage exper)
```
* From the quadratic fit line (red) it looks like people with many years of experience start to see reduced wages.
* Find the turning point (i.e. when experience starts to have a negative effect on wage)

```
estimates restore m3
nlcom -_b[exper]/(2*_b[expersq])
*or 
display = -(.0294761)/(2*-.0003975)
```
**Another method for D-i-D: Stratified approach:**

* We could also stratify by gender and fit a pair of separate models:
* one for the males and one for the females in the sample
* Model for men (if female==0)

```
reg lwage y85 educ exper expersq union if female==0
est store mm
```
* Model for women (if female==1)

```
reg lwage y85 educ exper expersq union if female==1
est store mf
```
* Compare estimates from each model.
* Which coefficients are different? What does it mean?

```
esttab mm mf, b(%7.4f) se star stats(N r2 r2_a)
```
* Now we can generate predicted values from each model to complete our D-i-D analysis like we did in the pooled approach
* Need to restore results from first stratified model (men) to get the predicted values.

```
est restore mm
margins, at(y85=0)
margins, at(y85=1)
```
* And now restore results from the second model (women) and get the predicted values

```
est restore mf
margins, at(y85=0)
margins, at(y85=1)
```
