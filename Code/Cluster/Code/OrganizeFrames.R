#!/usr/bin/env Rscript
# Runs all scripts to generate datafiles of frames for one video
rm(list=ls())

library(keras)
install_keras()
setwd("/rds/general/user/hhc4317/home/SparrowVis/Code/")


source("ProcessFrameInfo.R")
source("GenerateTraining.R")
source("ProcessImages.R")
source("ValidateModel.R")

Files <- list.files("../MeerkatOutput/")

#tried doing the argument thing, to take in argument and analyze vids 1 by 1:
# Args <- commandArgs(trailingOnly = TRUE)
# #condition to test if argument is good:
# ifelse(length(Args==2), print("all good!"), print("error! argument length is not 2!"))
# FileName <- Args[1]
# Year <- Args[2]

for(i in 1:length(Files)){
  #browser()
  FileName <- Files[i]
  
  VidCode <- strsplit(FileName,"_")[[1]][1]
  Process_framecsv(FileName)
  CodefrmExcel(FileName,VidCode, Year = "2015")
  
  data <- read.csv(paste("../MeerkatOutput/",FileName,"/","FramesLongCoded.csv", sep=""))
  data <- na.omit(data,data$Sex)
  
  ProcessImage(FileName, data)
  ImageID <- data$Sex
  save(ImageID, file=paste("../Arrays/",FileName,"_ImageID.rda", sep=""))
  
  #Validate model:
  ValidateModel(FileName,"TrainedCNN100-10")
}
