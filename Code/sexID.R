#Building CNN to identify sexes
rm(list=ls())
library(imager)
set.seed(1)

imagescale <- 4

#only reading in files for 1 video
data <- read.csv("../Data/VT0115_S1_VP7_20190607/VT0115_S1_VP7_20190607_MeerkatManual.csv")

data <- data[-which(data$Sex==""),] # removed rows without male/female
data <- data[-which(data$Events=="Around"), ]


#loading all images for training:
ImageVal <- array(data=NA, dim=c(nrow(data),1280/imagescale,720/imagescale,3))

for(i in 1:nrow(data)){
  Framenum <- data[i,1]
  image <- load.image(paste("../Data/VT0115_S1_VP7_20190607/",Framenum,".jpg", sep=""))
  resizeimg <- resize(image,size_x = 1280/imagescale, 720/imagescale,1,3)
  resizeimgdrop <- drop(resizeimg) # drops the dimension with a single matrix
  ImageVal[i,,,] <- resizeimgdrop
}

ImageID <- as.integer(as.character(factor(data$Sex, levels=c("F","M"), labels=c(0,1)))) # vector for male female
#F is 0, M is 1

#CNN:
library(keras)

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
trainingIndex <- sample(nrow(data),nrow(data)/2)
training_x <- ImageVal[trainingIndex,,,]
training_y <- ImageID[trainingIndex]
test_x <- ImageVal[-trainingIndex,,,]
test_y <- ImageID[-trainingIndex]

CNN %>% fit(training_x,training_y, epochs = 100)

CNN %>% evaluate(test_x,test_y)
predictions <- predict(CNN,test_x)
table(apply(predictions,1,which.max), test_y)

#save model
CNN %>% save_model_tf("../Data/SexModel")


#for all frames:
predictions <- predict(CNN,ImageVal)
table(apply(predictions,1,which.max), ImageID)
