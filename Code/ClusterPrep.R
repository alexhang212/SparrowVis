# Run and process all files to prepare for training CNN on HPC cluster
rm(list=ls())
library(keras)

source("ProcessFrameInfo.R")
source("GenerateTraining.R")
source("ProcessImages.R")

# Files <- list.files("../Data/Frames")
# Files <- Files[1:10]
Files <- "VO0056_VP7_W11_20150521"

for(i in 1:length(Files)){
#browser()
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
