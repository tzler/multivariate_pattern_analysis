 function newMvpc_scriptGenerator_preproc(nSubjects,scriptDir,mvpcDir,parameters,cfgPath)

%% Parallel file

cd(scriptDir);
fid = fopen(sprintf('sbatch_newMvpc_parallel_preproc.sh'),'wt');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --job-name=%s\n', parameters.slurm.name);  % Project Name
fprintf(fid,'#SBATCH --nodes=%d --cpus-per-task=%d  --tasks-per-node=%d\n', parameters.slurm.nodes, parameters.slurm.cpus_per_task, parameters.slurm.task_per_node);
fprintf(fid,'#SBATCH --mem-per-cpu=%d\n', parameters.slurm.mem_per_cpu);
fprintf(fid,'#SBATCH --mail-user=%s --mail-type=ALL\n', parameters.slurm.email);
fprintf(fid,'#SBATCH --output=../sbatch_%s_stdout.txt\n', parameters.slurm.name);
fprintf(fid,'#SBATCH --error=../sbatch_%s_stderr.txt\n', parameters.slurm.name);
fprintf(fid,'\n');
fprintf(fid,'module add openmpi/gcc/64/1.8.1\n');
fprintf(fid,'module add mit/matlab/2015a\n');
fprintf(fid,'cd %s\n',scriptDir);
fprintf(fid,'\n');
fprintf(fid,'chmod +x sbatch_newMvpc_single_preproc.sh\n');
fprintf(fid,'mpiexec -n %d ./sbatch_newMvpc_single_preproc.sh',nSubjects);

fclose(fid);


%% Single file

cd(scriptDir);
fid = fopen('sbatch_newMvpc_single_preproc.sh','wt');
    
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n');
fprintf(fid,['file_num=sbatch_newMvpc_preproc_sub$(printf ' char(34) '%s' char(34) ' $(($OMPI_COMM_WORLD_RANK + 1)))\n'],'%03d');
fprintf(fid,['matlab -nodisplay -nosplash -singleCompThread -r ' char(34) '$file_num' char(34) '\n']);
fprintf(fid,'exit\n');
fprintf(fid,'\n');

fclose(fid);

%% MATLAB scripts

cd(scriptDir);
for iSubject = 1:nSubjects
    scriptName = sprintf('sbatch_newMvpc_preproc_sub%03d.m',iSubject);
    fid = fopen(scriptName,'wt');
    fprintf(fid,'function  %s',scriptName(1:end-2));
    fprintf(fid,'\n cd(''%s'')', mvpcDir);
    fprintf(fid,'\n newMvpc_preproc(''%s'',%d)',cfgPath,iSubject);
    fclose(fid);
end


