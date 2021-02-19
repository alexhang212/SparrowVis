#Load a trained CNN, input 1 file, determine accuracy
rm(list=ls())
library(keras)
install_keras()

Args <- commandArgs(trailingOnly = TRUE)

FileName <- Args[1]
load(paste("../Arrays/",FileName,"_Array.rda",sep=""))
load(paste("../Arrays/",FileName,"_ImageID.rda",sep=""))

#Load trained CNN model: 
CNN <- load_model_hdf5("../Models/TrainedCNN100-10")
CNN %>% evaluate(ImageVal,ImageID)
predictions <- predict(CNN, ImageVal)


#Verify accuracy:
table(apply(predictions,1,which.max), ImageID)

predictiondf <- data.frame(predictions)
predictiondf$Predict<- apply(predictions,1,which.max)
predictiondf$Actual <- ImageID+1
predictiondf$match <- predictiondf$Predict==predictiondf$Actual

FrameLongCoded <- read.csv(paste("../MeerkatOutput/",FileName,"/FramesLongCoded.csv", sep=""))
FrameLongCoded <- na.omit(FrameLongCoded,FrameLongCoded$Sex)
predictiondf$Frame <- FrameLongCoded$Frame

CombinedData <- cbind(FrameLongCoded, predictiondf) #Combine predictions with long coded df
#quick tests:
print(sum((CombinedData$Sex+1)==CombinedData$Actual)==nrow(CombinedData)) # sex matches up

## Match with short:
FrameShort <- read.csv(paste("../MeerkatOutput/",FileName,"/FramesShort.csv", sep=""))
#preallocate columns:
FrameShort$PredictSex <- "NA"
FrameShort$Probability <- "NA"
FrameShort$ActualSex <- "NA"
UnqEvents <- unique(CombinedData$Event) # only take events that are present (wont happen if this is analyzing not analyzed data)
#calculate most probabilities for male/female
for(i in 1:length(UnqEvents)){
  sub <- subset(CombinedData, CombinedData$Event==UnqEvents[i])
  
  FemProb <- sum(sub$X1)/nrow(sub)
  MaleProb <- sum(sub$X2)/nrow(sub)
  
  if(isTRUE(FemProb > MaleProb)){
    #If female probability higher
    FrameShort$PredictSex[UnqEvents[i]] <- "F"
    FrameShort$Probability[UnqEvents[i]] <- FemProb
  }else{
    #if male probability higher
    FrameShort$PredictSex[UnqEvents[i]] <- "M"
    FrameShort$Probability[UnqEvents[i]] <- MaleProb
  }
  
  #just for now: put actual male/female
  if(isTRUE(sub$Actual[1]==1)){
    FrameShort$ActualSex[UnqEvents[i]] <- "F"
  }else{
    FrameShort$ActualSex[UnqEvents[i]] <- "M"
  }
}

FrameShort <-FrameShort[!FrameShort$PredictSex=="NA",]
FrameShort$Match <- FrameShort$PredictSex==FrameShort$ActualSex
print(paste("Accuracy of", sum(FrameShort$Match)/nrow(FrameShort)))

#Saving accuracies into csv:
OverallAccuracy <- sum(predictiondf$match)/nrow(predictiondf)
EventAccuracy <- sum(FrameShort$Match)/nrow(FrameShort)

Accuracies <- data.frame(FileName=FileName, FrameAccuracy = OverallAccuracy, EventAccuracy = EventAccuracy)

SumAccuracydf <- read.csv("../Models/ModelAccuracy.csv")
#subset to work around R adding column X:
SumAccuracydf <-SumAccuracydf[names(SumAccuracydf) %in% c("FileName","FrameAccuracy","EventAccuracy")]

if(SumAccuracydf$FileName %in% FileName){
  #If this file already exists in the dataframe
  SumAccuracydf[SumAccuracydf$FileName==FileName,] <- Accuracies[1,]
}else{
  #File havent been evaluated before
  SumAccuracydf <- rbind(SumAccuracydf,Accuracies)
}

write.csv(SumAccuracydf, file="../Models/ModelAccuracy.csv")


