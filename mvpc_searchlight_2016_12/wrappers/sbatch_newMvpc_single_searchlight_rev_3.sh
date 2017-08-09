#!/bin/bash

file_num=sbatch_newMvpc_searchlight_rev_$(printf "%03d" $(($OMPI_COMM_WORLD_RANK + 1 + 8)))
matlab -nodisplay -nosplash -singleCompThread -r "$file_num"
exit

