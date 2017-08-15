#!/bin/bash
#SBATCH --job-name=newMvpc_inter_facesVoices
#SBATCH --nodes=3 --overcommit
#SBATCH --mem-per-cpu=10240
#SBATCH --mail-user=anzellot@mit.edu --mail-type=ALL
#SBATCH --output=../sbatch_newMvpc_inter_facesVoices_stdout.txt
#SBATCH --error=../sbatch_newMvpc_inter_facesVoices_stderr.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices

chmod +x sbatch_newMvpc_single_interactions.sh
mpiexec -n 253 ./sbatch_newMvpc_single_interactions.sh