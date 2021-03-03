# script to load all the packages needed

library(keras)
#install_keras()
library(magick)
library(tidyverse)
library(abind)
library(readxl)
library(DescTools)

# FileName <- "VO0006_VP7_LM40_20150501"
# load(paste("../Arrays/",FileName,"_Array.rda",sep=""))
# load(paste("../Arrays/",FileName,"_ImageID.rda",sep=""))

#Load trained CNN model: 
CNN <- load_model_hdf5("../Models/TrainedCNN100-10")
ls()
# CNN %>% evaluate(ImageVal,ImageID)