#read in images, crop it and save array
rm(list=ls())
library(imager)
library(magick)

FileName <- "VT0115_S1_VP7_20190607"

data <- read.csv(paste("../Data/Frames/",FileName,"/","FramesLong.csv", sep=""))


#Testing
Framenum <- data$Frame[i]
image <- image_read(paste("../Data/Frames/",data$FileName[i],"/",Framenum,".jpg", sep=""))
cropimage <- image_crop(image, "251x436+832+273")
plot(cropimage)

resizeimg <- resize(image,size_x = 1280/imagescale, 720/imagescale,1,3)
resizeimgdrop <- drop(resizeimg) # drops the dimension with a single matrix
ImageVal[i,,,] <- resizeimgdrop
####


ImageVal <- array(data=NA, dim=c(nrow(data),1280/imagescale,720/imagescale,3))

for(i in 1:nrow(data)){
  Framenum <- data$Frame[i]
  image <- load.image(paste("../Data/Frames/",data$FileName[i],"/",Framenum,".jpg", sep=""))
  resizeimg <- resize(image,size_x = 1280/imagescale, 720/imagescale,1,3)
  resizeimgdrop <- drop(resizeimg) # drops the dimension with a single matrix
  ImageVal[i,,,] <- resizeimgdrop
}

