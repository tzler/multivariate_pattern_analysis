function preprocessedData = MVPDsearchlight_applyRegionModels(data,regionModels)

nRegionModels = length(regionModels);
for iRegionModel = 1:nRegionModels
    nSteps = length(regionModels(iRegionModel).steps);
    input_temp = data;
    for iStep = 1:nSteps
        preprocessedData_temp{iStep} = feval(regionModels(iRegionModel).steps(iStep).functionHandle,regionModels(iRegionModel).steps(iStep).parameters,input_temp);
        clear('input_temp');
        input_temp = preprocessedData_temp{iStep};
    end
    preprocessedData{iRegionModel} = preprocessedData_temp{nSteps};
    clear('preprocessedData_temp');
end
