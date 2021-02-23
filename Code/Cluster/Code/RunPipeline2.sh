#!/bin/bash
#PBS -l walltime=05:00:00
#PBS -l select=1:ncpus=2:mem=10gb

module load anaconda3/personal

cd $HOME/SparrowVis/Code/ #change directory

for entry in "../MeerkatInput"/*
do
echo $entry

vidnametemp=${entry%.*}
vidname=${vidnametemp##*/}
echo $vidname

source activate SparrowVis
echo "Meerkat is about to run"
python $HOME/SparrowVis/DeepMeerkat/DeepMeerkat/Meerkat.py --input $entry --path_to_model ../DeepMeerkat/DeepMeerkat/model/ --output ../MeerkatOutput
echo "Meerkat is finished running"


source activate r-tensorflow
echo "R scripts now run"
Rscript --vanilla OrganizeFrames.R $vidname 2015

Rscript --vanilla ValidateModel.R $vidname


echo "R scripts finish running"
conda deactivate

done
#end of file
