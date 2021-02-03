#Takes long/ short format and compares with excel file to generate training/ verification files
rm(list=ls())
library(readxl)
library(DescTools)

FileName <- "VO0006_VP7_LM40_20150501"
VidCode <- strsplit(FileName, "_")[[1]][1]# code for excel
Year <- "2015"

#Takes defined short format, matches it with excel and produces a new short and long csv
CodefrmExcel <- function(FileName,VidCode,Year){
Short <- read.csv(paste("../Data/Frames/",FileName,"/FramesShort.csv", sep=""))
excel <- read_excel(paste("../Data/Excel/DVDs ",Year,"/",VidCode,".xlsx", sep=""))


#round to decimal
FemValIn <- na.omit(excel$`F in`)
FemValOut <- na.omit(excel$`F out`)
MalValIn <- na.omit(excel$`M in`)
MalValOut <- na.omit(excel$`M out`)

mergedf <- data.frame(Time=c(FemValIn,FemValOut,MalValIn,MalValOut), 
                      Sex=c(rep(0,length(FemValIn)+length(FemValOut)), 
                                rep(1,length(MalValIn)+length(MalValOut))),
                      EventDes=c(rep("In",length(FemValIn)), rep("Out", length(FemValOut)),
                              rep("In",length(MalValIn)), rep("Out",length(MalValOut))))
Short$Time <- NA
Short$Sex <- NA
Short$EventDes <- NA

for(i in 1:nrow(mergedf)){
  Closeindex <- DescTools::Closest(Short$MeanTime, mergedf$Time[i], which=TRUE) #find which time is closest
  
  #check if there is duplicates:
  if(is.na(Short$Sex[Closeindex])){
    #is empty, can replace with new data
    Short[Closeindex,names(Short) %in% c("Time","Sex","EventDes")] <- mergedf[i, names(mergedf) %in%c("Time","Sex","EventDes") ]
    
  }else{
    #not empty, duplicate then add a row  
    newIndex <- nrow(Short) +1
    Short[newIndex, ] <- Short[Closeindex,]
    Short[newIndex,names(Short) %in% c("Time","Sex","EventDes")] <- mergedf[i, names(mergedf) %in%c("Time","Sex","EventDes") ]

  }
  
}

write.csv(Short, file=paste("../Data/Frames/",FileName,"/FramesShortCoded.csv", sep=""))

#Convert Short back to Long
Long <- read.csv(paste("../Data/Frames/",FileName,"/FramesLong.csv", sep=""))

ShortMerge <- Short[,names(Short) %in% c("Event","Sex","EventDes")]
ShortMerge <- ShortMerge[-which(duplicated(ShortMerge$Event)),]

NewLong <- merge(Long,ShortMerge,by="Event", all=T)

write.csv(NewLong, file=paste("../Data/Frames/",FileName,"/FramesLongCoded.csv", sep=""))

}