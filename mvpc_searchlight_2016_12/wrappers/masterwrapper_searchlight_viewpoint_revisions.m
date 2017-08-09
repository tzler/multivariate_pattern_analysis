
%% Multivariate analyses - Revision
nSubjects = 10;
scriptDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/wrappers';
mvpcDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/';

 parameters.slurm.name = 'mvpc_sl_rev';
 parameters.slurm.cores_per_node = 4; 
 parameters.slurm.cpus_per_task = 1; 
 parameters.slurm.time = 5; % time in days

 parameters.slurm.mem_per_cpu = 16000;
 parameters.slurm.email = 'anzellot@mit.edu';

newMvpc_scriptGenerator_searchlight_rev(nSubjects,scriptDir,mvpcDir,parameters);
 
 %% Submit to queue
 
system('cd /mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12/wrappers');
 for iJob = 1:3
 system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_rev_%d.sh',iJob));
 end

 clear all

% %% Univariate analyses
% 
% nSubjects = 10;
% scriptDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers';
% mvpcDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/';
% 
%  parameters.slurm.name = 'newMvpc_sl_facesView_uni';
%  parameters.slurm.cores_per_node = 4; 
%  parameters.slurm.cpus_per_task = 1;
%   parameters.slurm.time = 5; % time in days
%  parameters.slurm.mem_per_cpu = 16000;
%  parameters.slurm.email = 'anzellot@mit.edu';
% 
% newMvpc_scriptGenerator_searchlight_uni(nSubjects,scriptDir,mvpcDir,parameters);
%  
%  %% Submit to queue
%  
% system('cd /mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers');
%  for iJob = 1:3
%  system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_uni_%d.sh',iJob));
%  end
%  
%  clear all
%  
%  
% %% Multivariate analyses
%  nSubjects = 10;
% scriptDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers';
% mvpcDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/';
% 
%  parameters.slurm.name = 'newMvpc_sl_facesView_mul';
%  parameters.slurm.cores_per_node = 4; 
%  parameters.slurm.cpus_per_task = 1; 
%  parameters.slurm.time = 5; % time in days
% 
%  parameters.slurm.mem_per_cpu = 16000;
%  parameters.slurm.email = 'anzellot@mit.edu';
% 
% newMvpc_scriptGenerator_searchlight_mul(nSubjects,scriptDir,mvpcDir,parameters);
%  
%  %% Submit to queue
%  
% system('cd /mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers');
%  for iJob = 1:3
%  system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_mul_%d.sh',iJob));
%  end
% 
%  clear all
%  
%  %% Individual components analyses
%  nSubjects = 10;
% scriptDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers';
% mvpcDir = '/mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/';
% 
%  parameters.slurm.name = 'newMvpc_sl_facesView_indpc';
%  parameters.slurm.cores_per_node = 4; 
%  parameters.slurm.cpus_per_task = 1;
%  parameters.slurm.time = 5; % time in days
%  parameters.slurm.mem_per_cpu = 16000;
%  parameters.slurm.email = 'anzellot@mit.edu';
% 
% newMvpc_scriptGenerator_searchlight_indpc(nSubjects,scriptDir,mvpcDir,parameters);
%  
%  %% Submit to queue
%  
% system('cd /mindhive/saxelab3/anzellotti/facesViewpoint/mvpc_searchlight_2016_12/wrappers');
%  for iJob = 1:3
%  system(sprintf('sbatch sbatch_newMvpc_parallel_searchlight_indpc_%d.sh',iJob));
%  end