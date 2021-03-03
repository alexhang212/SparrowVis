#!/bin/bash
#PBS -l walltime=05:00:00
#PBS -l select=1:ncpus=2:mem=10gb

module load anaconda3/personal
source activate Renv

echo "R is about to run"
R --vanilla < $HOME/SparrowVis/Code/OrganizeFrames.R
echo "R is finished running"


#end of file
