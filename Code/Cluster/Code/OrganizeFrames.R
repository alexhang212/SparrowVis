#!/usr/bin/env Rscript
# Runs all scripts to generate datafiles of frames for one video
rm(list=ls())
source("ProcessFrameInfo.R")
source("GenerateTraining.R")
source("ProcessImages.R")

# Files <- list.files("../Data/Frames")
# Files <- Files[1:10]
Args <- commandArgs(trailingOnly = TRUE)
#condition to test if argument is good:
ifelse(length(Args==2), print("all good!"), print("error! argument length is not 2!"))
FileName <- Args[1]
Year <- Args[2]


VidCode <- strsplit(FileName,"_")[[1]][1]
Process_framecsv(FileName)
CodefrmExcel(FileName,VidCode, Year)

#Read coded dataframes and remove rows without sex
data <- read.csv(paste("../MeerkatOutput/",FileName,"/","FramesLongCoded.csv", sep=""))
data <- na.omit(data,data$Sex)


ProcessImage(FileName, data) # creates r arrays of pixel data
ImageID <- data$Sex
save(ImageID, file=paste("../Arrays/",FileName,"_ImageID.rda", sep="")) #validation data
