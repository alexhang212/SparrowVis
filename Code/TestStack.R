#Script to be ran in the cluster, train CNN
rm(list=ls())
graphics.off()
setwd("/rds/general/user/hhc4317/home/TrainCNN/")
#iter <-as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

#!! Set working directory to be the folder with all files!!#
require(abind)
require(keras)
install_keras()

#load arrays:
Files <- list.files()
ArrayNames <- Files[which(endsWith(Files, "Array.rda"))]
ImageIDNames <- Files[which(endsWith(Files,"ImageID.rda"))]
MainArray <- array(data=NA, dim=c(1,320,180,3))

add <- array(data=1000,dim=c(1,320,180,3))

#read arrays
for(i in 1:length(ArrayNames)){
  load(ArrayNames[i])
  MainArray <- abind(ImageVal,MainArray,along=1)
  MainArray <- abind(add,MainArray,along=1)
}

MainArray <- MainArray[-dim(MainArray)[1],,,] #Remove final array, it is all NAs from preallocation

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

#check if all NAs are removed
yo <- apply(MainArray,1,function(x) sum(is.na(x)))
if(sum(yo)>0){stop("There are NAs in arrays")}else{print("all good, no NAs")}

