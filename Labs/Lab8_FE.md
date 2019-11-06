# HS 409A Lab 8: Fixed Effects
Fall 2019  
TA: Mark Zocchi (mzocchi@brandeis.edu)

#### Goal
1. To estimate a fixed effects regression model in Stata

#### Objectives
1. Preliminary analysis for panel data
2. Estimate a fixed effects model

#### Research Question
1. What deterrent factors are associated with lower crime rates?

#### Dataset:
Panel data consisting of crime data rates and other related variables of 90 North Carolina counties from 1981-1987. (N= 630 observations)  

| <br>  Variable Name<br>   | <br>  Description<br>                                                                                                                 |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| <br>  lcrmrte  <br>       | <br>  Log of the number of crimes per person (dependent<br>  variable)<br>                                                            |
| <br>  d82-d87<br>         | <br>  Dummy<br>  variables indicating years 1982-1987<br>                                                                             |
| <br>  lprbarr<br>         | <br>  Log probability of arrest (ratio of arrests to<br>  offenses)<br>                                                               |
| <br>  lprbconv<br>        | <br>  Log probability of conviction (ratio of<br>  convictions to arrests)<br>                                                        |
| <br>  lprbpris<br>        | <br>  Log probability of serving time given a conviction<br>  (proportion of total convictions resulting in prison sentencing) <br>   |
| <br>  lavgsen<br>         | <br>  Log of average sentence (sanction severity)<br>                                                                                 |
| <br>  lpolpc<br>          | <br>  Log of police officers per capita<br> 
