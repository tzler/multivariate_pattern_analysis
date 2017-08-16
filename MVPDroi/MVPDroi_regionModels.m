function MVPDroi_regionModels(cfgPath,iSubject)

% This function estimates the region models for participant iSubject

% ########### Set paths ##########
load(cfgPath);
% set function paths
addpath(genpath(Cfg_MVPDroi.libraryPaths.mvpd));
addpath(genpath(Cfg_MVPDroi.libraryPaths.spm12));
addpath(genpath(Cfg_MVPDroi.libraryPaths.signal));
addpath(genpath(Cfg_MVPDroi.libraryPaths.shared));
rmpath(genpath(fullfile(Cfg_MVPDroi.libraryPaths.spm12,'external')));

% ######### Simplify variable names ########
subject = Cfg_MVPDroi.dataInfo.subjects(iSubject);
preprocModels = Cfg_MVPDroi.preprocModels;
regionModels = Cfg_MVPDroi.regionModels;
outputPath = Cfg_MVPDroi.outputPaths.regionModels;

% ######## Load data ########
[volumes_control,sizeVolumeSpace] = MVPDlib_load(subject,preprocModels);

% ######## Estimate region models ########
nRuns = length(volumes_control);
nRois = length(subject.roiPaths);
nRegionModels = length(regionModels);
for iRoi = 1:nRois
    roi_temp = logical(spm_read_vols(spm_vol(subject.roiPaths{iRoi})));
    nVox = size(roi_temp,1)*size(roi_temp,2)*size(roi_temp,3);
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

