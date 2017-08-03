#!/bin/bash

file_num=sbatch_newMvpc_preproc_sub$(printf "%03d" $(($OMPI_COMM_WORLD_RANK + 1)))
matlab -nodisplay -nosplash -singleCompThread -r "$file_num"
exit

