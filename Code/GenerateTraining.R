#Takes long/ short format and compares with excel file to generate training/ verification files
# rm(list=ls())
library(readxl)
library(DescTools)

#default: for testing
# FileName <- "VO0006_VP7_LM40_20150501"
# VidCode <- strsplit(FileName, "_")[[1]][1]# code for excel
# Year <- "2015"

#Takes defined short format, matches it with excel and produces a new short and long csv 
CodefrmExcelOld <- function(FileName,VidCode,Year){ # for old excel format
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
  Closeindex <- DescTools::Closest(Short$MeanTime, mergedf$Time[i], which=TRUE)[1] #find which time is closest
  
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

require(dplyr)
NewLong <- full_join(Long,ShortMerge)
#used dplyr join instead, because merge shuffles the order
#NewLong <- merge(Long,ShortMerge,by="Event", all=T)

write.csv(NewLong, file=paste("../Data/Frames/",FileName,"/FramesLongCoded.csv", sep=""))

}

#for testing:
# FileName <- "VO0157_VP11_MM1_20150615"
# VidCode <- strsplit(FileName, "_")[[1]][1]# code for excel
# Year <- "2015"

CodefrmExcelNew <- function(FileName,VidCode,Year){
  Short <- read.csv(paste("../Data/Frames/",FileName,"/FramesShort.csv", sep=""))
  excel <- read_excel(paste("../Data/Excel/DVDs ",Year,"/",VidCode,".xlsx", sep=""))
  
  #Figuring out the in and out times for being inside
  FemaleIN <- subset(excel,excel$Fstate=="IN")
  MaleIN <- subset(excel, excel$Mstate=="IN")
  
  FemValIn <- FemaleIN$Fstart
  FemValOut <- FemaleIN$Fend
  MalValIn <- MaleIN$Mstart
  MalValOut <- MaleIN$Mend
  
  #Figuring Out bird being Around:
  FemArd <- subset(excel,excel$Fstate=="A")
  MalArd <- subset(excel, excel$Mstate=="A")
  FemArd$MeanTime <- (FemArd$Fstart+FemArd$Fend)/2
  MalArd$MeanTime <- (MalArd$Mstart+MalArd$Mend)/2
  
  FemValA <- FemArd$MeanTime
  MalValA <- MalArd$MeanTime
  
  #Figuring out when bird is feeding from outside ('OF')
  FemOF <- subset(excel,excel$Fstate=="OF")
  MalOF <- subset(excel, excel$Mstate=="OF")
  FemOF$MeanTime <- (FemOF$Fstart+FemOF$Fend)/2
  MalOF$MeanTime <- (MalOF$Mstart+MalOF$Mend)/2
  
  FemValOF <- FemOF$MeanTime
  MalValOF <- MalOF$MeanTime
  
  
  #combine into dataframe for matching:
  mergedf <- data.frame(Time=c(FemValIn,FemValOut,FemValA,FemValOF,MalValIn,MalValOut,MalValA,MalValOF), 
                        Sex=c(rep(0,length(FemValIn)+length(FemValOut)+length(FemValA)+length(FemValOF)), 
                              rep(1,length(MalValIn)+length(MalValOut)+length(MalValA)+length(MalValOF))),
                        EventDes=c(rep("In",length(FemValIn)), rep("Out", length(FemValOut)),
                                   rep("Around", length(FemValA)),rep("OutsideFeeding", length(FemValOF)),
                                   rep("In",length(MalValIn)), rep("Out",length(MalValOut)), 
                                   rep("Around", length(MalValA)),rep("OutsideFeeding",length(MalValOF))))
  
  Short$Time <- NA
  Short$Sex <- NA
  Short$EventDes <- NA
  
  for(i in 1:nrow(mergedf)){
    Closeindex <- DescTools::Closest(Short$MeanTime, mergedf$Time[i], which=TRUE)[1] #find which time is closest
    
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
  if(sum(duplicated(ShortMerge$Event))>0){ #newly added, avoid cases where there is no duplicates
  #if there are duplicates
    ShortMerge <- ShortMerge[-which(duplicated(ShortMerge$Event)),]
  }else{
    #if there are no duplicates, do nothing
  }
  
  require(dplyr)
  NewLong <- full_join(Long,ShortMerge)
  
  write.csv(NewLong, file=paste("../Data/Frames/",FileName,"/FramesLongCoded.csv", sep=""))
}


CodefrmExcel <- function(FileName,VidCode,Year){
  excel <- read_excel(paste("../Data/Excel/DVDs ",Year,"/",VidCode,".xlsx", sep=""))
  if(sum(names(excel)%in%"Fstart")>0){
    #If Fstart is one of the columns, it is the new excel format
    CodefrmExcelNew(FileName,VidCode,Year)
  }else{
    #old format
    CodefrmExcelOld(FileName,VidCode,Year)
  }

}