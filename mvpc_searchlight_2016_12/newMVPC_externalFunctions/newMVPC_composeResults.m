function newMVPC_composeResults(cfgPath)

% cfgPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/Cfg_mvpcRoi.mat'

load(cfgPath);

%% Read region models properties

cd(Cfg_mvpcRoi.outputPaths.regionModels_base);
nSubjects =length(Cfg_mvpcRoi.dataInfo.subjects);
nRegionModels = length(Cfg_mvpcRoi.regionModels);

multidimModels = [];
for iRegionModel = 1:nRegionModels
    for iStep = 1:length(Cfg_mvpcRoi.regionModels(iRegionModel).steps)
        if ~isempty(strfind(Cfg_mvpcRoi.regionModels(iRegionModel).steps(iStep).functionHandle,'PCA'))
           multidimModels = vertcat(multidimModels,iRegionModel); 
        end
    end
end
        
for iSubject = 1:nSubjects
    for iRegionModel = 1:length(multidimModels)
        model_temp = load(sprintf('sub%s_rmodel%02d.mat',Cfg_mvpcRoi.dataInfo.subjects(iSubject).ID,multidimModels(iRegionModel)));
        for iRegion = 1:length(model_temp.preprocdata)
            for iRun = 1:length(model_temp.preprocdata{iRegion})
                nDim{iRegionModel}(iSubject,iRegion,iRun) = size(model_temp.preprocdata{iRegion}{iRun}.train,1);
            end
        end
        clear('model_temp');
    end
end

%% Read results

cd(Cfg_mvpcRoi.outputPaths.interactionModels_base);
nSubjects =length(Cfg_mvpcRoi.dataInfo.subjects);
nInteractionModels = length(Cfg_mvpcRoi.interactionModels);

% find nnet models
nnetModels = [];
for iInteractionModel = 1:nInteractionModels
    if ~isempty(strfind(Cfg_mvpcRoi.interactionModels(iInteractionModel).functionHandle,'neuralNet'))
        nnetModels = vertcat(nnetModels,iInteractionModel);
    end
end

for iSubject = 1:nSubjects
    for iInteractionModel = 1:nInteractionModels
        if iInteractionModel <3
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_mvpcRoi.dataInfo.subjects(iSubject).ID,iInteractionModel));
            connectivityMatrices_r{iInteractionModel}(:,:,iSubject) = model_temp.results;
            clear('model_temp');  
        elseif iInteractionModel ==3
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_mvpcRoi.dataInfo.subjects(iSubject).ID,iInteractionModel));
            connectivityMatrices_r{iInteractionModel}(:,:,iSubject) = sqrt(model_temp.results);
            clear('model_temp');            
        else
            model_temp = load(sprintf('sub%s_imodel%02d.mat',Cfg_mvpcRoi.dataInfo.subjects(iSubject).ID,iInteractionModel));
            connectivityMatrices_r{iInteractionModel}(:,:,iSubject) = sqrt(model_temp.results.connectivityMatrix);
            weights{iInteractionModel} = model_temp.results.parameters;
            clear('model_temp');
        end
    end
end




