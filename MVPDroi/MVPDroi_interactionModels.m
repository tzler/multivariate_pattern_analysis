function MVPDroi_interactionModels(cfgPath,iSubject,iAnalysis)

% This function runs the interaction models iAnalysis in
% participant iSubject

% ############# Set paths ############
load(cfgPath);
% set function paths
addpath(genpath(Cfg_MVPDroi.libraryPaths.mvpc));
addpath(genpath(Cfg_MVPDroi.libraryPaths.spm12));
rmpath(genpath(fullfile(Cfg_MVPDroi.libraryPaths.spm12,'external')));

% ############ Load data #############
subject = Cfg_MVPDroi.dataInfo.subjects(iSubject);
interactionModel = Cfg_MVPDroi.interactionModels(iAnalysis);
regionModelName = sprintf('sub%s_rmodel%02d',subject.ID,interactionModel.regionModel);
regionModel = load(fullfile(Cfg_MVPDroi.outputPaths.regionModel,regionModelName));

% add empty parameter fields for interactionModel functions that do not need
% parameters
if ~isfield(interactionModel,'parameters')
    interactionModel.parameters = [];
end


% ######## Estimate and assess interaction model ########
nRois = length(regionModel.preprocdata);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        results_temp = feval(interactionModel.functionHandle,interactionModel.parameters,regionModel.preprocdata{jRoi},regionModel.preprocdata{iRoi});
        nMeasures = length(results_temp);
        for iMeasure = 1:nMeasures % reformat with measures outside
            results{iMeasure}(iRoi,jRoi) = results_temp{iMeasure};
        end
    end
end
fprintf('\nInteraction model %d for subject %d completed.\n',iAnalysis,iSubject);

% ################ Save to file #############
 outputFilename = sprintf('sub%s_imodel%02d',subject.ID,iAnalysis);
 outputFilepath = fullfile(Cfg_MVPDroi.outputPaths.interactionModels,outputFilename);
 save(outputFilepath,'results','interactionModel','-v7.3');
