#!/bin/bash
#PBS -l walltime=00:15:00
#PBS -l select=1:ncpus=2:mem=10gb
module load anaconda3/personal
source activate RKerasEnv


echo "R is about to run"
R --vanilla < $HOME/SparrowVis/Code/Test.R
echo "R is finished running"

#end of file
