 function MVPDroi_scriptGenerator_regionModels(nSubjects,outputPaths,mvpdDir,parameters)
 
 
% This function generates scripts to parallelize the region models in
% MVPDroi.
productsDir = outputPaths.products;
cfgPath = outputPaths.cfgPath;
 
 %% Shell scripts
 cd(productsDir);
 for iSubject = 1:nSubjects
     % open file
     fid = fopen(sprintf('sbatch_MVPDroi_rModels_%02d.sh',iSubject),'wt');   
     fprintf(fid,'#!/bin/bash\n');
     % write slurm parameters
     fprintf(fid,'#SBATCH --job-name=%s\n', parameters.slurm.name);
     fprintf(fid,'#SBATCH --nodes=1 --cpus-per-task=1  --tasks-per-node=1\n');
     fprintf(fid,'#SBATCH --mem-per-cpu=%d\n', parameters.slurm.mem_per_cpu);
     fprintf(fid,'#SBATCH --mail-user=%s --mail-type=ALL\n', parameters.slurm.email);
     fprintf(fid,'#SBATCH --output=../sbatch_%s_stdout.txt\n', parameters.slurm.name);
     fprintf(fid,'#SBATCH --error=../sbatch_%s_stderr.txt\n', parameters.slurm.name);
     % add MATLAB module
     fprintf(fid,'module add mit/matlab/2015a\n');
     fprintf(fid,'cd %s\n',productsDir);
     fprintf(fid,'\n');
     % run MATLAB script
     fprintf(fid,['matlab -nodisplay -nosplash -singleCompThread -r sbatch_MVPDroi_rModels_mat_sub%02d\n',iSubject]);
     fprintf(fid,'exit\n');
     fprintf(fid,'\n');
     % close file
     fclose(fid);
 end
 
 %% MATLAB scripts
 cd(productsDir);
 for iSubject = 1:nSubjects
     % open file
     scriptName = sprintf('sbatch_MVPDroi_rModels_mat_sub%02d.m',iSubject);
     fid = fopen(scriptName,'wt');
     % write function launching analysis for one subject
     fprintf(fid,'function  %s',scriptName(1:end-2));
     fprintf(fid,'\n cd(''%s'')', mvpdDir);
     fprintf(fid,'\n MVPDroi_regionModels(''%s'',%d)',cfgPath,iSubject);
     % close file
     fclose(fid);
 end




