function sbatch_genScripts(Cfg_mvpcRoi, savePath, slurm)

nSubjects = numel(Cfg_mvpcRoi.dataInfo.subjects);
cd(savePath);

for iSubject = 1:nSubjects
	fid = fopen(sprintf('sbatch_run%03d.m',iSubject),'wt');
    fprintf(fid,'\n');
    fprintf(fid,'load(''%s'')\n',Cfg_mvpcRoi.outputPaths.Cfg_variable);

%% Use this code if not passing Cfg_mvpcRoi.mat path:
% 	fprintf(fid,'cd(''/mindhive/gablab/users/daeda/analyses/EIB/results'');\n');
% 	fprintf(fid,'resultsDirs = dir(''mvpc_*'');\n');
% 	fprintf(fid,'cd(resultsDirs(end).name);\n');
% 	fprintf(fid,'%% load allsubjects Cfg\n');
% 	fprintf(fid,'load(''Cfg_mvpcRoi.mat'');\n');
% fprintf(fid,'\n');
% 	fprintf(fid,'[~, resultsDir{1}, ~] = fileparts(pwd);\n');
% 	fprintf(fid,'[~, resultsDir{2}, ~] = fileparts(Cfg_mvpcRoi.outputPaths.results);\n');
% fprintf(fid,'\n');
% 	fprintf(fid,'if ~strcmp(resultsDir{1},resultsDir{2})\n');
% 	fprintf(fid,'	error(''Cfg load error'');\n');
% 	fprintf(fid,'end\n');

	fprintf(fid,'\n');
	fprintf(fid,'%% Load libraries\n');
	fprintf(fid,'libs = fieldnames(Cfg_mvpcRoi.libraryPaths);\n');
	fprintf(fid,'for dependency = 1:numel(libs)\n');
	fprintf(fid,'    addpath(genpath( Cfg_mvpcRoi.libraryPaths.(libs{dependency}) ));\n');
	fprintf(fid,'end\n');
	fprintf(fid,'rmpath(genpath(fullfile(Cfg_mvpcRoi.libraryPaths.spm12,''external'')));\n');
	fprintf(fid,'rmpath(genpath(''/software/pkg/matlab/matlab-2015b/toolbox/stats/eml''));\n');
fprintf(fid,'\n');
	fprintf(fid,'%% Calculate connectivity between the rois\n');
	fprintf(fid,'iSubject = %d;\n',iSubject);
	fprintf(fid,'global mvpc_iSubject\n');
	fprintf(fid,'mvpc_iSubject = iSubject;\n');
fprintf(fid,'\n');
	fprintf(fid,'results = mvpc_rois_singleSub(Cfg_mvpcRoi.dataInfo.subjects(iSubject),Cfg_mvpcRoi.compcorr.nPCs,Cfg_mvpcRoi.regionModels,Cfg_mvpcRoi.interactionModels);\n');
	fprintf(fid,'fprintf(''Finished connectivity calculations for subject %s'',iSubject);\n','%d\n');
fprintf(fid,'\n');
	fprintf(fid,'%% Save\n');
	fprintf(fid,'cd(Cfg_mvpcRoi.outputPaths.results);\n');
	fprintf(fid,'filename_persubject = sprintf(''results_subject%0.3d'');\n',iSubject);
	fprintf(fid,'subjectData = Cfg_mvpcRoi.dataInfo.subjects(iSubject);\n');
	fprintf(fid,'save(filename_persubject,''results'',''subjectData'')\n');
fprintf(fid,'\n');
%{
% MPI does not support recursive slum calls
fprintf(fid,'cd(''%s'');\n',fullfile(Cfg_mvpcRoi.outputPaths.results,'temp_nnet',sprintf('Sub%0.3d',iSubject),'batchscripts')); % cd('/mindhive/gablab/users/daeda/analyses/EIB/results/mvpc_736498/temp_nnet/Sub001/batchscripts'); 
fprintf(fid,'unix(''sbatch sbatch_nnet_parallel.sh'');\n');
fprintf(fid,'\n');
%}


    fclose(fid);
end


%%
fid = fopen(sprintf('sbatch_parallel.sh'),'wt');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --job-name=%s\n',slurm.name);  % Project Name
fprintf(fid,'#SBATCH --nodes=%d --cpus-per-task=%d  --tasks-per-node=20\n', slurm.nodes, slurm.cpus_per_task);
fprintf(fid,'#SBATCH --mem-per-cpu=%d\n',slurm.mem_per_cpu);
fprintf(fid,'#SBATCH --mail-user=%s --mail-type=ALL\n', slurm.email);
fprintf(fid,'#SBATCH --output=/mindhive/saxelab2/tyler/mvpc/kids/processing/sbatch_%s_stdout_%%j.txt\n',slurm.name);
fprintf(fid,'#SBATCH --error=/mindhive/saxelab2/tyler/mvpc/kids/processing/sbatch_%s_stderr_%%j.txt\n',slurm.name);
fprintf(fid,'\n');
fprintf(fid,'module add openmpi/gcc/64/1.8.1\n');
fprintf(fid,'module add mit/matlab/2015a\n');
fprintf(fid,'cd %s\n',savePath);
fprintf(fid,'\n');
fprintf(fid,'chmod +x sbatch_single.sh\n');
fprintf(fid,'mpiexec -n %d ./sbatch_single.sh\n',nSubjects);


fclose(fid);


%%
fid = fopen(sprintf('sbatch_single.sh'),'wt');
    
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,['file_num=sbatch_run$(printf ' char(34) '%s' char(34) ' $(($OMPI_COMM_WORLD_RANK + 1)))\n'],'%03d');
fprintf(fid,['matlab -nodisplay -nosplash -singleCompThread -r ' char(34) '$file_num' char(34) '\n']);
fprintf(fid,'exit\n');
fprintf(fid,'\n');
fclose(fid);

end











