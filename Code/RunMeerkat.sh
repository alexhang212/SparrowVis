#!/bin/bash

#to run meerkat:

#need to be in ./venvMeerkat virtual environment
#to log into virtual env:
#source ~/venvMeerkat/bin/activate

echo $1

#run meerkat:
python ~/Documents/DeepMeerkat/DeepMeerkat/Meerkat.py --input $1 --path_to_model ~/Documents/DeepMeerkat/DeepMeerkat/model/ --output ~/Documents/SparrowVis/Data/Frames


