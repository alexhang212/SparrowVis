#!/bin/bash
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=1:mem=10gb
module load anaconda3/personal
echo "R is about to run"
R --vanilla < $HOME/TrainCNN_Cluster.R
mv TrainedCNN* $HOME
echo "R is finished running"

#end of file
