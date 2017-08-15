% This script makes and saves the inputs for preprocessing, and makes the
% scripts to launch preprocessing in parallel with MPI

%% Prepare and save inputs

% ######## Specify and add library paths ########
Cfg_mvpcRoi.dataInfo.project =  '/mindhive/saxelab3/anzellotti/facesVoices_art2';
Cfg_mvpcRoi.dataInfo.data = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF';
Cfg_mvpcRoi.libraryPaths.mvpc = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials_classification/';
Cfg_mvpcRoi.libraryPaths.spm12 = '/mindhive/saxelab3/anzellotti/software/spm12';
% set workspace paths
addpath(Cfg_mvpcRoi.dataInfo.project);
% set function paths
addpath(genpath(Cfg_mvpcRoi.libraryPaths.mvpc));

% ########## Specify inputs ###########
% set regressors filter 
Cfg_mvpcRoi.dataInfo.regressorRunFilter = 'motion_outliers_only_*.mat'; 
Cfg_mvpcRoi.dataInfo.regressorTotalFilter = 'motion_total_*.mat';
% set functional filter
Cfg_mvpcRoi.dataInfo.functionalFilter = 'swaf*.img';
% set anatomical filters
Cfg_mvpcRoi.dataInfo.anatDirName = 'anatomy1';
Cfg_mvpcRoi.dataInfo.compcorrFilter = 'mask_combWMCSF_*.nii';
% set motion filters
Cfg_mvpcRoi.dataInfo.motionDirName = 'motion';
Cfg_mvpcRoi.dataInfo.totalMotionFilter = 'motion_total_*.mat';
% set subject data info
Cfg_mvpcRoi.dataInfo.subjects = mvpc_generateFullDataPaths_facesVoices_art2;

% ######## Preprocessing and region models #######
Cfg_mvpcRoi.compcorr.nPCs = 5;
% region model with low pass filtering
Cfg_mvpcRoi.regionModels(1).label = 'mean_lowPass0.1';
Cfg_mvpcRoi.regionModels(1).steps(1).functionHandle = 'mvpc_mean';
Cfg_mvpcRoi.regionModels(1).steps(2).functionHandle = 'mvpc_lowPass';
Cfg_mvpcRoi.regionModels(1).steps(2).parameters.lowPassFrequencyHz = 0.1;
Cfg_mvpcRoi.regionModels(1).steps(2).parameters.TR = 2;
% preprocessing without low pass filtering
Cfg_mvpcRoi.regionModels(2).label = 'mean_noLowPass';
Cfg_mvpcRoi.regionModels(2).steps(1).functionHandle = 'mvpc_mean';
% preprocessing without low pass filtering
Cfg_mvpcRoi.regionModels(3).label = 'demean_PCA_noLowPass';
Cfg_mvpcRoi.regionModels(3).steps(1).functionHandle = 'mvpc_demean';
Cfg_mvpcRoi.regionModels(3).steps(2).functionHandle = 'mvpc_indepPCA_BIC';
Cfg_mvpcRoi.regionModels(3).steps(2).parameters.minPCs = 3;
Cfg_mvpcRoi.regionModels(3).steps(2).parameters.maxPCs = 20;

% ############# Interaction Models #############
% functional connectivity with low-pass 
Cfg_mvpcRoi.interactionModels(1).label = 'fconn_lowPass0.1';
Cfg_mvpcRoi.interactionModels(1).regionModel = 1;
Cfg_mvpcRoi.interactionModels(1).functionHandle = 'mvpc_correlation';
% functional connectivity without low-pass filtering
Cfg_mvpcRoi.interactionModels(2).label = 'fconn_noLowPass';
Cfg_mvpcRoi.interactionModels(2).regionModel = 2;
Cfg_mvpcRoi.interactionModels(2).functionHandle = 'mvpc_correlation';
% linear multivariate connectivity
Cfg_mvpcRoi.interactionModels(3).label = 'iconn_noLowPass';
Cfg_mvpcRoi.interactionModels(3).regionModel = 3;
Cfg_mvpcRoi.interactionModels(3).functionHandle = 'mvpc_multipleLinearRegression_indepPCA';
% non-linear multivariate connectivity
for iNode = 1:10
    Cfg_mvpcRoi.interactionModels(3+iNode).label = sprintf('iconn_nnet%02d',iNode);
    Cfg_mvpcRoi.interactionModels(3+iNode).regionModel = 3;
    Cfg_mvpcRoi.interactionModels(3+iNode).functionHandle = 'mvpc_neuralNet_indepPCA';
    Cfg_mvpcRoi.interactionModels(3+iNode).parameters.nNodes = iNode;
end

% ######## set ROIs ########
% set ROI filter for mvpc_populateCfg
Cfg_mvpcRoi.dataInfo.roiFilter = '*.img';
% specify paths to the folders containing the ROIs for mvpc_populateCfg
nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
for iSubject = 1:nSubjects
    Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).subjectPath,'ROIs');
end
% specify ROI names
Cfg_mvpcRoi.dataInfo.regionLabels = {'rFFA','lFFA','rSTS','lSTS','rATL','lATL','PCvis','vmPFC','rpSTG','lpSTG','rmSTG','rmSTG','raSTG','raSTG','PCaud'};

% ################## Populate Cfg ###############
Cfg_mvpcRoi.dataInfo.expungeVols = true;
Cfg_mvpcRoi.dataInfo.expungeRuns = true;
Cfg_mvpcRoi.dataInfo.expungeRunsThreshold = 2/3; % discard runs with > 2/3 scrubbed volumes
[exit_script, Cfg_mvpcRoi] = newMvpc_populateCfg(Cfg_mvpcRoi);

% ######### Set output folders ########
Cfg_mvpcRoi.outputPaths.regionModels_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'regionModels');
Cfg_mvpcRoi.outputPaths.interactionModels_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'interactionModels_classification');

% ######## Check file existence, make output directories ########
if ~exit_script
	exit_script = newMvpc_rois_makedirs(Cfg_mvpcRoi);
end

% ######## Save Cfg to file ##############
cfgPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/Cfg_mvpcRoi.mat';
save(cfgPath,'Cfg_mvpcRoi','-v7.3');

% ########## Terminate if errors were encountered ############
if exit_script
    error('Errors encoutered. Not generating scripts.');
    return
end

%% Make parallel scripts for preprocessing

nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
scriptDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices';
mvpcDir = fullfile(Cfg_mvpcRoi.libraryPaths.mvpc,'newMVPC_externalFunctions');

 parameters.slurm.name = 'newMvpc_preproc_facesVoices';
 parameters.slurm.nodes = 1; 
 parameters.slurm.cpus_per_task = 1;
 parameters.slurm.task_per_node = nSubjects;
 parameters.slurm.mem_per_cpu = 8192;
 parameters.slurm.email = 'anzellot@mit.edu';

 newMvpc_scriptGenerator_preproc(nSubjects,scriptDir,mvpcDir,parameters,cfgPath);
 
 %% Submit to queue
 system('cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices');
 for iSubject = 2:17
 system(sprintf('sbatch sbatch_newMvpc_parallel_interactions_%d.sh',iJob));
 end
 
 %% Make parallel scripts for interaction models
 
nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
nAnalyses = length(Cfg_mvpcRoi.interactionModels);
scriptDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials_classification/newMVPC_wrappers_facesVoices';
mvpcDir = fullfile(Cfg_mvpcRoi.libraryPaths.mvpc,'newMVPC_externalFunctions');

 parameters.slurm.name = 'newMvpc_inter_facesVoices';
 parameters.slurm.cores_per_node = 5; 
 parameters.slurm.cpus_per_task = 1;
 parameters.slurm.mem_per_cpu = 10240;
 parameters.slurm.email = 'anzellot@mit.edu';

 newMvpc_scriptGenerator_interactions(nSubjects,nAnalyses,scriptDir,mvpcDir,parameters,cfgPath);
 
 %% Submit to queue
 
system('cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices');
 for iJob = 1:26
 system(sprintf('sbatch sbatch_newMvpc_parallel_interactions_%d.sh',iJob));
 end
 
 
 
 
