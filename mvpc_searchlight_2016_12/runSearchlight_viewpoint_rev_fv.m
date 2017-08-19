function runSearchlight_fv_rev(iSubject)

% ######## Specify project folder path ########
Cfg_searchlight.dataInfo.project = '/mindhive/saxelab3/anzellotti/facesVoices_art2';

% ######## Specify library paths ########
Cfg_searchlight.libraryPaths.spm12 = '/mindhive/saxelab3/anzellotti/software/spm12';
Cfg_searchlight.libraryPaths.mrtools = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12';
addpath(genpath(Cfg_searchlight.libraryPaths.mrtools));

% ######## Provide subject information ########
subjects_temp = [1,3:5,8,12:17];
subjects = subjects_temp(iSubject);
subjectTemplatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d';
runTemplatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d/run%d';
nRuns = 5;
seedTemplatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/5_ROIs_222/facesVShouses/ROI03_S%02d_sphere6mm.img';
searchSpaceTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/meanGray_discrete.nii';
compcorrMaskTemplatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d/anatomy1/mask_combWMCSF_sub%02d.nii';
% generate full paths to the volume directories
Cfg_searchlight.dataInfo.subjects = mvpc_generateFullDataPaths_facesVoices(subjects,subjectTemplatePath,runTemplatePath,nRuns,seedTemplatePath,searchSpaceTemplatePath,compcorrMaskTemplatePath); % THIS FUNCTION NEEDS TO BE CHANGED FOR DIFFERENT PROJECTS
Cfg_searchlight.dataInfo.functionalFilter = 'swaf*.img';
Cfg_searchlight.dataInfo.anatDirName = 'anatomy1';
Cfg_searchlight.dataInfo.compcorrFilter = 'mask_combWMCSF_*.nii';

% ######## Set parameters ########
 % path of a ROI to use as search space
Cfg_searchlight.searchlightInfo.voxelSize = [2 2 2]; % voxel size in mm
Cfg_searchlight.searchlightInfo.sphereRadius = 6; % radius in mm
Cfg_searchlight.searchlightInfo.compcorr.nPCs = 5;
Cfg_searchlight.searchlightInfo.compcorr.includeMotionRegressors='yes';

Cfg_searchlight.outputPath = '/mindhive/saxelab3/anzellotti/facesViewpoint/searchlight_results_rev_fv';

% ### Region Models ###
% region model for fconn with low pass
Cfg_searchlight.regionModels(1).seed.label = 'mean_lowPass0.1';
Cfg_searchlight.regionModels(1).seed.steps(1).functionHandle = 'mvpc_mean';
Cfg_searchlight.regionModels(1).seed.steps(2).functionHandle = 'mvpc_lowPass';
Cfg_searchlight.regionModels(1).seed.steps(2).parameters.lowPassFrequencyHz = 0.1;
Cfg_searchlight.regionModels(1).seed.steps(2).parameters.TR = 2;
Cfg_searchlight.regionModels(1).spheres = Cfg_searchlight.regionModels(1).seed;
% region model for leave-one-out fconn with low pass
Cfg_searchlight.regionModels(2).seed.label = 'mean_lowPass0.1_traintest';
Cfg_searchlight.regionModels(2).seed.steps(1).functionHandle = 'mvpc_mean_traintest';
Cfg_searchlight.regionModels(2).seed.steps(2).functionHandle = 'mvpc_lowPass_traintest';
Cfg_searchlight.regionModels(2).seed.steps(2).parameters.lowPassFrequencyHz = 0.1;
Cfg_searchlight.regionModels(2).seed.steps(2).parameters.TR = 2;
Cfg_searchlight.regionModels(2).spheres = Cfg_searchlight.regionModels(2).seed;
% region model for leave-one-out fconn without low pass
Cfg_searchlight.regionModels(3).seed.label = 'mean_noLowPass_traintest';
Cfg_searchlight.regionModels(3).seed.steps(1).functionHandle = 'mvpc_mean_traintest';
Cfg_searchlight.regionModels(3).spheres = Cfg_searchlight.regionModels(3).seed;

Cfg_searchlight.regionModels(4).seed.label = sprintf('PCA_noLowPass_BIC');
Cfg_searchlight.regionModels(4).seed.steps(1).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
Cfg_searchlight.regionModels(4).seed.steps(1).parameters.minPCs = 3;
Cfg_searchlight.regionModels(4).seed.steps(1).parameters.maxPCs = 10;
Cfg_searchlight.regionModels(4).spheres = Cfg_searchlight.regionModels(4).seed;
Cfg_searchlight.regionModels(5).seed.label = sprintf('PCA_noLowPass_BIC_demean');
Cfg_searchlight.regionModels(5).seed.steps(1).functionHandle = 'mvpc_demean';
Cfg_searchlight.regionModels(5).seed.steps(2).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
Cfg_searchlight.regionModels(5).seed.steps(2).parameters.minPCs = 3;
Cfg_searchlight.regionModels(5).seed.steps(2).parameters.maxPCs = 10;
Cfg_searchlight.regionModels(5).spheres = Cfg_searchlight.regionModels(5).seed;

% ### Interaction Models ###

% functional connectivity with low-pass 
Cfg_searchlight.interactionModels(1).label = 'fconn_lowPass0.1';
Cfg_searchlight.interactionModels(1).regionModel = 1;
Cfg_searchlight.interactionModels(1).functionHandle = 'mvpc_correlation';
Cfg_searchlight.interactionModels(1).parameters = [];

for iModel = 2:3
    Cfg_searchlight.interactionModels(iModel).label = sprintf('loo_%02d',iModel);
    Cfg_searchlight.interactionModels(iModel).regionModel = iModel;
    Cfg_searchlight.interactionModels(iModel).functionHandle = 'mvpc_multipleLinearRegression_indPCA_sl_weighted_V';
    Cfg_searchlight.interactionModels(iModel).parameters = [];
end

% linear multivariate connectivity
for iModel = 4:5
    Cfg_searchlight.interactionModels(iModel).label = sprintf('loo_%02d',iModel);
    Cfg_searchlight.interactionModels(iModel).regionModel = iModel;
    Cfg_searchlight.interactionModels(iModel).functionHandle = 'mvpc_multipleLinearRegression_indPCA_sl_weighted_V';
    Cfg_searchlight.interactionModels(iModel).parameters = [];
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
mvpc_searchlight_only(Cfg_searchlight,Cfg_smoothing)
