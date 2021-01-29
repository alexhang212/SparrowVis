#Building CNN to identify sexes
rm(list=ls())
library(imager)
library(keras)
library(plyr)
set.seed(1)

imagescale <- 4
FileName <- "VT0115_S1_VP7_20190607"

#####Reading in Data#####

###Reading in new files:###
newdata <- read.csv(paste("../Data/Frames/",FileName,"/",FileName,"_MeerkatManual.csv", sep=""))
newdata$FileName <- FileName

data <- rbind.fill(newdata,data)

data <- data[-which(data$Sex==""),] # removed rows without male/female
data <- data[-which(data$Sex=="MF"),] # removed rows without male/female
#data <- data[-which(data$Events=="Around"), ]
write.csv(data,file="../Data/UpdatedTrainingFramesinfo.csv")


###Reading in Frames####
data <- read.csv("../Data/UpdatedTrainingFramesinfo.csv")
#loading all images for training:
ImageVal <- array(data=NA, dim=c(nrow(data),1280/imagescale,720/imagescale,3))

for(i in 1:nrow(data)){
  Framenum <- data$Frame[i]
  image <- load.image(paste("../Data/Frames/",data$FileName[i],"/",Framenum,".jpg", sep=""))
  resizeimg <- resize(image,size_x = 1280/imagescale, 720/imagescale,1,3)
  resizeimgdrop <- drop(resizeimg) # drops the dimension with a single matrix
  ImageVal[i,,,] <- resizeimgdrop
}

ImageID <- as.integer(as.character(factor(data$Sex, levels=c("F","M"), labels=c(0,1)))) # vector for male female
#F is 0, M is 1


#####Training New CNN Model#####
CNN <- keras_model_sequential()

CNN %>% layer_conv_2d(filters=30, kernel_size=c(4,4), activation = 'relu',
                      input_shape=c(1280/imagescale,720/imagescale,3), data_format="channels_last") %>%
  layer_max_pooling_2d(pool_size = c(3,3)) %>%
  layer_flatten() %>%
  layer_dense(units=30, activation = 'relu')%>%
  #layer_dense(units=15, activation='relu')%>%
  #layer_dropout(rate=0.25) %>%
  layer_dense(units=2, activation='softmax')%>%
  compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=c('accuracy')
  )

#Setting training data: half training, half test
#cutting dataset by a quarter, reduce size
quarter <- sample(nrow(data), nrow(data)/4)
data <- data[-quarter,]

trainingIndex <- sample(nrow(data),nrow(data)/2)
training_x <- ImageVal[trainingIndex,,,]
training_y <- ImageID[trainingIndex]
test_x <- ImageVal[-trainingIndex,,,]
test_y <- ImageID[-trainingIndex]

CNN %>% fit(training_x,training_y, epochs = 75)

CNN %>% evaluate(test_x,test_y)
predictions <- predict(CNN,test_x)
table(apply(predictions,1,which.max), test_y)

#save model
CNN %>% save_model_hdf5("../Data/Models/CNN2_100eq")


#for all frames:
predictions <- predict(CNN,ImageVal)
table(apply(predictions,1,which.max), ImageID)



##### Retrain CNN#####
#Fitting existing model
testCNN <- load_model_hdf5("../Data/Models/CNN2_100eq")
testCNN %>% evaluate(ImageVal,ImageID)
predictions <- predict(testCNN,ImageVal)
table(apply(predictions,1,which.max), ImageID)



#Setting up training data
trainingIndex <- sample(nrow(data),nrow(data)/2)
training_x <- ImageVal[trainingIndex,,,]
training_y <- ImageID[trainingIndex]
test_x <- ImageVal[-trainingIndex,,,]
test_y <- ImageID[-trainingIndex]


# Retraining model:
newCNN <- keras_model_sequential()%>%
  CNN1_85()%>%
  compile(optimizer='adam',
          loss='sparse_categorical_crossentropy',
          metrics=c('accuracy'))


newCNN %>% fit(training_x,training_y, epochs = 75)
testCNN %>% evaluate(test_x,test_y)
predictions <- predict(newCNN,test_x)
table(apply(predictions,1,which.max), test_y)

CNN1_85 %>% save_model_hdf5("../Data/Models/CNN2_88")



##### Verify Model: Fitting new data #####
#creating predict df, match back to results
testCNN <- load_model_hdf5("../Data/Models/CNN2_100eq")
testCNN %>% evaluate(ImageVal,ImageID)
predictions <- predict(testCNN,ImageVal)
table(apply(predictions,1,which.max), ImageID)

predictiondf <- data.frame(predictions)
predictiondf$Predict<- apply(predictions,1,which.max)
predictiondf$Actual <- ImageID+1
predictiondf$match <- predictiondf$Predict==predictiondf$Actual
predictiondf$Frame <- data$Frame

FrameLong <- read.csv(paste("../Data/Frames/",FileName,"/FramesLong.csv", sep=""))
predictiondf2 <- merge(predictiondf, FrameLong[,names(FrameLong)%in%c("Frame","Event")], by="Frame")
predictiondf2 <- predictiondf2[!duplicated(predictiondf2$Frame),] # remove duplicates, some frames have multiple rows
predictiondf2 <- na.omit(predictiondf2) # remove frames that are not part of events

FrameShort <- read.csv(paste("../Data/Frames/",FileName,"/FramesShort.csv", sep=""))
#preallocate columns:
FrameShort$PredictSex <- "NA"
FrameShort$Probability <- "NA"
FrameShort$ActualSex <- "NA"
#calculate most probabilities for male/female
for(i in 1:max(predictiondf2$Event)){
  sub <- subset(predictiondf2, predictiondf2$Event==i)
  FemProb <- sum(sub$X1)/nrow(sub)
  MaleProb <- sum(sub$X2)/nrow(sub)
  
  if(isTRUE(FemProb > MaleProb)){
    #If female probability higher
    FrameShort$PredictSex[i] <- "F"
    FrameShort$Probability[i] <- FemProb
    }else{
    #if male probability higher
    FrameShort$PredictSex[i] <- "M"
    FrameShort$Probability[i] <- MaleProb
    }
  
  #just for now: put actual male/female
  if(isTRUE(sub$Actual[1]==1)){
    FrameShort$ActualSex[i] <- "F"
  }else{
    FrameShort$ActualSex[i] <- "M"
  }
  
}

#calculate accuracy:
FrameShort$Match <- FrameShort$PredictSex==FrameShort$ActualSex
print(paste("Accuracy of", sum(FrameShort$Match)/nrow(FrameShort)))
write.csv(paste("../Data/Frames/",FileName,"/CNNAccuracy.csv", sep=""))
