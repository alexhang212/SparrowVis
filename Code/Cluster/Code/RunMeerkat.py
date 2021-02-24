#!/usr/bin/env python
"""Runs deep meerkat on cluster"""

import subprocess
import os 

#set directory:
os.chdir("/rds/general/user/hhc4317/home/SparrowVis/Code")

#get file names in Input directory
FileName = []
for root, dirs, files in os.walk("../MeerkatInput/", topdown=False):
    FileName += files

num = os.getenv("PBS_ARRAY_INDEX")#get index from cluster
print(num)
type(num)
video = FileName[num-1] #get video name, -1 because cluster returns 1-N codes

#run meerkat:
print("Running meerkat on:"+video)
subprocess.call(["python","../DeepMeerkat/DeepMeerkat/Meerkat.py", "--input","../MeerkatInput/{vid}".format(vid=video), "--path_to_model", "../DeepMeerkat/DeepMeerkat/model/", "--output", "../MeerkatOutput"])
print("Meerkat Finish Running")
