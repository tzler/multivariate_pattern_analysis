function wrapper_mvpc_EIB

runAnalaysis = false;

% ######## Specify library paths ########
Cfg_mvpcRoi.dataInfo.project = '/mindhive/gablab/u/daeda/analyses/EIB';
Cfg_mvpcRoi.dataInfo.data = '/mindhive/gablab/u/daeda/analyses/EIB/EIB_data';
Cfg_mvpcRoi.libraryPaths.mvpc = '/mindhive/gablab/u/daeda/analyses/EIB/mvpc';
Cfg_mvpcRoi.libraryPaths.spm12 = '/mindhive/gablab/u/daeda/software/spm12';
% Cfg_mvpcRoi.libraryPaths.barwitherr = '/mindhive/saxelab3/ELEOS_MVPC/barwitherr';

% set workspace paths
addpath(Cfg_mvpcRoi.dataInfo.project);
% set function paths
addpath(genpath(Cfg_mvpcRoi.libraryPaths.mvpc));

% set regressors filter 
Cfg_mvpcRoi.dataInfo.regressorRunFilter = 'motion_outliers_only_*.mat'; 
Cfg_mvpcRoi.dataInfo.regressorTotalFilter = 'motion_total_*.mat';

% set functional filter
Cfg_mvpcRoi.dataInfo.functionalFilter = 'swaf*.nii';

% set anatomical filters
Cfg_mvpcRoi.dataInfo.anatDirName = 'anat';
Cfg_mvpcRoi.dataInfo.compcorrFilter = 'mask_combWMCSF_*.nii';

% set motion filters
Cfg_mvpcRoi.dataInfo.motionDirName = 'motion';
Cfg_mvpcRoi.dataInfo.totalMotionFilter = 'motion_total_*.mat';

% ######## Provide subject information ########
% load .mat file containing subject information
Cfg_mvpcRoi.dataInfo.subjectInfoPath = fullfile(Cfg_mvpcRoi.dataInfo.data,'EIB_subject_taskruns.mat');
subjects_controls = [10, 16:18, 21:23, 25, 26, 27, 38:42];
%subjects_controls = [10, 16:18, 21:23, 26, 27, 38:42];
subjects_ASD = [28:29, 31:34, 36, 57, 63:64, 66:70];
%subjects_ASD = [28:29, 31,32,34, 36, 57, 63:64, 66:70];

subjectSelector = [subjects_controls,subjects_ASD];

% load subject variable
load(Cfg_mvpcRoi.dataInfo.subjectInfoPath);
subjectInfo_mvpc = s(subjectSelector);

% generate full paths to the volume directories
Cfg_mvpcRoi.dataInfo.subjects = mvpc_generateFullDataPaths_EIB(Cfg_mvpcRoi.dataInfo.data,subjectInfo_mvpc); % THIS FUNCTION NEEDS TO BE CHANGED FOR DIFFERENT PROJECTS


% ######## Set parameters ########

%% ### Preprocessing ###
Cfg_mvpcRoi.compcorr.nPCs = 5;

% ### Region Models ###
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

% ### Interaction Models ###
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
Cfg_mvpcRoi.interactionModels(3).functionHandle = 'mvpc_multipleLinearRegression';
% non-linear multivariate connectivity
Cfg_mvpcRoi.interactionModels(4).label = 'iconn_nnet10';
Cfg_mvpcRoi.interactionModels(4).regionModel = 3;
Cfg_mvpcRoi.interactionModels(4).functionHandle = 'mvpc_neuralNet_indepPCA';
Cfg_mvpcRoi.interactionModels(4).parameters.nNodes = 10;


%% ######## set ROI ########
% set ROI filter for mvpc_populateCfg
Cfg_mvpcRoi.dataInfo.roiFilter = '*_EIB.img';

% specify paths to the folders containing the ROIs for mvpc_populateCfg
% ty: but we're using multiple ROIs for each subject
nSubjects = length(subjectInfo_mvpc);
for iSubject = 1:nSubjects
    Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir = '/mindhive/gablab/u/daeda/analyses/EIB/ROIs';
end

% specify ROI names
roiNamesFilePath = fullfile('/mindhive/gablab/u/daeda/software/mindhivemirror/wfu_pickatlas/MNI_atlas_templates/aal_MNI_V4_List.mat');
load(roiNamesFilePath);
% specify names of regions of interest
Cfg_mvpcRoi.dataInfo.regionLabels = {ROI.Nom_L}; % ROI is variable loaded from wfu atlas
% tempROInames = {ROI.Nom_L}; % ROI is variable loaded from wfu atlas
% Cfg_mvpcRoi.dataInfo.regionLabels = {tempROInames{1:90}}; % select only first 90 ROI

% ######## Populate Cfg ######## 
Cfg_mvpcRoi.dataInfo.expungeVols = true;
Cfg_mvpcRoi.dataInfo.expungeRuns = true;
Cfg_mvpcRoi.dataInfo.expungeRunsThreshold = 2/3; % discard runs with > 2/3 scrubbed volumes
[exit_script, Cfg_mvpcRoi] = mvpc_populateCfg(Cfg_mvpcRoi);

% Trim ROI for EIB b/c of small bounding box (remove cerebellar ROIs)
Cfg_mvpcRoi.dataInfo.regionLabels(91:end) = [];
for iSubject = 1:nSubjects
Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths(91:end) = [];
end

% ######### Set output folders ########
Cfg_mvpcRoi.outputPaths.date_id = num2str(datenum(date));
output = strcat('mvpc_',Cfg_mvpcRoi.outputPaths.date_id);
Cfg_mvpcRoi.outputPaths.results_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'results');
Cfg_mvpcRoi.outputPaths.fig_base = fullfile(Cfg_mvpcRoi.dataInfo.project,'figures'); % adding the date to the folder because multiple figures will be saved
Cfg_mvpcRoi.outputPaths.results = fullfile(Cfg_mvpcRoi.outputPaths.results_base,output);
Cfg_mvpcRoi.outputPaths.fig = fullfile(Cfg_mvpcRoi.outputPaths.fig_base,output);

%% ######## Check file existence, make output directories ########
exit_script = mvpc_rois_makedirs(Cfg_mvpcRoi);

if exit_script
    return;
end

%% ######## save CFG variables ########
Cfg_mvpcRoi.outputPaths.Cfg_variable = fullfile(Cfg_mvpcRoi.outputPaths.results,'Cfg_mvpcRoi.mat');
save(Cfg_mvpcRoi.outputPaths.Cfg_variable,'Cfg_mvpcRoi');
fprintf('Cfg Saved to %s\n',Cfg_mvpcRoi.outputPaths.Cfg_variable)

if runAnalaysis
	%% ######## Run analysis ########
	timerStart = tic;
	lastTimepoint = toc(timerStart);
	results = mvpc_rois(Cfg_mvpcRoi);
	timerSplit = toc(timerStart);
	fprintf('MVPC Analysis Complete. Total time: %d h %d m %f s.\n\n\n',floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
else
	[wrapperPath,~,~]=fileparts(which(mfilename));
	slurm.name = 'EIB_MVPC';
	slurm.mem_per_cpu = 15360;
	slurm.nodes = 1;
	slurm.cpus_per_task = 1;
	slurm.email = 'daeda@mit.edu';
	sbatch_genScripts(Cfg_mvpcRoi, wrapperPath, slurm);
	fprintf('\nsbatch scripts generated\n')
end

end