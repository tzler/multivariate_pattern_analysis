#!/bin/bash
#SBATCH --job-name=LANGISC_preproc --time=2-00:00:00
#SBATCH --mail-user=stefano.anzellotti@gmail.com --mail-type=ALL
#SBATCH --mem 10GB
#SBATCH --output=run.stdout
#SBATCH --error=run.stderr

module add mit/matlab/2014a
cd /mindhive/saxelab3/anzellotti/LANG_ISC/preprocessing_ISC
matlab -nodisplay -singleCompThread -r "script001, exit"
