function placeholder = sbatch_genScripts_nnet(parameters,data)

global mvpc_iSubject

nnetDir = fullfile(parameters.savePath,'temp_nnet');
subDirName = sprintf('Sub%0.3d',mvpc_iSubject);
subDir = fullfile(nnetDir,subDirName);
scriptDir = fullfile(subDir,'batchscripts');
mkdir(scriptDir);

% save data Cfg for subject
cd(subDir);
subFilename = sprintf('nnetdata%d.mat',mvpc_iSubject);
save(subFilename,'parameters','data');
Cfg_nnet = which(subFilename);

% move to directory in which to save nnet batch scripts for subject
cd(scriptDir);

nRois = length(data);

placeholder = zeros(nRois); % is this the best way to handel the feval output requirement?

%% Parallel file

fid = fopen(sprintf('sbatch_nnet_parallel.sh'),'wt');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --job-name=%s_%d\n', parameters.slurm.name,mvpc_iSubject);  % Project Name
fprintf(fid,'#SBATCH --nodes=%d --cpus-per-task=%d  --tasks-per-node=%d\n', parameters.slurm.nodes, parameters.slurm.cpus_per_task, parameters.slurm.task_per_node);
fprintf(fid,'#SBATCH --mem-per-cpu=%d\n', parameters.slurm.mem_per_cpu);
fprintf(fid,'#SBATCH --mail-user=%s --mail-type=ALL\n', parameters.slurm.email);
fprintf(fid,'#SBATCH --output=../sbatch_%s_stdout_%%j.txt\n', parameters.slurm.name);
fprintf(fid,'#SBATCH --error=../sbatch_%s_stderr_%%j.txt\n', parameters.slurm.name);
fprintf(fid,'\n');
fprintf(fid,'module add openmpi/gcc/64/1.8.1\n');
fprintf(fid,'module add mit/matlab/2015a\n');
fprintf(fid,'cd %s\n',scriptDir);
fprintf(fid,'\n');
fprintf(fid,'chmod +x sbatch_nnet_single.sh\n');
fprintf(fid,'mpiexec -n %d ./sbatch_nnet_single.sh',nRois);

fclose(fid);


%% Single file

fid = fopen(sprintf('sbatch_nnet_single.sh'),'wt');
    
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,['file_num=sbatch_nnet_run$(printf ' char(34) '%s' char(34) ' $(($OMPI_COMM_WORLD_RANK + 1)))\n'],'%03d');
fprintf(fid,['matlab -nodisplay -nosplash -singleCompThread -r ' char(34) '$file_num' char(34) '\n']);
fprintf(fid,'exit\n');
fprintf(fid,'\n');

fclose(fid);


%% NNET function

for iRoi = 1:nRois
    
    fid = fopen(sprintf('sbatch_nnet_run%03d.m',iRoi),'wt');

	fprintf(fid,'%% Subject number %d\n\n',mvpc_iSubject);
	fprintf(fid,'%% load libraries\n');

	libs = fieldnames(parameters.libraryPaths);
	for dependency = 1:numel(libs)
	    fprintf(fid,'addpath(''%s'');\n',parameters.libraryPaths.(libs{dependency}));
	end
	fprintf(fid,'addpath(genpath(''%s''));\n',parameters.libraryPaths.mvpc);
	
	fprintf(fid,'\n');
	fprintf(fid,'iRoi = %d;\n',iRoi);
	fprintf(fid,'nRois = %d;\n',nRois);
	fprintf(fid,'cd(''%s'');\n',subDir);

	fprintf(fid,'\n');

	fprintf(fid,'%% load file containing parameters, data\n');
	fprintf(fid,'load(''%s'');\n',Cfg_nnet);
	fprintf(fid,'\n');
	fprintf(fid,'for jRoi = 1:nRois\n');
	    fprintf(fid,'    [~, meanVarexpl_byComp{1,jRoi},~] = %s(parameters,data{jRoi},data{iRoi});\n',parameters.functionHandle);
	    fprintf(fid,'    connectivityMatrix(1,jRoi) = mean(meanVarexpl_byComp{1,jRoi});\n');
	fprintf(fid,'end\n');
	fprintf(fid,'\n');
	fprintf(fid,'connectivityMatrix(connectivityMatrix<0)=0;\n');
	fprintf(fid,'\n');
	fprintf(fid,'filename = sprintf(''nnetcpnt_Sub%0.3d_Roi%0.3d.mat'');\n',mvpc_iSubject,iRoi);
	fprintf(fid,'save(filename,''connectivityMatrix'');\n');

	fclose(fid);

end

%{

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois]
        [~, meanVarexpl_byComp{iRoi,jRoi},~] = mvpc_neuralNet_byComponent(parameters,data{jRoi},data{iRoi});
        connectivityMatrix(iRoi,jRoi) = mean(meanVarexpl_byComp{iRoi,jRoi});
    end
end

connectivityMatrix(connectivityMatrix<0)=0;

end

%}

end

