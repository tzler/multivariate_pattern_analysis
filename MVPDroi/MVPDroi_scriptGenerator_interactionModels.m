function MVPDroi_scriptGenerator_interactionModels(nSubjects,nAnalyses,outputPaths,mvpcDir,parameters)

% This function generates scripts to parallelize the interaction models in
% MVPDroi.

productsDir = outputPaths.products;
cfgPath = outputPaths.cfgPath;
nNodes = ceil(nSubjects*nAnalyses/parameters.slurm.cores_per_node);

for iNode = 1:nNodes
    
    %% Shell parallel scripts
    
    nTasks = min(parameters.slurm.cores_per_node,nSubjects*nAnalyses-(iNode-1)*parameters.slurm.cores_per_node);
    
    cd(productsDir);
    fid = fopen(sprintf('sbatch_MVPDroi_parallel_iModel_%d.sh',iNode),'wt');
    
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'#SBATCH --job-name=%s\n', parameters.slurm.name);  % Project Name
    fprintf(fid,'#SBATCH --nodes=%d --cpus-per-task=%d  --tasks-per-node=%d\n', 1, parameters.slurm.cpus_per_task, nTasks);
    fprintf(fid,'#SBATCH --mem-per-cpu=%d\n', parameters.slurm.mem_per_cpu);
    fprintf(fid,'#SBATCH --mail-user=%s --mail-type=ALL\n', parameters.slurm.email);
    fprintf(fid,'#SBATCH --output=../sbatch_%s_stdout_%d.txt\n', parameters.slurm.name,iNode);
    fprintf(fid,'#SBATCH --error=../sbatch_%s_stderr_%d.txt\n', parameters.slurm.name,iNode);
    fprintf(fid,'\n');
    fprintf(fid,'module add openmpi/gcc/64/1.8.1\n');
    fprintf(fid,'module add mit/matlab/2015a\n');
    fprintf(fid,'cd %s\n',productsDir);
    fprintf(fid,'\n');
    fprintf(fid,'chmod +x sbatch_MVPDroi_single_iModel_%d.sh\n',iNode);
    fprintf(fid,'mpiexec -n %d ./sbatch_MVPDroi_single_iModel_%d.sh',nTasks,iNode);
    
    fclose(fid);
    
    
    %% Shell single scripts
    
    cd(productsDir);
    fid = fopen(sprintf('sbatch_MVPDroi_single_iModel_%d.sh',iNode),'wt');
    
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'\n');
    fprintf(fid,['file_num=sbatch_MVPDroi_iModel_$(printf ' char(34) '%s' char(34) ' $(($OMPI_COMM_WORLD_RANK + 1 + %d)))\n'],'%03d',(iNode-1)*parameters.slurm.cores_per_node);
    fprintf(fid,['matlab -nodisplay -nosplash -singleCompThread -r ' char(34) '$file_num' char(34) '\n']);
    fprintf(fid,'exit\n');
    fprintf(fid,'\n');
    
    fclose(fid);
    
end

%% MATLAB scripts

cd(productsDir);
for iSubject = 1:nSubjects
    for iAnalysis = 1:nAnalyses
        scriptName = sprintf('sbatch_MVPDroi_iModel_%03d.m',iAnalysis+nAnalyses*(iSubject-1));
        fid = fopen(scriptName,'wt');
        fprintf(fid,'function  %s',scriptName(1:end-2));
        fprintf(fid,'\n cd(''%s'')', mvpcDir);
        fprintf(fid,'\n MVPDroi_interactionModels(''%s'',%d,%d)',productsDir,iSubject,iAnalysis);
        fclose(fid);
    end
end


