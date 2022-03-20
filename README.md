# survival

**Survival analysis is the study of the probability of an event occurence (death, complication, relapse, infection,...) over time which is called *time-to-event* according to explanatory factors**. Thus, in survival analysis we look for:
- The probability to survive at least a certain time "t" from a reference time 
- The probability that the expected event occurs after a certain time "t".

So, the main tasks in survival analysis are:

  ▶ to estimate the time-to-event distributions: estimation\
  ▶ to compare time-to-event distributions in different sub-populations: test\
  ▶ to determine which factors/covariates influence these distributions: regression.

Survival analysis is used in many fields such as:
- biomedical sciences, in particular in clinical trials, epidemiology (event of interest: in cancer for example time to death without prolongation of disease, study of treatment efficacy, ...)
- insurance (event(s) of interest: time of damage)
- economics ( event(s) of interest: time of employment or unemployment)
- engineering (event of interest: downtime analysis)

A survival analysis is :
- longitudinal: following people over time
- prospective: taking into account events that occur during the course of the study
- cohort: observation of a group of people over time
To attempt the main tasks in survival analysis, we use several estimators depending on the case. We have parametric, semi-parametric or non-parametric estimators.

In this work, we will see how to perform survival analysis in each case of problem (parametric, semi-parametric or non-parametric) using R and/or Python.

# Requirements

- R: survival 
- Python: lifelines

# Documentation

https://en.wikipedia.org/wiki/Survival_function

https://fr.wikipedia.org/wiki/Estimateur_de_Kaplan-Meier

https://en.wikipedia.org/wiki/Proportional_hazards_model

# Survival function and hazard ratio

The survival function is a function that gives the probability that a patient, device, or other object of interest will survive past a certain time.
![image](https://user-images.githubusercontent.com/101581394/159171177-c85d3f89-cf62-49a5-897a-cbc12ab1f2fb.png)

Instantaneous risk (hazard rate): For a given t, this is the probability that the event probability that the event will occur within a small interval of time after t knowing that it has not occurred until t.

![image](https://user-images.githubusercontent.com/101581394/159171925-f92b4914-18d1-4a33-9756-a8f54d17bc91.png)

## Parametric survival function

Lorsqu’on fait l’hypothèse selon laquelle les durées de survie appartiennent à une famille de loi donnée, nous sommes dans le cas d’estimation paramétrique. Le ou les paramètre(s) à déterminer dépendent donc de la famille de loi considérée. Ces paramètres peuvent être obtenus par maximisation de fonction de vraisemblance (algorithme itératif EM, algorithme itératif de Newton Raphson ou méthode de gradient). \
We have several families of laws that model survival times and can therefore be used as hypotheses for estimating a survival function:
- Exponential distribution of parameter 
- Weibull distribution
- Gamma distribution
- log-logistic distribution
- ...
For each of the above distributions, we can estimate the parameters of these laws in the case of complete data or censored data (more frequent in real life) in order to estimate survival probabilities or survival functions. 
