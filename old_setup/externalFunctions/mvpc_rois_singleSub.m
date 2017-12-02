function results = mvpc_rois_singleSub(subject,nPCs,regionModels,interactionModels)

%% ######## Load data ########
[volumes_control,sizeVolumeSpace] = mvpc_load_compcorr(subject.functionalPaths,subject.compcorrMask,nPCs);


% ######## Estimate models of the regions' responses in isolation ########
nRuns = length(volumes_control);
nRois = length(subject.roiPaths);
nRegionModels = length(regionModels);
for iRoi = 1:nRois
    roi_temp = logical(spm_read_vols(spm_vol(subject.roiPaths{iRoi})));
    nVox = size(roi_temp,1)*size(roi_temp,2)*size(roi_temp,3);
    if nVox~=sizeVolumeSpace(1)*sizeVolumeSpace(2)*sizeVolumeSpace(3)        
        fprintf('WARNING: size of ROI %d in subject %s does not match size of functional data.',iRoi,subject.ID);
    end
    roi_temp2 = reshape(roi_temp,nVox,1);
    for iRun = 1:nRuns
        data{iRun} = volumes_control{iRun}(roi_temp2,:);
    end
    for iRegionModel = 1:nRegionModels
        nSteps = length(regionModels(iRegionModel).steps);
        input_temp = data;
        for iStep = 1:nSteps
            preprocessedData_temp{iStep} = feval(regionModels(iRegionModel).steps(iStep).functionHandle,regionModels(iRegionModel).steps(iStep).parameters,input_temp);
            clear('input_temp');
            input_temp = preprocessedData_temp{iStep};
        end
        preprocessedData{iRegionModel}{iRoi} = preprocessedData_temp{nSteps};
        clear('preprocessedData_temp');
    end
    clear('data');
    fprintf('\nRegion models for ROI %d completed.\n',iRoi);
end

% ######## Estimate models of the interactions ######## 
nInteractionModels = length(interactionModels);
for iInteractionModel = 1:nInteractionModels
    results{iInteractionModel} = feval(interactionModels(iInteractionModel).functionHandle,interactionModels(iInteractionModel).parameters,preprocessedData{interactionModels(iInteractionModel).regionModel});
    fprintf('\nInteraction model %d completed.\n',iInteractionModel);
end
    
end
