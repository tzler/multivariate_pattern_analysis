
%% Multivariate analyses - Revision
nSubjects = 10;
scriptDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/MVPDtests/searchlight/products';
mkdir(scriptDir);
mvpcDir = '/mindhive/saxelab3/anzellotti/github_repos/mvpd/';

 parameters.slurm.name = 'mvpc_sl_rev';
 parameters.slurm.cores_per_node = 4; 
 parameters.slurm.cpus_per_task = 1; 
 parameters.slurm.time = 5; % time in days
 parameters.slurm.mem_per_cpu = 16000;
 parameters.slurm.email = 'anzellot@mit.edu';

 nAnalyses = 3;
 
MVPDsearchlight_scriptGenerator(nSubjects,nAnalyses,scriptDir,mvpcDir,parameters);
 
 %% Submit to queue
 
system(sprintf('cd %s',scriptDir));
 for iJob = 1:3
 system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_rev_%d.sh',iJob));
 end


