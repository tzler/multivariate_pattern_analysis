
%% Multivariate analyses - Revision
nSubjects = 11;
scriptDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/wrappers';
mvpcDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/';

 parameters.slurm.name = 'mvpc_sl_fvrev';
 parameters.slurm.cores_per_node = 4; 
 parameters.slurm.cpus_per_task = 1; 
 parameters.slurm.time = 5; % time in days

 parameters.slurm.mem_per_cpu = 16000;
 parameters.slurm.email = 'anzellot@mit.edu';

newMvpc_scriptGenerator_searchlight_rev_fv(nSubjects,scriptDir,mvpcDir,parameters);
 
 %% Submit to queue
 
system('cd /mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/wrappers');
 for iJob = 1:3
 system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_rev_fv_%d.sh',iJob));
 end

 clear all
