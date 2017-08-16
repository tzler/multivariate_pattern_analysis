function runSearchlight(iSubject)

%% Initialize general parameters

% ######## Specify and add library paths ########
Cfg_MVPDroi.libraryPaths.mvpd = '/mindhive/saxelab3/anzellotti/github_repos/mvpd';
Cfg_MVPDroi.libraryPaths.spm12 = '/mindhive/saxelab3/anzellotti/software/spm12';
addpath(genpath(Cfg_MVPDroi.libraryPaths.mvpd));

% ########## Specify inputs ###########
subjects = generateFullDataPaths_example;
Cfg_MVPDroi.dataInfo.subjects = subjects(iSubject);

% ######## Preprocessing and region models #######
% preprocessing model
Cfg_MVPDroi.preprocModels.steps(1).functionHandle = 'loadDenoise_scrub';
Cfg_MVPDroi.preprocModels.steps(2).functionHandle = 'loadDenoise_compcorr';
Cfg_MVPDroi.preprocModels.steps(2).parameters.nPCs = 5;
Cfg_MVPDroi.preprocModels.steps(3).functionHandle = 'loadDenoise_globalSignal';
Cfg_MVPDroi.preprocModels.steps(4).functionHandle = 'loadDenoise_motionParameters';

% region model with low pass filtering
Cfg_MVPDroi.regionModels(1).label = 'mean_lowPass0.1';
Cfg_MVPDroi.regionModels(1).steps(1).functionHandle = 'regionModel_mean';
Cfg_MVPDroi.regionModels(1).steps(2).functionHandle = 'regionModel_lowPass';
Cfg_MVPDroi.regionModels(1).steps(2).parameters.lowPassFrequencyHz = 0.1;
Cfg_MVPDroi.regionModels(1).steps(2).parameters.TR = 2;
% preprocessing without low pass filtering
Cfg_MVPDroi.regionModels(2).label = 'mean_noLowPass';
Cfg_MVPDroi.regionModels(2).steps(1).functionHandle = 'regionModel_mean_traintest';
% preprocessing without low pass filtering
Cfg_MVPDroi.regionModels(3).label = 'PCA_noLowPass';
Cfg_MVPDroi.regionModels(3).steps(1).functionHandle = 'regionModel_indepPCA_BIC';
Cfg_MVPDroi.regionModels(3).steps(1).parameters.minPCs = 3;
Cfg_MVPDroi.regionModels(3).steps(1).parameters.maxPCs = 10;

% ############# Interaction Models #############
% functional connectivity with low-pass
Cfg_MVPDroi.interactionModels(1).label = 'fconn_lowPass0.1';
Cfg_MVPDroi.interactionModels(1).regionModel = 1;
Cfg_MVPDroi.interactionModels(1).functionHandle = 'interactionModel_y_equal_x';
Cfg_MVPDroi.interactionModels(1).parameters.measureHandle{1} = 'accuracy_corr';
Cfg_MVPDroi.interactionModels(1).parameters.measureHandle{2} = 'accuracy_rSquare';
% functional connectivity without low-pass filtering
Cfg_MVPDroi.interactionModels(2).label = 'fconn_noLowPass';
Cfg_MVPDroi.interactionModels(2).regionModel = 2;
Cfg_MVPDroi.interactionModels(2).functionHandle = 'interactionModel_correlation';
Cfg_MVPDroi.interactionModels(2).functionHandle = 'interactionModel_y_equal_x';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{1} = 'accuracy_corr';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{2} = 'accuracy_rSquare';
% linear multivariate connectivity
Cfg_MVPDroi.interactionModels(3).label = 'iconn_noLowPass';
Cfg_MVPDroi.interactionModels(3).regionModel = 3;
Cfg_MVPDroi.interactionModels(3).functionHandle = 'interactionModel_lin';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{1} = 'accuracy_corr';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{2} = 'accuracy_rSquare';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{3} = 'accuracy_varexpl_vox_mean';
Cfg_MVPDroi.interactionModels(2).parameters.measureHandle{4} = 'accuracy_varexpl_ledoitWolf';
% non-linear multivariate connectivity
for iNode = 1:10
    Cfg_MVPDroi.interactionModels(3+iNode).label = sprintf('mvpd_nnet%02d',iNode);
    Cfg_MVPDroi.interactionModels(3+iNode).regionModel = 3;
    Cfg_MVPDroi.interactionModels(3+iNode).functionHandle = 'interactionModel_nn';
    Cfg_MVPDroi.interactionModels(3+iNode).parameters.nNodes = iNode;
end

% ######### Set output folders ########
output_main =  '/mindhive/saxelab3/anzellotti/facesVoices_art2';
Cfg_MVPDroi.outputPaths.regionModels = fullfile(output_main,'regionModels');
Cfg_MVPDroi.outputPaths.interactionModels = fullfile(output_main,'interactionModels');
Cfg_MVPDroi.outputPaths.products = fullfile(output_main,'products');
Cfg_MVPDroi.outputPaths.cfgPath = fullfile(Cfg_MVPDroi.outputPaths.products,'Cfg_MVPDroi');

% ######## Check file existence, make output directories, save Cfg file ########
MVPDroi_setenv(Cfg_MVPDroi);


% ######## Set parameters ########
 % path of a ROI to use as search space
Cfg_searchlight.searchlightInfo.voxelSize = [2 2 2]; % voxel size in mm
Cfg_searchlight.searchlightInfo.sphereRadius = 6; % radius in mm
Cfg_searchlight.searchlightInfo.compcorr.nPCs = 5;

Cfg_searchlight.outputPath = '/mindhive/saxelab3/anzellotti/facesViewpoint/searchlight_results_rev';


% ######## Sanity checks ########


% ######## Run ########
mvpc_searchlight_only(Cfg_searchlight,Cfg_smoothing)
