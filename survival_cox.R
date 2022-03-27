## ----setup, include=FALSE------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ------------------------------------------------------------------------------------
library(KMsurv)
library(tidyverse)
library(survival)


## ------------------------------------------------------------------------------------
data(bmt)
bmt = bmt %>% select(-c(t1,d1,d2,ta,da,tc,dc))


## ------------------------------------------------------------------------------------
head(bmt,n=10)
help(bmt)


## ------------------------------------------------------------------------------------
bmt2=bmt
names(bmt2) = c("group",    "dfs" ,   "dfsstatus"  , "tp" ,   "dp" ,   "agep" ,   "aged"  ,  "genderp"  ,  "genderd",    "cmvp"  ,  "cmvd"  ,  "waiting"  ,  "fab" ,   "hospital" ,   "mtw"  )
glimpse(bmt2) #sorte de transpose juste pour voir les variables renommées


## ------------------------------------------------------------------------------------
bmt2$group = recode(bmt2$group, "1"="ALL","2"="Low","3"="High")
bmt2$genderp = recode(bmt2$genderp, "1"="Male","0"="Female")
bmt2$genderd = recode(bmt2$genderd, "1"="Male","0"="Female")
bmt2$cmvp = recode(bmt2$cmvp, "1"="Positive","0"="Negative")
bmt2$cmvd = recode(bmt2$cmvd, "1"="Positive","0"="Negative")
bmt2$hospital = recode(bmt2$hospital , "1" = "Ohio State U.", "2" = "Alferd" , "3" = "St. Vincent", "4" = "Hahnemann")
bmt2$dp = recode(bmt2$dp, "1"="Return Normal","0"="Not Return normal")
bmt2$dfsstatus = recode(bmt2$dfsstatus, "Dead Or Relapsed"=1,"Alive Disease Free"=0)
bmt2$mtw = recode(bmt2$mtw, "1"="Yes","0"="No")
glimpse(bmt2)


## ------------------------------------------------------------------------------------
bmt2 %>% drop_na()


## ------------------------------------------------------------------------------------

table(bmt2$dfsstatus)*100/sum(table(bmt2$dfsstatus))


## ------------------------------------------------------------------------------------
summary(bmt2$dfs)
ggplot(bmt2, aes(x=dfs)) + ggtitle('Histogram of dfs')+
 geom_histogram(aes(y=..density..), colour="black", fill="white",bins=30)+
 geom_density(alpha=.2, fill="#FF6666") 


## ------------------------------------------------------------------------------------
 head(bmt2)


## ------------------------------------------------------------------------------------
cbind(bmt2$tp,bmt2$agep, bmt2$aged, bmt2$waiting)


## ------------------------------------------------------------------------------------
bmtcor <- cor(cbind(bmt2$tp,bmt2$agep, bmt2$aged, bmt2$waiting),method="spearman")#Spearman test robuste
bmtcor
corrplot(as.matrix(bmtcor), method='color', addCoef.col = "black", type="lower", tl.col="black", tl.srt=45,title='Matrice de corrélation')


## ------------------------------------------------------------------------------------
fisher.test(bmt2$genderd,bmt2$genderp)
wilcox.test(bmt2$tp~bmt2$genderp)
kruskal.test(bmt2$tp~bmt2$hospital)


## ------------------------------------------------------------------------------------
library(MASS)
cox_model_raw = stepAIC(coxph(Surv(dfs,dfsstatus)~group+tp+dp+agep+aged+genderp+
                        genderd+cmvp+cmvd+waiting+
                        fab+hospital,data=bmt2),trace=F)
summary(cox_model_raw)


## ------------------------------------------------------------------------------------
library(survminer)
ggsurvplot(survfit(cox_model_raw), conf.int = FALSE, 
           surv.median.line="hv",xlab="Time",ylab="Disease Free Survival Indicator",
           break.time.by=365,title=" Disease Free Survival curve",
           risk.table = TRUE,tables.height = 0.30,
           font.main = c(12, "bold", "darkblue"),
           font.x = c(8, "bold.italic", "red"),
           font.y = c(8, "bold.italic", "darkred"),
           font.tickslab = c(8, "plain", "darkgreen"),  
           data = bmt2)


## ------------------------------------------------------------------------------------
cox.zph(cox_model_raw)
par(mfrow=c(2,4))
plot(cox.zph(cox_model_raw))


## ------------------------------------------------------------------------------------
bmt2$id = c(1:nrow(bmt2))
bmt2_merge <- tmerge(bmt2,bmt2,id=id,endpt=event(dfs,dfsstatus))
bmt2_merge <- tmerge(bmt2_merge,bmt2,id=id,p_recovery=tdc(tp)) #adds platelet recovery as tdc
#bmt2_merge)
head(bmt2_merge)
head(bmt2)


## ------------------------------------------------------------------------------------
bmt2$hospital = recode(bmt2$hospital , "1" = "Ohio State U.", "2" = "Alferd" , "3" = "St. Vincent", "4" = "Hahnemann")


## ------------------------------------------------------------------------------------
cox_model_raw2 = stepAIC(coxph(Surv(tstart,tstop,endpt)~group+agep+aged+genderp+
                        genderd+cmvp+cmvd+waiting+p_recovery+
                        fab+hospital,data=bmt2_merge),trace=F)
summary(cox_model_raw2)

## ------------------------------------------------------------------------------------
cox.zph(cox_model_raw2)
par(mfrow=c(2,4))
plot(cox.zph(cox_model_raw2))


## ------------------------------------------------------------------------------------
cox_model_raw3 = stepAIC(coxph(Surv(tstart,tstop,endpt)~group+agep+aged+genderp+
                        genderd+cmvp+cmvd+waiting+p_recovery+
                        fab+strata(hospital),data=bmt2_merge),trace=F)
summary(cox_model_raw3)

## ------------------------------------------------------------------------------------
cox.zph(cox_model_raw3)
par(mfrow=c(2,4))
plot(cox.zph(cox_model_raw3))


## ------------------------------------------------------------------------------------
library(caret)

quartiles_aged = quantile(bmt2_merge$aged,probs = seq(0,1,0.25))
bmt2_merge$aged_discret = cut(bmt2_merge$aged, quartiles_aged)
quartiles_agep = quantile(bmt2_merge$agep,probs = seq(0,1,0.25))
bmt2_merge$agep_discret = cut(bmt2_merge$agep, quartiles_agep)



## ------------------------------------------------------------------------------------
bmt2_merge_small = bmt2_merge %>% drop_na()


## ------------------------------------------------------------------------------------
cox_model = stepAIC(coxph(Surv(tstart,tstop,endpt)~group+agep_discret+aged_discret+genderp+
                        genderd+cmvp+cmvd+waiting+p_recovery+
                        fab+strata(hospital),data=bmt2_merge_small),trace=F)
summary(cox_model)


## ------------------------------------------------------------------------------------
cox_model_final = stepAIC(coxph(Surv(tstart,tstop,endpt)~group+agep_discret+p_recovery+
                        fab+strata(hospital),data=bmt2_merge_small),trace=F)
summary(cox_model_final)

## ------------------------------------------------------------------------------------
cox.zph(cox_model_final)
par(mfrow=c(2,4))
plot(cox.zph(cox_model_final))


## ------------------------------------------------------------------------------------
ggsurvplot(survfit(cox_model_final), conf.int = FALSE, 
           surv.median.line="hv",xlab="Time",ylab="Disease Free Survival Indicator",
           break.time.by=365,title=" Disease Free Survival curve using cox",
           tables.height = 0.30,
           font.main = c(12, "bold", "darkblue"),
           font.x = c(8, "bold.italic", "red"),
           font.y = c(8, "bold.italic", "darkred"),
           font.tickslab = c(8, "plain", "darkgreen"),  
           data = bmt2_merge_small)


## ------------------------------------------------------------------------------------
bmt_group=survfit(Surv(dfs,dfsstatus)~group,data=bmt2_merge_small)
ggsurvplot(bmt_group, conf.int = FALSE, 
           surv.median.line="hv",xlab="Time",ylab="Disease Free Survival",
           break.time.by=365,title="Disease Free Survival curve in fonction of group",
           risk.table = TRUE,tables.height = 0.30,
           font.main = c(12, "bold", "darkblue"),
           font.x = c(8, "bold.italic", "red"),
           font.y = c(8, "bold.italic", "darkred"),
           font.tickslab = c(8, "plain", "darkgreen"), pval = TRUE, 
           data = bmt2_merge_small)

