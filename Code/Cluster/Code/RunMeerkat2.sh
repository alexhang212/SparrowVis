#!/bin/bash
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=2:mem=1gb

module load anaconda3/personal
source activate SparrowVis

echo "Python is about to run"
python RunMeerkat.py
echo "Python is finished running"

#end of file
