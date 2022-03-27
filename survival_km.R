## ----setup, include=FALSE------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ------------------------------------------------------------------------------------
library(survival)
library(survminer)
library(tidyverse)


## ------------------------------------------------------------------------------------
data=load('D:/SAF 2/LONGITUDINAL_DATA_ANALYSIS/survival_km/chomage_tp.rda')
chomage<-Dataset


## ------------------------------------------------------------------------------------
head(chomage)


## ------------------------------------------------------------------------------------
chomage$status[chomage$statut=="evenement"]<-0
chomage$status[chomage$statut=="censure"]<-1

chomage_surv=Surv(chomage$temps,chomage$status)


## ------------------------------------------------------------------------------------
chomage_km=survfit(chomage_surv~1,type="kaplan-meier")
summary(chomage_km)


## ------------------------------------------------------------------------------------
ggsurvplot(chomage_km, conf.int = FALSE, 
           surv.median.line="hv",xlab="Time",ylab="unemployement",
           break.time.by=1,title="unemployment risk curv",
           risk.table = TRUE,tables.height = 0.30,
           font.main = c(12, "bold", "darkblue"),
           font.x = c(8, "bold.italic", "red"),
           font.y = c(8, "bold.italic", "darkred"),
           font.tickslab = c(8, "plain", "darkgreen"),
           data = chomage)


## ------------------------------------------------------------------------------------
chomage_km_bygrp=survfit(chomage_surv~chomage$genre,type="kaplan-meier")
summary(chomage_km_bygrp)


## ------------------------------------------------------------------------------------
ggsurvplot(chomage_km_bygrp, conf.int = FALSE, 
           surv.median.line="hv",xlab="Time",ylab="unemployement",
           break.time.by=1,title="unemployment risk curv",
           risk.table = TRUE,tables.height = 0.30,
           font.main = c(12, "bold", "darkblue"), risk.table.col = "strata",
            ggtheme = theme_bw(),            
           font.x = c(8, "bold.italic", "red"),
           font.y = c(8, "bold.italic", "darkred"),
           font.tickslab = c(8, "plain", "darkgreen"), pval = TRUE, 
           data = chomage)


## ------------------------------------------------------------------------------------
survdiff(chomage_surv~chomage$genre)

