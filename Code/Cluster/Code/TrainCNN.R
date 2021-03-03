#Script to be ran in the cluster, train CNN
rm(list=ls())
graphics.off()
setwd("/rds/general/user/hhc4317/home/SparrowVis/Code/")
#iter <-as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

#!! Set working directory to be the folder with all files!!#
require(abind)
require(keras)
install_keras()

#load arrays:
Files <- list.files("../Arrays/")
ArrayNames <- Files[which(endsWith(Files, "Array.rda"))]
ImageIDNames <- Files[which(endsWith(Files,"ImageID.rda"))]
MainArray <- array(data=NA, dim=c(1,320,180,3))

#read arrays
for(i in 1:length(ArrayNames)){
  load(ArrayNames[i])
  MainArray <- abind(MainArray,ImageVal,along=1)
  
}

MainArray <- MainArray[-1,,,] #Remove first array, it is all NAs from preallocation

#read ImageIDs
ImageIDVect <- c()
for(i in 1:length(ImageIDNames)){
  load(ImageIDNames[i])
  ImageIDVect <- c(ImageIDVect, ImageID)
}

#Testing stuff to make sure stuff works:
if(dim(MainArray)[1]==length(ImageIDVect)){
  print("ALL GOOD!!! WOOP WOOP")
}else{
  stop("Array length and IDvector doesnt match")
}

#subset 5% of data to create training + validation





#check if all NAs are removed
yo <- apply(MainArray,1,function(x) sum(is.na(x)))
if(sum(yo)>0){stop("There are NAs in arrays")}else{print("all good, no NAs")}

###Train CNN###
#CNN <- load_model_hdf5("EmptyCNN")
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


#fitting the model: with augmentation:
# for(i in 1:100){
# print(paste("epoch:",i))
# Augmented <- MainArray + rnorm(length(MainArray), sd=0.01)
# CNN %>% fit(Augmented,ImageIDVect, epochs = 1)
# }

#fitting Model: without augmentation
CNN %>% fit(MainArray,ImageIDVect, epochs = 100)

##

print("finished training, saving model")
CNN %>% save_model_hdf5("TrainedCNN")
print("Finished Saving!")


#Try fit the models#
load(ArrayNames[1])
load(ImageIDNames[1])
print(ArrayNames[1])
CNN %>% evaluate(ImageVal,ImageID)
predictions <- predict(CNN, ImageVal)
save(predictions, file="Prediction.rda")
