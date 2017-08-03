#!/bin/bash
#SBATCH --job-name=fv_indPCA --time=2-00:00:00
#SBATCH --mail-user=stefano.anzellotti@gmail.com --mail-type=ALL
#SBATCH --mem 10GB
#SBATCH --output=run.stdout
#SBATCH --error=run.stderr

module add mit/matlab/2014a
cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices/
matlab -nodisplay -singleCompThread -r "sbatch_newMvpc_interactions_138, exit"
