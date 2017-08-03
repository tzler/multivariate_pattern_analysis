
% ######## Specify project folder path ########
Cfg_searchlight.dataInfo.project = 'C:\stefano\facesViewpoint';

% ######## Specify library paths ########
Cfg_searchlight.libraryPaths.spm12 = 'C:\Program Files\MATLAB\R2015b\toolbox\spm12';
Cfg_searchlight.libraryPaths.mrtools = 'C:\stefano\mvpc_searchlight_2016_12';
Cfg_searchlight.libraryPaths.signal = 'C:\Program Files\MATLAB\R2015b\toolbox\signal\signal';
Cfg_searchlight.libraryPaths.stats = 'C:\Program Files\MATLAB\R2015b\toolbox\stats\stats';

% ######## Provide subject information ########
subjects = [1];
subjectTemplatePath = 'C:\\stefano\\facesViewpoint\\2_data_preproc\\sub%02d';
runTemplatePath = 'C:\\stefano\\facesViewpoint\\2_data_preproc\\sub%02d\\run%d';
nRuns = 3;
seedTemplatePath = 'C:\\stefano\\facesViewpoint\\2_data_preproc\\1_ROIs\\6mm\\rightFFA6mm_222\\sub%02d_6mm_rightFFA_222.nii';
searchSpaceTemplatePath = 'C:\stefano\facesViewpoint\2_data_preproc\meanGray_discrete.nii';
compcorrMaskTemplatePath = 'C:\\stefano\\facesViewpoint\\2_data_preproc\\sub%02d\\anatomy1\\mask_combWMCSF_sub%02d.nii';
% generate full paths to the volume directories
Cfg_searchlight.dataInfo.subjects = mvpc_generateFullDataPaths_facesViewpoint(subjects,subjectTemplatePath,runTemplatePath,nRuns,seedTemplatePath,searchSpaceTemplatePath,compcorrMaskTemplatePath); % THIS FUNCTION NEEDS TO BE CHANGED FOR DIFFERENT PROJECTS
Cfg_searchlight.dataInfo.functionalFilter = 'swaf*.img';
Cfg_searchlight.dataInfo.anatDirName = 'anatomy1';
Cfg_searchlight.dataInfo.compcorrFilter = 'mask_combWMCSF_*.nii';

% ######## Set parameters ########
 % path of a ROI to use as search space
Cfg_searchlight.searchlightInfo.voxelSize = [2 2 2]; % voxel size in mm
Cfg_searchlight.searchlightInfo.sphereRadius = 6; % radius in mm
Cfg_searchlight.searchlightInfo.compcorr.nPCs = 5;
Cfg_searchlight.outputPath = 'C:\stefano\facesViewpoint\results_weighted_V';

% ### Region Models ###
% region model with low pass filtering
Cfg_searchlight.regionModels(1).label = 'mean_lowPass0.1';
Cfg_searchlight.regionModels(1).steps(1).functionHandle = 'mvpc_mean';
Cfg_searchlight.regionModels(1).steps(2).functionHandle = 'mvpc_lowPass';
Cfg_searchlight.regionModels(1).steps(2).parameters.lowPassFrequencyHz = 0.1;
Cfg_searchlight.regionModels(1).steps(2).parameters.TR = 2;
% % preprocessing without low pass filtering
% Cfg_searchlight.regionModels(2).label = 'mean_noLowPass';
% Cfg_searchlight.regionModels(2).steps(1).functionHandle = 'mvpc_mean';
% preprocessing without low pass filtering
for iDim = 1:3
    Cfg_searchlight.regionModels(1+iDim).label = 'PCA_noLowPass';
    % Cfg_searchlight.regionModels(2).steps(1).functionHandle = 'mvpc_demean';
    Cfg_searchlight.regionModels(1+iDim).steps(1).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
    Cfg_searchlight.regionModels(1+iDim).steps(1).parameters.minPCs = iDim;
    Cfg_searchlight.regionModels(1+iDim).steps(1).parameters.maxPCs = iDim;
end

% ### Interaction Models ###
% functional connectivity with low-pass 
Cfg_searchlight.interactionModels(1).label = 'fconn_lowPass0.1';
Cfg_searchlight.interactionModels(1).regionModel = 1;
Cfg_searchlight.interactionModels(1).functionHandle = 'mvpc_correlation';
% % functional connectivity without low-pass filtering
% Cfg_searchlight.interactionModels(2).label = 'fconn_lowPass0.1_indep';
% Cfg_searchlight.interactionModels(2).regionModel = 1;
% Cfg_searchlight.interactionModels(2).functionHandle = 'mvpc_multipleLinearRegression_r';
% 
% % functional connectivity without low-pass filtering
% Cfg_searchlight.interactionModels(2).label = 'fconn_noLowPass';
% Cfg_searchlight.interactionModels(2).regionModel = 2;
% Cfg_searchlight.interactionModels(2).functionHandle = 'mvpc_correlation';
% linear multivariate connectivity
for iDim = 1:3
    Cfg_searchlight.interactionModels(1+iDim).label = 'iconn_noLowPass';
    Cfg_searchlight.interactionModels(1+iDim).regionModel = 1+iDim;
    Cfg_searchlight.interactionModels(1+iDim).functionHandle = 'mvpc_multipleLinearRegression_indPCA_sl_weighted_V';
end 
% ### Postprocessing parameters ###
Cfg_smoothing.smoothingKernel = [2 2 2];

% set regressors filter 
Cfg_searchlight.dataInfo.regressorRunFilter = 'motion_outliers_only_*.mat'; 
Cfg_searchlight.dataInfo.regressorTotalFilter = 'motion_total_*.mat';
% set motion filters
Cfg_searchlight.dataInfo.motionDirName = 'motion';
Cfg_searchlight.dataInfo.totalMotionFilter = 'motion_total_*.mat';


% ######## Populate Cfg ########
Cfg_searchlight.dataInfo.expungeVols = true;
Cfg_searchlight.dataInfo.expungeRuns = true;
Cfg_searchlight.dataInfo.expungeRunsThreshold = 2/3; % discard runs with > 2/3 scrubbed volumes
[Cfg_searchlight, exit_script] = newMvpc_populateCfg(Cfg_searchlight);

% ######## Sanity checks ########


% ######## Run ########
mvpc_searchlight(Cfg_searchlight,Cfg_smoothing)