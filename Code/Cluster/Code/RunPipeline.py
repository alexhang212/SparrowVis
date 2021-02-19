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

    #run meerkat:
    subprocess.call(["python","../DeepMeerkat/DeepMeerkat/Meerkat.py", "--input","../MeerkatInput/{vid}".format(vid=i), "--path_to_model", "../DeepMeerkat/DeepMeerkat/model/", "--output", "../MeerkatOutput"])

    VidName = i.split(".")[0] # stripping the .mp4 extension

    #process the frames:
    subprocess.call(["Rscript", "--vanilla", "OrganizeFrames.R",VidName,"2015"])

    #Validating the model:
    subprocess.call(["Rscript", "--vanilla", "ValidateModel.R", VidName])



