methodscandidate# HS 409A Lab 5: Instrumental Variables
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)  

#### Goal:

#### Objectives: 

#### Background: Minnesota Domestic Violence Experiment
* The Minnesota Domestic Violence Experiment (MDVE) was motivated by debate over the importance of deterrence effects in the police response to domestic violence. For more info see: http://masteringmetrics.com/wp-content/uploads/2015/02/Angrist_2006.pdf

* Officers participating in the experiment randomized suspects of domestic violence into one of three groups: arrest, separation, or advice. However, the researchers found that many suspects randomized to Advice or Separation ("coddled") were arrested anyways. Researchers hypothesized that the treatment delivered was therefore non-random; i.e. those that were randomized to one of the coddled options but were arrested anyways were different than those that were randomized and actually received a coddled option (most cases that broke randomization occurred when a suspected attempted assault on an officer, the victim demanded arrest, or when both the victim and suspect were injured).

#### Research Question:
* Ho: There is no difference in recidivism (defined as one or more episodes of domestic violence post treatment) between the treatments (arrested vs. coddled)

#### Preliminary Analysis:
* Note: for the sake of simplicity, we are only considering arrest vs non-arrest for this exercise.
```
cd " " 
use mvde.dta
codebook, compact
```
* First, we can use a 2x2 table to examine assigned vs delivered treatments in the MDVE. 
```
tab z_arrest x_arrest, row
```
* We can see from the table that almost 100% 91/92 of those randomized to be arrested were arrested. However, only 80% (177/222) of those randomized to be coddled were coddled. Because the treatment was not delivered randomly as intended, the MDVE looks like a broken experiment and is a good candidate for and instrumental variable approach.

* The primary outcome for this study is post-treatment episodes of domestic violence (y_postdv). If randomization worked (i.e. z_arrest = x_arrest), we could just do a simple regression to test the null hypothesis:
```
reg y_postdv x_arrest
estimates store OLS1
```
* From this output we see being arrested resulted in a recidivism rate 7.4 percentages points lower than those not arrested.

* However, this finding does not take the "non-compliance" into account. We are worried that because officers were more likely to break randomization and arrest the more violent suspects, we may be underestimating the effect of arrest using this simple OLS.

* The researchers instead decide to estimate the effect of arrest on recidivism using a two-stage least squares approach with the randomization assignment (z_arrest) as the instrumental variable and actual arrest (x_arrest) as the endogenous explanatory variable. By adding the option "first" the Stata output will include both the first and second stages. 
```
ivregress 2sls y_postdv (x_arrest = z_arrest), first
estimates store IV1
```
* You will notice that the coefficient in the first stage is simply the difference in probability of being arrested if assigned to non-arrest and the probability of not being arrested if assigned to arrest (.797 - .011 = .786).

* The second stage of the regression shows the causal effect of being arrested after removing the selection bias. The coefficient -0.15 (95% CI -0.27 to -0.03) translates to almost a 15 percentage points reduction in recidivism for those arrested compared to those not arrested. As suspected, this is a larger effect than the simple OLS estimate we did earlier when just looking at treatment delivered.

#### How do we know if we have selected a good instrument?

* For a randomized experiment with some non-compliance, it is reasonable to assume that the randomization assignment will serve as a good instrument. Why? It is unlikely that randomization had any effect on the outcome *other than* through the treatment (exclusion restriction) and it is likely randomization is strongly correlated with our explanatory variable of interest (identification assumption). This is not always the case with IVs - especially when there is concern that the IV may be correlated with the error term (Cov(z,u) != 0) or if the IV is only weakly correlated with the endogenous explanatory variable.
```
corr x_arrest z_arrest 
```
* Even though some people did not receive their randomized treatment, there is still a strong correlation between our instrument (randomization) and our explanatory variable (treatment received). This satisfies the identifying assumption. 

* There is no way to test if the exclusion restriction is met. Satisfying this assumption comes from our reasoning that randomization cannot cause post treatment episodes of domestic violence *other than* through receiving the treatment.

#### What about models with multiple covariates?
* So far, our models have not included any covariates. Suppose the setup is the same as before, with the modification that we’d now like to control for a vector of covariates. If randomization had not been broken we could just do:
```
reg y_postdv x_arrest weapon chem i.race i.year
estimates store OLS2
```
and call it a day. However, we suspect that treatment was not delivered in a random way so we use the IV approach. 

* In IV lingo, this is the "reduced form" effect. If you can't see any causal effect in the reduced form, it is probably not going to be there with any IV approach. Here, we still see a significant effect of being randomized to arrest after controlling for the suspect's race, whether or not they had a weapon, and/or were under the influence of drugs/alcohol. 

```
ivregress 2sls y_postdv weapon chem i.race i.year (x_arrest = z_arrest), first
estimates store IV2

esttab OLS1 OSL2 IV1 IV2, keep(x_arrest weapon chem) mtitle(OLS OLS IV IV/2SLS)
```
* In the table we see that arrest has a larger effect when using the instrumental variable approach. The standard errors are larger than in the OLS model, which is expected. 

#### Post estimation tests
* (from Woolridge 15-5) "The 2SLS estimator is less efficient than OLS when the explanatory variables are exogenous; as we have seen, the 2SLS estimates can have very large standard errors. Therefore, it is useful to have a test for endogeneity of an explanatory variable that shows whether 2SLS is even necessary. Obtaining such a test is rather simple."

```
estimates restore IV2
estat endogenous
```
* The Wu-Hausman test Ho hypothesis is that the instruments are exogenous. If we fail to reject the null, we can conclude that the 2SLS estimator is not necessary. Here, we see a significant result (p<0.05) so we should not use the OLS estimate.

#### Another example using multiple instrumental variables

* We don't always have the benefit of a randomized assignment to use as an instrument. This is an example from Woolridge 15.8, which uses mother's and father's education as an instrument for education.

Load the mroz dataset:
```
bcuse mroz
```
(see: http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.des) for variable labels.

We will first run a normal OLS for comparison to the 2SLS model:
```
reg lwage educ exper expersq
estimates store OLS
```
* Every additional year of education increases log-wages by 0.11 (approximately 11% in real wages, p<0.001). 

* We suspect that education is endogenous and think that an IV approach could work using mother and father education as instruments. Before we do that we should make sure that mother's and father's education is indeed correlated with education after controlling for experience (identifying assumption). Because we are using two instruments, we use an F-test for joint significance.
```
reg educ motheduc fatheduc exper expersq
test meduc feduc
```
* Both mother's and father's years of education is jointly significant

* For the exclusion restriction, is it reasonable to assume that mother's and father's education have no effect on the wages of the individual, other than through the individual's own education? 
* This can be *roughly* tested by including these in an OLS regression:
```
reg lwage motheduc fatheduc educ exper expersq
```
However, unlike when we had a random assignment as an IV,  it is less clear that your mother's and father's education would have NO effect on you wages other than by increasing your own education (e.g. social networks, parental job connections, etc.). However, we are reasonably satisfied with our results so we try a 2SLS model. 

```
ivregress 2sls lwage exper expersq (educ=motheduc fatheduc), first
estat endogenous
```
* The Wu-Hausman test is not significant (p>0.05), so our estimates are no different than normal OLS. 

*If we look at the first stage results more closely, we can see that the instrument is not particularly strong, meaning that there is not strong correlation between education and parent's education after controlling for experience (partial r2 = 0.2).
```
estat firststage
```

* With two instruments and only one endogenous explanatory variable we can test to see if the model is over-identified. 
```
estat overid
```
* The null hypothesis is that the instruments are uncorrelated with the error term (meaning that they are exogenous) and that the instruments are correctly excluded from the estimated equation so we are looking for an insignificant p-value here. See Wooldridge Ch. 15 for a more thorough explanation.
