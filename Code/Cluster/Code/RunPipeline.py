#!/usr/bin/env python
"""~Runs deep meerkat and validation workflow on cluster"""

import subprocess
import os 

#set directory:
os.chdir("/rds/general/user/hhc4317/home/SparrowVis/Code")

#get file names in Input directory
FileName = []
for root, dirs, files in os.walk("../MeerkatInput/", topdown=False):
    FileName += files

for i in FileName:
    #for every video detected in Meerkat input:
    subprocess.call(["source", "activate","SparrowVis"])#activates sparrow vis virtual env

    #run meerkat:
    subprocess.call(["python","../DeepMeerkat/DeepMeerkat/Meerkat.py", "--input","../MeerkatInput/{vid}".format(vid=i), "--path_to_model", "../DeepMeerkat/DeepMeerkat/model/", "--output", "../MeerkatOutput"])
    print("Meerkat Finish Running")
    VidName = i.split(".")[0] # stripping the .mp4 extension

    #leaving sparrowvis virtual env and using r-tensorflow
    subprocess.call(["conda","deactivate"])
    subprocess.call(["source", "activate","r-tensorflow"])


    print("running process frame R script for video" + i)
    #process the frames:
    subprocess.call(["Rscript", "--vanilla", "OrganizeFrames.R",VidName,"2015"])
   
    print("finish processing frames")

    #print("Start validate model for Video" + i)
    #Validating the model:
    subprocess.call(["Rscript", "--vanilla", "ValidateModel.R", VidName])
    print("finish validating model")

    subprocess.call(["conda","deactivate"])

