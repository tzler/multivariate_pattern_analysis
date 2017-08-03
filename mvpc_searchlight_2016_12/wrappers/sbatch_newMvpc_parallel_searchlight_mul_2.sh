#!/bin/bash
#SBATCH --job-name=newMvpc_sl_facesView_mul
#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=4
#SBATCH --mem-per-cpu=16000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=anzellot@mit.edu --mail-type=ALL
#SBATCH --output=../sbatch_newMvpc_sl_facesView_mul_stdout_2.txt
#SBATCH --error=../sbatch_newMvpc_sl_facesView_mul_stderr_2.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers

chmod +x sbatch_newMvpc_single_searchlight_mul_2.sh
mpiexec -n 4 ./sbatch_newMvpc_single_searchlight_mul_2.sh