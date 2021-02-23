#!/bin/bash
#PBS -l walltime=20:00:00
#PBS -l select=1:ncpus=2:mem=10gb
module load anaconda3/personal
source activate SparrowVis
echo "Python is about to run"
python $HOME/SparrowVis/Code/RunPipeline.py
echo "Python is finished running"

#end of file
