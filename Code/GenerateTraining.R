#Takes long/ short format and compares with excel file to generate training/ verification files
rm(list=ls())

FileName <- "VT0115_S1_VP7_20190607"

Short <- read.csv(paste("../Data/Frames/",FileName,"/FramesShort.csv", sep=""))

