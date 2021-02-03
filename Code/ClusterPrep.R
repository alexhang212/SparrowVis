# Run and process all files to prepare for training CNN on HPC cluster
rm(list=ls())
library(keras)

source("ProcessFrameInfo.R")
source("GenerateTraining.R")
source("ProcessImages.R")

Files <- c()
for(i in 1:length(Files)){
FileName <- Files[i]
  
VidCode <- strsplit(FileName,"_")[[1]][1]
Process_framecsv(FileName)
CodefrmExcel(FileName,VidCode, Year = "2015")

data <- read.csv(paste("../Data/Frames/",FileName,"/","FramesLongCoded.csv", sep=""))
data <- na.omit(data,data$Sex)

ProcessImage(FileName, data)
ImageID <- data$Sex
save(ImageID, file=paste("../Data/Arrays/",FileName,"_ImageID.rda", sep=""))
}


#Building CNN structure and saving it
imagescale <- 4
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

CNN %>% save_model_hdf5("../Data/Arrays/EmptyCNN")
