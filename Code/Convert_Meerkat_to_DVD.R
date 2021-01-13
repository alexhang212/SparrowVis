setwd("~/Masters/Project/Computing/Code/")

rm(list=ls())

data <- read.csv("../Data/VT0115_S1_VP7_20190607_MeerkatManual.csv")


#convert time to decimals:
data$Time.dec <-sapply(strsplit(data$Clock, ":"), 
                       function(x){
                         x <- as.numeric(x)
                         x[1]*60 + x[2]+x[3]/60
                       })

#Male Female
Male <- subset(data,data$Sex=="M")
Female <- subset(data,data$Sex=="F")

#Count number of events
#probably a slow run:

#male:
previous <- "Wow"
counter <- 0
EventNumvect <- c(rep(NA,nrow(Male)))
#EventVect <- c() #vector to store event names, not needed anymore

for(i in 1:nrow(Male)){
  current <- Male[i,"Events"]
  
  if(current==previous){
    EventNumvect[i] <- counter
  }else{
    counter <- counter +1
    EventNumvect[i] <- counter
    #EventVect[length(EventVect)+1] <- current
  }
  
  previous <- Male[i,"Events"]
}

Male$EventNum <- EventNumvect
#EventVectMale <- EventVect

#Female:
previous <- "Wow"
counter <- 0
EventNumvect <- c(rep(NA,nrow(Female)))
#EventVect <- c()

for(i in 1:nrow(Female)){
  current <- Female[i,"Events"]
  
  if(current==previous){
    EventNumvect[i] <- counter
  }else{
    counter <- counter +1
    EventNumvect[i] <- counter
    #EventVect[length(EventVect)+1] <- current
  }
  
  previous <- Female[i,"Events"]
}

Female$EventNum <- EventNumvect
#EventVectFemale <- EventVect


#Aggregate data:
MaleSum <- aggregate(Male$Time.dec, by=list(Male$EventNum,Male$Events), FUN=mean, data=Male)
MaleSum$Sex <- "M"

FemaleSum <- aggregate(Female$Time.dec, by=list(Female$EventNum, Female$Events), FUN=mean, data=Female)
FemaleSum$Sex <- "F"

Sumdata <- rbind(MaleSum,FemaleSum)
write.csv(Sumdata,"../Data/VT0115_S1_VP7_20190607_MeerkatManualSummary.csv")


