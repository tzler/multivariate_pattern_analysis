function nDims = MVPDroi_readDimsPCA(cfgPath)

% cfgPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/Cfg_MVPDroi.mat'

load(cfgPath);

%% Read number of dimensions for PCA models

cd(Cfg_MVPDroi.outputPaths.regionModels_base);
nSubjects =length(Cfg_MVPDroi.dataInfo.subjects);
nRegionModels = length(Cfg_MVPDroi.regionModels);

% find PCA models
multidimModels = [];
for iRegionModel = 1:nRegionModels
    for iStep = 1:length(Cfg_MVPDroi.regionModels(iRegionModel).steps)
        if ~isempty(strfind(Cfg_MVPDroi.regionModels(iRegionModel).steps(iStep).functionHandle,'PCA'))
           multidimModels = vertcat(multidimModels,iRegionModel); 
        end
    end
end

% extract the number of dimensions
for iSubject = 1:nSubjects
    for iRegionModel = 1:length(multidimModels)
        model_temp = load(sprintf('sub%s_rmodel%02d.mat',Cfg_MVPDroi.dataInfo.subjects(iSubject).ID,multidimModels(iRegionModel)));
        for iRegion = 1:length(model_temp.preprocdata)
            for iRun = 1:length(model_temp.preprocdata{iRegion})
                nDims{iRegionModel}(iSubject,iRegion,iRun) = size(model_temp.preprocdata{iRegion}{iRun}.train,1);
            end
        end
        clear('model_temp');
    end
end