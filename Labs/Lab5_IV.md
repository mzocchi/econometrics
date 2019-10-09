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

* The primary outcome for this study is post-treatment episodes of domestic violence (y_postdv). If randomization worked (i.e. z_arrest = x_arrest), we could just do a simple test to test the null hypothesis:
```
tab z_arrest z_postdv, row chi
```
* From this table we find that 9.8% of those arrested and 20.7% of those not arrested had a post treatment episode of domestic violence. a difference of about 11%, which is statistically significant (p<0.05). However, this finding does not take non-compliance into account. We are worried that because officers were more likely to break randomization and arrest the more violent suspects, we may be underestimating the effect of arrest.

```
ivregress 2sls y_postdv (x_arrest = z_arrest), first
```
* You will notice that the coefficient in the first stage is simply the difference in probability of being arrested if assigned to non-arrest and the probability of not being arrested if assigned to arrest (.797 - .011 = .786).

* The second stage of the regression shows the causal effect of being arrested after removing the selection bias. The coefficient -0.139 translates to almost 14 percentage points lower recividism rates for those arrested compared to those not arrested. As suspected, this is a larger effect than the simple estimate we did earlier when just looking at treatement assignment (11% difference).

* What if we just look at the effect of the treatment delivered, regardless of randomization assignment:
```
prtest y_posdv, by(x_arrest)
```
* From these results we find that 12.5% of those arrested had a post treatment episode of DV compared to 21.4% of those not arrested (a difference of only 8.8%, p=0.04).

* Again, we underestimate the effect of arrest on post episode domestic violence.

#### How do we know if we have selected a good instrument?

For a randomized experiment with some non-compliance, it is resonable to assume that the randomization assignment will serve as a good instrument. Why? It is unlikely that randomization had any effect on the outcome *other than* through the treatment. This is not always the case with IVs - especially when there is concern that the IV may be correlated with the error term (Cov(z,x) = 0)   





