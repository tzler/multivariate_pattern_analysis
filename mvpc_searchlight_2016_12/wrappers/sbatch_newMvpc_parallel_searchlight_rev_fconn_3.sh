#!/bin/bash
#SBATCH --job-name=mvpc_sl_revfconn
#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=1
#SBATCH --mem-per-cpu=16000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=anzellot@mit.edu --mail-type=ALL
#SBATCH --output=../sbatch_mvpc_sl_revfconn_stdout_3.txt
#SBATCH --error=../sbatch_mvpc_sl_revfconn_stderr_3.txt

module add openmpi/gcc/64/1.8.1
module add mit/matlab/2015a
cd /mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/wrappers

chmod +x sbatch_newMvpc_single_searchlight_rev_fconn_3.sh
mpiexec -n 1 ./sbatch_newMvpc_single_searchlight_rev_fconn_3.sh