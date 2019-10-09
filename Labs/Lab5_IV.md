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
tab z_arrest x_arrest, row chi


* Next, let's just look at results based on treatment delievered, ignoring the randomization (x_arrest):





