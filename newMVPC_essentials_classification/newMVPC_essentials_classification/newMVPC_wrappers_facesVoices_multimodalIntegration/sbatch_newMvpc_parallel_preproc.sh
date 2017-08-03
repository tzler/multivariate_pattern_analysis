#!/bin/bash
#SBATCH --job-name=mvpc_fvMI_r
#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=11
#SBATCH --mem-per-cpu=8192
#SBATCH --mail-user=anzellot@mit.edu --mail-type=ALL
#SBATCH --output=../sbatch_mvpc_fvMI_r_stdout.txt
#SBATCH --error=../sbatch_mvpc_fvMI_r_stderr.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices_multimodalIntegration

chmod +x sbatch_newMvpc_single_preproc.sh
mpiexec -n 11 ./sbatch_newMvpc_single_preproc.sh