#!/usr/bin/env python3
"""Crawls through hard disk to determine what videos we have"""

import subprocess
import os 
import csv
import pandas

#gets all file names from hard disk:
FileName = []
for root, dirs, files in os.walk("/media/alex2/Elements", topdown=False):
    FileName += files

#saving to csv:
df = pandas.DataFrame(data={"Files": FileName})
df.to_csv("../Data/HardDiskFile.csv", sep=',',index=False)

