# HS 409A Lab 4: Propensity Scores
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)  

#### Goal:
Use propensity scores to make the treatment and comparison groups more comparable.

#### Objectives: 
1.	Select variables for the propensity score model
2.	Compute propensity scores and check balance of results
3.	Estimate the average treatment effect on the treated using various matching and weighting techniques

#### Research Questions:
Does attending catholic high school affect 12th grade math achievement?

#### Model:
<p style="text-align: center;">
<img src="http://latex.codecogs.com/gif.latex?Logit/Probit%28Catholic%29%20%3D%20B_0%20&plus;%20B_1Inc8%20&plus;%20B_2Inc^2%20&plus;%20B_3math8%20&plus;%20B_4mathfam" /><br><br>
<img src="http://latex.codecogs.com/gif.latex?Math12%20%3D%20B_0%20&plus;%20B_1Catholic%20&plus;%20e" /></p>

#### Dataset:
Cross sectional dataset of 5,671 students on their academic achievement, family income, catholic school attendance, and demographics.  

#### Preliminary steps in Stata
* Download and unzip the "Lab4_PScore" folder from LATTE  
* Open the do file "PSlab.do" in Stata  
* Set your working directory to the unzipped "Lab4_PScore" folder
* Open the education.dta data file.
* Download/install pscore and psmatch2

```
cd "..."
use education.dta, clear 
capture ssc install psmatch2
findit pscore
  // (download st0026_2 for latest version if not already installed) 
```
#### Objective 1: Explore variables for the propensity score model
**Family income, Catholic school attendance, and 12th grade math achievement**  
* The main idea behind propensity scores is creating a comparable treatment and control group so that we can test the effects of treatment on the outcomes.
* In many cases, we have too many observations in the comparison group that that are not comparable to those in the treatment group, making it difficult to evaluate the effectiveness of treatment. *Thus, the first step is to assess if there are differences between the comparison and the treatment groups.*
* Relating this to the research question, we want to know if there are differences between students who attended Catholic school versus those that did not. 
* *If there are differences*, we want to select individuals who did not attend Catholic school that are similar to those who did, and compare their math achievement.

**Descriptive statistics, t-test**
```
tabstat math12, by(catholic) stat(N mean sd min max)
ttest math12, by(catholic)
```
* Students who attended catholic schools had  12th grade math scores about 4 points higher than students who did not attend catholic schools.

```
tab faminc8 catholic, row chi2
```
* There are income differences between students who attended Catholic school versus non-attendees. Lower income categories consist of more students who did not attend Catholic school.
* Since there are so few observations of catholic school attendance among the very low income groups, we may want to collapse the income categories into broader categories for analyses (i.e. low income, middle income, and high income). The option “icodes” labels categories using integers (e.g. 1, 2, 3, etc.). We specify that the first new category should include observations <$20K; the second category, $20K < X < $35K; the third category, $35K < X < $75K.

```
egen catfaminc8=cut(faminc8), at(1,9,11,13) icodes
label define inccat2 0 "Low income: <$20K" 1 "Middle income: $20K-$35K" 2 "High Income >$35K"
label values catfaminc8 inccat2
```
* Always a good idea to confirm that you coded your new variable correctly:
```
tab faminc8 catfaminc8
```
* We now check for differences in match scores using the new recoded income categories

```
table catfaminc8 catholic, contents(mean math12) 
```
* We can see that across the three income categories, mean math scores in 12th grade was higher for those that attend catholic school.
* We now check to see if this difference is statistically significant in each of the income categories:

```
by catfaminc8, sort: regress math12 catholic   
*or:
by catfaminc8, sort: ttest math12, by(catholic)
```
* We can see that across the three income categories, math achievement in 12th grade was significantly higher for students who attended catholic schools versus those who did not.  

**8th grade math aptitude, Catholic school attendance, and 12th grade math achievement**  
* A student with high math aptitude in 8th grade may choose to attend Catholic schools, assuming that Catholic schools may provide more rigorous math courses.  
* High math aptitude in 8th grade may also correlate with the outcome variable, math12.  
* We use student math scores in 8th grade as an indicator of math aptitude (math8).  

```
ttest math8, by(catholic)
*or
reg math8 catholic

corr math12 math8  
bysort catfaminc8: regress math8 catholic 
```
* Math scores in 8th grade were about about 2.4 points lower in students that did not attend Catholic school (95% CI -3.2, -1.6)
* Math scores in 12th grade are highly correlated with math scores in 8th grade (correlation = 0.829)
* Like we saw with the 12th grade math scores, We see that math8 is higher in students that attended catholic school attendance in each of the three income groups; however, the difference found in the higher income category is not statistically significant (p=0.132).<br><br>
* From our analysis thus far, we have reasons to believe that family income and math ability may contribute to one’s decision to attend catholic high school.  However, there may be an interactive effect between family income and math ability on catholic high school attendance.  For example, students with high math ability from families with higher income may choose catholic high schools (positive interaction). This interactive effect may also contribute to better 12th grade math achievement.
* To create the interaction term, we need to recode faminc8, as it is currently in a categorical format representing income ranges. We recode faminc8 by giving each individual the middle value of the income range in his/her original income category.  This will help us to create the interaction term between math8 and income to follow. (Note: This average income computation approach may not be the best estimation technique.  We are simply using this approach given the limitations of the data.)

```
recode faminc8 (1=0) (2=0.5) (3=2) (4=4) (5=6.25) (6=8.75) (7=12.5) (8=17.5)  
  (9=22.5) (10=30) (11=42.5) (12=62.5), gen(faminc8r)
label var faminc8r "family income, recoded"
gen faminc8rsq = faminc8r*faminc8r
```
#### Objective 2. Compute propensity scores and check balance of results
* After extensive data exploration in objective #1, we conclude that family income, 8th grade math aptitude, and the interaction between math ability in 8th grade and family income predict Catholic high school attendance and 12th grade math achievement.  
* We now proceed with conducting a logistic regression to predict the likelihood of students attending catholic schools. 
* *Note:* This step is simply to show you how to run a logit model to generate propensity scores. User-written commands or Stata built-in commands for propensity scores will automatically calculate the scores and give you the treatment effect estimates.

**Obtain propensity score using logit**
```
logit catholic c.math8##c.faminc8r faminc8rsq 
predict pscore
tabstat pscore, by(catholic) stat(mean sd min max)
```

**Obtain propensity scores using pscore and psmatch2**
* Two popular commands for propensity score methods are pscore and psmatch2, which we will use for the remainder of this lab exercise. We use pscore because it conveniently computes the propensity scores and identifies the optimal number of blocks.  Adding the detail option will provide an extended output on the balance of the propensity scores for each block and their balance for each covariate within each block.  T-test is used to check for balance. Statistically insignificant results indicate that the treatment and comparison groups are balanced.  This is step 2 and 3 in Garrido et al., 2014.

```
pscore catholic inc8 inc8sq math8 mathfam, logit pscore(p) blockid(b) comsup detail
```
* We can graphically observe the distribution of p-scores by catholic school attendance.

```
histogram p, kdensity kdenopts(gaussian) by(catholic, cols(1) legend(off)) xlabel(0(.1).2) ytitle(Frequency) xtitle(Estimated Propensity Scores)
```

#### Objective 3. Explore matching and weighting techniques using psmatch2
* Note that we want to include only observations that are part of “common support.”  To do so, add “common” to psmatch2. The following matching and weighting procedures require psmatch2 command (this is step 4 in Garrido et al., 2014). Please remember to set the seed at any random number so that the results are reproducible.

**Estimate Average Treatment Effect on the Treated (ATT) using nearest neighbor matching with replacement**  

```
set seed 9262019
psmatch2 catholic faminc8r faminc8rsq math8 mathfam, n(1) outcome(math12) common logit ate 
```

* Check for balance of covariates after matching the sample by a propensity score using pstest. The following command must be done right after psmatch2 (Step 5 in Garrido et al., 2014).  Ideally, %bias (standardized difference) should be low.

```
pstest  math8 faminc8r faminc8rsq mathfam, treated(catholic) graph
```

**Estimate ATT using 1-1 nearest neighborhood matching without replacement and without caliper restriction**  
* Each observation in the treatment group is matched with one in the comparison group that shares the closest propensity scores. If you include the nonreplacement option, there will be only one unique match for each individual in the treatment group. 

```
set seed 9262019
psmatch2 catholic faminc8r faminc8rsq math8 mathfam, outcome(math12) noreplacement common logit ate 
pstest  math8 faminc8r faminc8rsq mathfam, treated(catholic) both graph
```

**Estimate ATT with caliper restriction and with replacement**  
* We can restrict the matches above to only observations with propensity scores within a certain caliper.  The norm is 0.2 standard deviations of the log of propensity scores. We also request for no replacement of matches. You can add the graph option.

```
set seed 9262019
psmatch2 catholic faminc8r faminc8rsq math8 mathfam, outcome(math12) common logit ate caliper(.2)
pstest  math8 faminc8r faminc8rsq mathfam, treated(catholic) graph
```

**Estimate ATT using kernel weighting**   
* “In kernel matching, each treated individual is given a weight of one. A weighted composite of comparison observations is used to create a match for each treated individual, where comparison individuals are weighted by their distance in propensity score from treated individuals within a range or bandwidth of the propensity score” (Garrido et al., 2014, p. 10) Better matches (higher p scores) are given more weights. This reduces bias while adding precision by using the entire sample, excluding only observations outside of the common support.

```
set seed 9262019
psmatch2 catholic faminc8r faminc8rsq math8 mathfam, outcome(math12) kernel common logit ate
pstest  math8 faminc8r faminc8rsq mathfam, treated(catholic) both graph
```

**Interpretation of the treatment effect (Step 6 in Garrido et al., 2014)**  
* Garrido et al. 2014 seems to suggest using psmatch2 in order to use pstest to determine the best matching or weighting technique to estimate the treatment effect. Once determined, they recommend using a built-in Stata command (teffects psmatch) to calculate ATT because the command calculates standard errors based on the fact that propensity scores are estimated. Based on all the matching weighting techniques, it appears that either the 1:1 matching with replacement or matching with caliper set at 0.2 are better options.  Using 1:1 matching with replacement and no caliper, we execute the teffects psmatch command.

```
teffects psmatch (math12) (catholic faminc8r faminc8rsq math8 mathfam), atet nn(1)
```

* Based on our 1:1 matching with replacement strategy, individuals who attended Catholic schools scored 1.826 points higher on 12th grade math achievement compared to those who did not attend.  

#### Extra

**Two additional matching strategies from pscore (must predict propensity scores using pscore before running atts or attnd)**  
* Estimate ATT using stratification matching (post-estimation command of pscore)  
* The stratification matching method takes the difference between the average outcomes of the treatment group and the comparison group of each block.  ATT is calculated as “an average of the ATT of each block with weights given by the distribution of treatment units across blocks.”   

```
psmatch2 catholic faminc8r faminc8rsq math8 mathfam, outcome(math12) n(1) common logit ate
atts math12 catholic, pscore(p) comsup blockid(b) bootstrap
```
* Estimate ATT using nearest-neighbor matching with random draws (post-estimation command of pscore)  
* For nearest-neighbor matching, Stata first sorts all records by the estimated propensity score, then searches forward and backward for the closest match in the comparison group. Random draws means that Stata will draw either the forward or backward matches if they both are equally good.  

```
attnd math12 catholic, pscore(p) comsup detail matchvar(neighbor) matchdta(pickdat)
```
