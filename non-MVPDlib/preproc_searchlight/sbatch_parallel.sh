#!/bin/bash
#SBATCH --job-name=EIB_preproc_parallel
#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=30
#SBATCH --mem-per-cpu=15360
#SBATCH --mail-user=daeda@mit.edu --mail-type=ALL
#SBATCH --output=../sbatchrunEIB_stdout_%j.txt
#SBATCH --error=../sbatchrunEIB_stderr_%j.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/gablab/u/daeda/analyses/EIB/preproctoolsspm

chmod +x sbatch_single.sh
mpiexec -n 30 ./sbatch_single.sh
