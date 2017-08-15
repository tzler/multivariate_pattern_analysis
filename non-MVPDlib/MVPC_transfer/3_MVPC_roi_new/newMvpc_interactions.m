function newMvpc_interactions(cfgPath,iSubject,iAnalysis)

% This function runs the interaction models iAnalysis in
% participant iSubject

% ############# Set paths ############
load(cfgPath);
% set workspace paths
addpath(Cfg_mvpcRoi.dataInfo.project);
% set function paths
addpath(genpath(Cfg_mvpcRoi.libraryPaths.mvpc));
addpath(genpath(Cfg_mvpcRoi.libraryPaths.spm12));
rmpath(genpath(fullfile(Cfg_mvpcRoi.libraryPaths.spm12,'external')));

% ############ Load data #############
subject = Cfg_mvpcRoi.dataInfo.subjects(iSubject);
interactionModel = Cfg_mvpcRoi.interactionModels(iAnalysis);
regionModelName = sprintf('sub%s_rmodel%02d',subject.ID,interactionModel.regionModel);
regionModel = load(fullfile(Cfg_mvpcRoi.outputPaths.regionModels_base,regionModelName));

% ######## Estimate and assess interaction model ######## 
results = mvpc_inter_roi(interactionModel.functionHandle,interactionModel.parameters,regionModel.preprocdata);
fprintf('\nInteraction model %d for subject %d completed.\n',iAnalysis,iSubject);


% ################ Save to file #############
 outputFilename = sprintf('sub%s_imodel%02d',subject.ID,iAnalysis);
 outputFilepath = fullfile(Cfg_mvpcRoi.outputPaths.interactionModels_base,outputFilename);
 save(outputFilepath,'results','interactionModel','-v7.3');
