#!/bin/bash
#SBATCH --job-name=kids_MVPC
#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=20
#SBATCH --mem-per-cpu=2000
#SBATCH --mail-user=bonnen@mit.edu --mail-type=ALL
#SBATCH --output=/mindhive/saxelab2/tyler/mvpc/kids/processing/sbatch_kids_MVPC_stdout_%j.txt
#SBATCH --error=/mindhive/saxelab2/tyler/mvpc/kids/processing/sbatch_kids_MVPC_stderr_%j.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/saxelab2/tyler/mvpc/kids/setup/hybridsbatch/mvpc_123PM_2016_0726

chmod +x sbatch_single.sh
mpiexec -n 1 ./sbatch_single.sh
