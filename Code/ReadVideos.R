setwd("D:/Provision Videos/") #Set working directory to hard drive
rm(list=ls())
list.files()

#counting files in each directory
setwd("2012")
list.files()
setwd("Videos")
Prov <- list.files()

Provsplit <- strsplit(Prov, "-")
#find index where length is 1:
index <- which(sapply(Provsplit,function(x) length(x)==1)==TRUE)
Provsplit[index] <- NULL


Days <- sapply(Provsplit, '[[', 3) #get second element from each thing in the list
sum(Days == "6I")
sum(Days == "7P")
