# Lab 2. Pre Post

### Goal: To estimate OLS regression models in Stata for pre-post study designs

### Objectives: 
1. Estimate and interpret a regression model for a pre-post study
2. Complete a difference-in-differences table by hand

### Research Questions: 
1. Is there a wage difference between 1978 and 1985, controlling for other factors? Does this effect differ by gender?

### Dataset: 
Pooled cross sectional dataset of individuals’ hourly wages and related predictors of two time periods, 1978 and 1985. (N= 1,084 observations)

### Model:
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1y85%20&plus;%20B_2female%20&plus;%20B_3y85*female%20&plus;%20B_4educ%20&plus;%20B_5exper%20&plus;%20B_6expersq%20&plus;%20B_7union%20&plus;%20u" />

#### Preliminary steps in Stata:  
* Download/unzip the Lab2_PrePost folder from LATTE  
* Open lab2.do  
* Set working directory and open dta file
```
        cd "C:\Heller\409A\Lab2_PrePost"  
        use "Wage.dta", clear 
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
* lwage = b0 + b1(female) + b2(educ) + b3(exper) + b4(expersq) + b5(union) + u
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1female%20&plus;%20B_2educ%20&plus;%20B_3exper%20&plus;%20B_4expersq%20&plus;%20B_5union%20&plus;%20u" />
```
	regress lwage female educ exper expersq union
	est store m1
```
* for larger coefficients, exponentiate the coefficient and subtract to interpret a percentage change. 
```
	di exp(-.25)-1
```
* Now add in a covariate to control for survey year (y85)
* lwage = b0 + b1(y85) + b2(female) + b3(educ) + b4(exper) + b5(expersq) + b6(union) + u
<img src="http://latex.codecogs.com/gif.latex?Log%28wage%29%20%3D%20B_0%20&plus;%20B_1y85%20&plus;%20B_2female%20&plus;%20B_3educ%20&plus;%20B_4exper%20&plus;%20B_5expersq%20&plus;%20B_6union%20&plus;%20u" />
```	
	regress lwage y85 female educ exper expersq union
	est store m2
```
* Let's compare models in a table
	esttab m1 m2, b(%7.4f) se star stats(N r2 r2_a)

* I hypothosize that the difference in wages between females and males may have changed between 1978 and 1985
	table year female, c(mean lwage)
	
* It appears that the difference may have declined between 1978 and 1985. To test this formally, we include an interaction term:
	* We can create an interaction term
		gen y85fem = y85*female
		label var y85fem "Females in 1985"

	* lwage = b0 + b1(y85) + b2(female) + b3(y85fem) + b4(educ) + b5(exper) + b6(expersq) + b6(union) + u
		reg lwage y85 female y85fem educ exper expersq union 
		est store m3

* Now compare all three models:
	esttab m1 m2 m3, b(%7.4f) se star stats(N r2 r2_a)
	
* ----------------------------------- *
* 	Difference-in-differences table   *
*    pre-post analysis                *
* ----------------------------------- *
	
* Let's focus on Model 3

* Predicted means (in log-wages) for each group
	
	* Use these values to find the D-i-D effect:

		* Men in '78 -- reference group:
		margins, at(y85=0 female=0 y85fem=0)

		* Women in '78
		margins, at(y85=0 female=1 y85fem=0)

		* Men in '85
		margins, at(y85=1 female=0 y85fem=0)

		* Women in '85
		margins, at(y85=1 female=1 y85fem=1)
	
		* difference between men and women in 1978:
			di 1.807-1.487
		* difference between men and women in 1985:
			di 2.160-1.929
		* difference-in-difference:
			di 0.32 - 0.231
		
* Another equivalent option to get the same values: use Stata's factor notation. Factor notation will help when using margins.
	reg lwage y85##female educ exper expersq union 
	margins y85#female
		
	* Margins plot is a nice way to visualize the results from the margins table.
		marginsplot 

* If you want to create an interaction term with a continious variable (e.g. experience), you will need to put a 'c.' in front (we will remove the quadratic term to simplify): 
	reg lwage female c.exper##y85 educ union 
	
	* for margins, specify what levels of the continous variable you are interested in. Note: any covariates ommitted will be set at their means by default.
	margins y85, at(exper=(1 4 10 20))
	
	* we may also want set another variable in the model at a specific value, e.g., union members
	margins y85, at(exper=(1 4 10 20) union=1)
		
	marginsplot
		/* From the plot, it looks like the effect of experience on wages is about the same in 1978 as it was in 1985.
			This is confirmed by the fact that our interaction term in the regression model is very small and not signficant. */

* ----------------------------------- *
* 	 Extra					          *
*    pre-post analysis                *
* ----------------------------------- *

* Why do we have an experience squared term in the model? 
	
	twoway (scatter lwage exper) (qfit lwage exper) (lfit lwage exper)

	* From the quadratic fit line (red) it looks like people with many years of experience start to see reduced wages.
		
* Find the turning point (i.e. when experience starts to have a negative effect on wage)
	estimates restore m3
	
	nlcom -_b[exper]/(2*_b[expersq])
	*or 
	display = -(.0294761)/(2*-.0003975)


*** Another method for D-i-D: Stratified approach ***

* We could also stratify by gender and fit a pair of separate models:
	* one for the males and one for the females in the sample

* Model for men (if female==0)
	reg lwage y85 educ exper expersq union if female==0
	est store mm

* Model for women (if female==1)
	reg lwage y85 educ exper expersq union if female==1
	est store mf

* Compare estimates from each model
	* Which coefficients are different? What does it mean?
	esttab mm mf, b(%7.4f) se star stats(N r2 r2_a)

* Now we can generate predicted values from each model
* to complete our D-i-D analysis like we did in the pooled approach

* Need to restore results from first stratified model (men) to get its
* predicted values
	est restore mm

	margins, at(y85=0)
	margins, at(y85=1)

* And now restore results from the second model (women) and get its
* predicted values
	est restore mf

	margins, at(y85=0)
	margins, at(y85=1)
