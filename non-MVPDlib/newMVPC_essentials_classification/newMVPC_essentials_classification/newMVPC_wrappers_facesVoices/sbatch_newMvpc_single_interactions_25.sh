#!/bin/bash

file_num=sbatch_newMvpc_interactions_$(printf "%03d" $(($OMPI_COMM_WORLD_RANK + 1 + 120)))
matlab -nodisplay -nosplash -singleCompThread -r "$file_num"
exit

