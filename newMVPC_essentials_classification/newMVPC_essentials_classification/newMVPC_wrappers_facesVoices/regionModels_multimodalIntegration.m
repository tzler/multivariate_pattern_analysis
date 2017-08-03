% This script makes and saves the inputs for preprocessing, and makes the
% scripts to launch preprocessing in parallel with MPI

%% Prepare and save inputs

% ######## Specify and add library paths ########
Cfg_mvpcRoi.dataInfo.project =  '/mindhive/saxelab3/anzellotti/facesVoices_art2';
Cfg_mvpcRoi.dataInfo.data = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF';
Cfg_mvpcRoi.libraryPaths.mvpc = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/';
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
% preprocessing without low pass filtering
Cfg_mvpcRoi.regionModels(1).label = 'demean_PCA_noLowPass';
Cfg_mvpcRoi.regionModels(1).steps(1).functionHandle = 'mvpc_demean';
Cfg_mvpcRoi.regionModels(1).steps(2).functionHandle = 'mvpc_indepPCA_BIC';
Cfg_mvpcRoi.regionModels(1).steps(2).parameters.minPCs = 3;
Cfg_mvpcRoi.regionModels(1).steps(2).parameters.maxPCs = 20;

% ######## set ROIs ########
% set ROI filter for mvpc_populateCfg
Cfg_mvpcRoi.dataInfo.roiFilter = '*.img';
% specify paths to the folders containing the ROIs for mvpc_populateCfg
nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
for iSubject = 1:nSubjects
    Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).subjectPath,'ROIs_multimodalIntegration');
end
% % specify ROI names
Cfg_mvpcRoi.dataInfo.regionLabels = {'PCaud','PCvis','facesOnly_roi','lSTG','lSTS','rSTG','rSTS','voiceOnly_roi'};

% ################## Populate Cfg ###############
Cfg_mvpcRoi.dataInfo.expungeVols = true;
Cfg_mvpcRoi.dataInfo.expungeRuns = true;
Cfg_mvpcRoi.dataInfo.expungeRunsThreshold = 2/3; % discard runs with > 2/3 scrubbed volumes
[exit_script, Cfg_mvpcRoi] = newMvpc_populateCfg(Cfg_mvpcRoi);

% ######### Set output folders ########
Cfg_mvpcRoi.outputPaths.regionModels_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'regionModels_multimodalIntegration');
Cfg_mvpcRoi.outputPaths.interactionModels_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'interactionModels_multimodalIntegration');

% ######## Check file existence, make output directories ########
if ~exit_script
	exit_script = newMvpc_rois_makedirs(Cfg_mvpcRoi);
end

% ######## Save Cfg to file ##############
cfgPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/Cfg_mvpcRoi_multimodalIntegration.mat';
save(cfgPath,'Cfg_mvpcRoi','-v7.3');

% ########## Terminate if errors were encountered ############
if exit_script
    error('Errors encoutered. Not generating scripts.');
    return
end

%% Make parallel scripts for preprocessing

nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
scriptDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/newMVPC_wrappers_facesVoices_multimodalIntegration';
mvpcDir = fullfile(Cfg_mvpcRoi.libraryPaths.mvpc,'newMVPC_externalFunctions');

 parameters.slurm.name = 'mvpc_fvMI_r';
 parameters.slurm.nodes = 1; 
 parameters.slurm.cpus_per_task = 1;
 parameters.slurm.task_per_node = nSubjects;
 parameters.slurm.mem_per_cpu = 8192;
 parameters.slurm.email = 'anzellot@mit.edu';

 newMvpc_scriptGenerator_preproc(nSubjects,scriptDir,mvpcDir,parameters,cfgPath);
 