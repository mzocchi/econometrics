# HS 409A Lab 5: Instrumental Variables
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)  

#### Goal:

#### Objectives: 

#### Background: Minnesota Domestic Violence Experiment
* The Minnesota Domestic Violence Experiment (MDVE) was motivated by debate over the importance of deterrence effects in the police response to domestic violence. Police are often reluctant to make arrests for domestic violence unless the victim demands an arrest or the suspect does something that warrants arrest (beside the assault itself).

* Officers participating in the experiment randomized suspects of domestic violence one of three groups: arrest, separation, or advice. However, about 20% of those randomized to Advice or Separation (non-arrest) were arrested anyways. Researchers hypothosized that the treatment delievered was therefore non-random: i.e. those that were arrested but randomized to one of the non-arrest options were different than those that were ranodmized and actually received one of the non-arrest options (most cases that broke randomization occured when a suspected attempted assult on an officer, the victim demanded arrest, or when both the victim and suspect were injured).

#### Research Question:
* Ho: There is no difference in recividism between arrest and non-arrest.

#### Preliminary Analysis:
* Note: for the sake of simplicity, we are going to collapse the two non-arrest groups (Separation and Advice) into one "non-arrest" group.

```
cd " " 
use MDVE.dta
```
* First, we can use a 2x2 table to examine assigned and delivered treatments in the MDVE
```
tab z_arrest x_arrest, row
```
* We can see from the table that almost 100% 91/92 of those assiged to be arrested were arrested. However, only 80% (177/222) of those assigned to one of the non-arrest options were not arrested. Because the treatment was not delivered randomly as intendend, the MDVE looks like a broken experiment and is a good candiditate for IV methodss.

* The primary outcome for this study is post-treatment episodes of domestic violence (y_postdv). If randomization worked (i.e. z_arrest = x_arrest), we could just do a simple regression to test the null hypothesis:
```
reg y_postdv x_arrest
estimates store OLS1
```
* From this output we see that recividism was 8.8 percentages points lower in suspects that were arrested compared to those not arrested.

However, this finding does not take non-compliance into account. We are worried because officers were more likely to break randomization and arrest the more violent suspects, we may be underestimating the effect of arrest using this simple OLS.

```
ivregress 2sls y_postdv (x_arrest = z_arrest), first
estimates store IV1
```
* You will notice that the coefficient in the first stage is simply the difference in probability of being arrested if assigned to non-arrest and the probability of not being arrested if assigned to arrest (.797 - .011 = .786).

* The second stage of the regression shows the causal effect of being arrested after removing the selection bias. The coefficient -0.139 translates to almost 14 percentage points lower recividism rates for those arrested compared to those not arrested. As suspected, this is a larger effect than the simple estimate we did earlier when just looking at treatment delivered.

#### How do we know if we have selected a good instrument?

* For a randomized experiment with some non-compliance, it is resonable to assume that the randomization assignment will serve as a good instrument. Why? It is unlikely that randomization had any effect on the outcome *other than* through the treatment (exclusion restriction) and it is likely randomization is strongly correlated with our explanatory variable of interest (identification assumption). This is not always the case with IVs - especially when there is concern that the IV may be correlated with the error term (Cov(z,x) != 0) or if the IV is only weakly correlated with the endogenous explanatory variable.

```
corr x_arrest z_arrest 
```
* Even though some people did not receive their randomized treatment, there is still a strong correlation between our instument (randomization assignment) and our explanatory variable (treatment actually received). This satisfies the identifying assumption. 

* There is no way to test if the exclusion restriction is met. Statisfying this assumption comes from our reasoning that randomization cannot cause post treatment episodes of domestic violence *other than* through assignment of the treatment.

#### What about models with multiple covariates
* So far, our models have not included any covariates. Suppose the setup is the same as before, with the modification that we’d now
like to control for a vector of covariates. If randomization had not been broken we could just do:
```
reg y_postdv x_arrest weapon chem i.race i.year
estimates store OLS2
```
and call it a day. However, we suspect that treatment was not delivered in a random way so we use the IV approach. 

* In IV lingo, this is the "reduced form" effect. If you can't see any causal effect in the reduced form, it is probably not going to be there with any IV approach. Here, we still see a significant effect of being randomized to arrest after controlling for the suspect's race, whether or not they had a weapon, and/or were under the influence of drugs/alcohol. 

```
ivregress y_postdv weapon chem i.race i.year (x_arrest = z_arrest)
estimates store IV2

esttab OLS1 OSL2 IV1 IV2, keep(x_arrest weapon chem) mtitle(OLS OLS IV/2SLS IV/2SLS)
```
* In the table we see that arrest has a larger effect when using the instrumental variable approach. The standard errors are a bit larger than in the OLS model, which is expected.













