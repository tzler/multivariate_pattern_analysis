function newMvpc_preproc(cfgPath,iSubject)

% This function estimates the region models for participant iSubject

% ########### Set paths ##########
load(cfgPath);
% set workspace paths
addpath(Cfg_mvpcRoi.dataInfo.project);
% set function paths
addpath(genpath(Cfg_mvpcRoi.libraryPaths.mvpc));
addpath(genpath(Cfg_mvpcRoi.libraryPaths.spm12));
rmpath(genpath(fullfile(Cfg_mvpcRoi.libraryPaths.spm12,'external')));

% ######### Simplify variable names ########
subject = Cfg_mvpcRoi.dataInfo.subjects(iSubject);
nPCs_compcorr = Cfg_mvpcRoi.compcorr.nPCs;
regionModels = Cfg_mvpcRoi.regionModels;
outputPath = Cfg_mvpcRoi.outputPaths.regionModels_base;

% ######## Load data ########
[volumes_control,sizeVolumeSpace] = mvpc_load_compcorr(subject.functionalPaths,subject.compcorrMask,nPCs_compcorr);

% ######## Estimate region models ########
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

for iRegionModel = 1:nRegionModels
    filename = sprintf('sub%s_rmodel%02d',subject.ID,iRegionModel);
    preprocdata = preprocessedData{iRegionModel};
    preprocinfo = regionModels(iRegionModel);
    save(fullfile(outputPath,filename),'preprocdata','preprocinfo','-v7.3');
    clear('filename','preprocdata','preprocinfo');
end
 fprintf('\nRegion models saved to disk.\n',iRoi);

