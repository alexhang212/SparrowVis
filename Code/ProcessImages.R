#read in images, crop it and save array
rm(list=ls())
library(imager)
library(magick)

FileName <- "VT0139_S1_VP11_20190611"
data <- read.csv(paste("../Data/Frames/",FileName,"/","FramesLong.csv", sep=""))

imagescale <- 4
ImageVal <- array(data=NA, dim=c(nrow(data),1280/imagescale,720/imagescale,3))

for(i in 1:nrow(data)){
  Framenum <- data$Frame[i]
  image <- image_read(paste("../Data/Frames/",data$FileName[i],"/",Framenum,".jpg", sep=""))
  
  #crop image:
  cropimage <- image_crop(image,paste(data$w[i]*1.5,"x",data$h[i]*1.5,"+",data$x[i],"+",data$y[i], sep=""))
  
  #add black border around cropped image#
  #get desired height and width:
  ht <- 720/imagescale
  wt <- 1280/imagescale
  cropimagedim <- dim(cropimage[[1]])
  
  #scale image according to size of crop
  if(isTRUE(cropimagedim[3]>cropimagedim[2])){#if height of image > width
  if(cropimagedim[3]>ht) {cropscale <- image_scale(cropimage, paste("x",ht, sep=""))}else{
    cropscale<- cropimage} #scale to height, only if the height is larger than desired height
  }else{
  if(cropimagedim[2]>wt){cropscale <- image_scale(cropimage, paste(wt, sep=""))}else{
    cropscale <- cropimage} #scale to width
  }
  
  scaledimagedim <- dim(cropscale[[1]]) #get dimension of scaled image
  #add border:
  cropborder <- image_border(cropscale,"black", geometry = paste((wt-scaledimagedim[2])/2,"x",(ht-scaledimagedim[3])/2, sep=""))
  #sometimes, pixel values are not perfect, need to rescale again
  
  finalimage <- image_scale(cropborder, paste(wt,"x",ht,"!",sep=""))
  # browser()
  plot(finalimage)
  
  #save to array:
  ImageVal[i,,,] <- as.integer(finalimage[[1]])/255
}

save(ImageVal, file=paste("../Data/Arrays/",FileName,"_Array.rda", sep=""))
