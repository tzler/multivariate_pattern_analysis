function MVPDroi_composeResults(cfgPath)

% cfgPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/Cfg_MVPDroi.mat'

load(cfgPath);

%% Read results

cd(Cfg_MVPDroi.outputPaths.interactionModels);
nSubjects =length(Cfg_MVPDroi.dataInfo.subjects);
nInteractionModels = length(Cfg_MVPDroi.interactionModels);

% find nnet models
nnetModels = [];
for iInteractionModel = 1:nInteractionModels
    if ~isempty(strfind(Cfg_MVPDroi.interactionModels(iInteractionModel).functionHandle,'neuralNet'))
        nnetModels = vertcat(nnetModels,iInteractionModel);
    end
end

for iSubject = 1:nSubjects
    for iInteractionModel = 1:nInteractionModels
        if iInteractionModel <3
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_MVPDroi.dataInfo.subjects(iSubject).ID,iInteractionModel));
            dependenceMatrices_r{iInteractionModel}(:,:,iSubject) = model_temp.results;
            clear('model_temp');  
        elseif iInteractionModel ==3
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_MVPDroi.dataInfo.subjects(iSubject).ID,iInteractionModel));
            dependenceMatrices_r{iInteractionModel}(:,:,iSubject) = sqrt(model_temp.results);
            clear('model_temp');            
        else
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_MVPDroi_dataInfo.subjects(iSubject).ID,iInteractionModel));
            dependenceMatrices_r{iInteractionModel}(:,:,iSubject) = sqrt(model_temp.results.dependenceMatrix);
            weights{iInteractionModel}{iSubject} = model_temp.results.parameters;
            clear('model_temp');
        end
    end
end




