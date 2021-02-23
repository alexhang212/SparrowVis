#!/bin/bash
#PBS -l walltime=05:00:00
#PBS -l select=1:ncpus=2:mem=10gb

module load anaconda3/personal
source activate SparrowVis

cd $HOME/SparrowVis/Code/ #change directory

for entry in "../MeerkatInput"/*
do
echo $entry

vidnametemp=${entry%.*}
vidname=${vidnametemp##*/}
echo $vidname


echo "Meerkat is about to run"
python $HOME/SparrowVis/DeepMeerkat/DeepMeerkat/Meerkat.py --input $entry --path_to_model ../DeepMeerkat/DeepMeerkat/model/ --output ../MeerkatOutput
echo "Meerkat is finished running"

done
#end of file
