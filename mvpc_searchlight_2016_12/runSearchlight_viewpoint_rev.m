function runSearchlight_viewpoint_rev(iSubject)

% ######## Specify project folder path ########
Cfg_searchlight.dataInfo.project = '/mindhive/saxelab3/anzellotti/facesViewpoint';

% ######## Specify library paths ########
Cfg_searchlight.libraryPaths.spm12 = '/mindhive/saxelab3/anzellotti/software/spm12';
Cfg_searchlight.libraryPaths.mrtools = '/mindhive/saxelab3/anzellotti/facesViewpoint/MVPC_scripts_revision/mvpc_searchlight_2016_12';
Cfg_searchlight.libraryPaths.signal = '/mindhive/saxelab3/anzellotti/software/MATLAB/R2015a/toolbox/signal/signal';
Cfg_searchlight.libraryPaths.stats = '/mindhive/saxelab3/anzellotti/software/MATLAB/R2015a/toolbox/stats/stats';
addpath(genpath(Cfg_searchlight.libraryPaths.mrtools));

% ######## Provide subject information ########
subjects_temp = [1:8,10];
subjects = subjects_temp(iSubject);
subjectTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/sub%02d';
runTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/sub%02d/run%d';
nRuns = 3;
seedTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/1_ROIs/6mm/rightFFA6mm_222/sub%02d_6mm_rightFFA_222.nii';
searchSpaceTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/meanGray_discrete.nii';
compcorrMaskTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/sub%02d/anatomy1/mask_combWMCSF_sub%02d.nii';
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
Cfg_searchlight.searchlightInfo.compcorr.includeMotionRegressors='yes';

Cfg_searchlight.outputPath = '/mindhive/saxelab3/anzellotti/facesViewpoint/searchlight_results_rev';

% ### Region Models ###
% region model for mvpc 1-3 dimensions
% for iDim = 1:3
%    Cfg_searchlight.regionModels(iDim).seed.label = sprintf('PCA_noLowPass_%02ddim',iDim);
%     % Cfg_searchlight.regionModels(2).steps(1).functionHandle = 'mvpc_demean';
%     Cfg_searchlight.regionModels(iDim).seed.steps(1).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
%     Cfg_searchlight.regionModels(iDim).seed.steps(1).parameters.minPCs = iDim;
%     Cfg_searchlight.regionModels(iDim).seed.steps(1).parameters.maxPCs = iDim;
%     Cfg_searchlight.regionModels(iDim).spheres = Cfg_searchlight.regionModels(iDim).seed;
% end
Cfg_searchlight.regionModels(1).seed.label = sprintf('PCA_noLowPass_BIC');
Cfg_searchlight.regionModels(1).seed.steps(1).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
Cfg_searchlight.regionModels(1).seed.steps(1).parameters.minPCs = 3;
Cfg_searchlight.regionModels(1).seed.steps(1).parameters.maxPCs = 10;
Cfg_searchlight.regionModels(1).spheres = Cfg_searchlight.regionModels(1).seed;
Cfg_searchlight.regionModels(2).seed.label = sprintf('PCA_noLowPass_BIC_demean');
Cfg_searchlight.regionModels(2).seed.steps(1).functionHandle = 'mvpc_demean';
Cfg_searchlight.regionModels(2).seed.steps(2).functionHandle = 'mvpc_indepPCA_BIC_weights_V';
Cfg_searchlight.regionModels(2).seed.steps(2).parameters.minPCs = 3;
Cfg_searchlight.regionModels(2).seed.steps(2).parameters.maxPCs = 10;
Cfg_searchlight.regionModels(2).spheres = Cfg_searchlight.regionModels(2).seed;

% ### Interaction Models ###

% linear multivariate connectivity
for iModel = 1:2
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
