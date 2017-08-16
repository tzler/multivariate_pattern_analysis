function [volumes_control,sizeVolumeSpace] = MVPDlib_load(subject,preprocModels)

functionalPaths = subject.functionalPaths;
nRuns = length(functionalPaths);
for iRun = 1:nRuns
    %% Load data
    % obtain functional volumes
    nVolumes = length(functionalPaths{iRun});
    for iVolume = 1:nVolumes
        volumes(:,:,:,iVolume) = spm_read_vols(spm_vol(functionalPaths{iRun}{iVolume})); % Load volume
    end
    % reshape volumes
    sizeVolumeSpace = size(volumes);
    volumes2 = reshape(volumes,sizeVolumeSpace(1)*sizeVolumeSpace(2)*sizeVolumeSpace(3),sizeVolumeSpace(4));
    clear('volumes');
    %% Generate regressors of no interests
    nSteps = length(preprocModels.steps);
    for iStep = 1:nSteps
        volumes2 = feval(preprocModels.steps(iStep).functionHandle,preprocModels.steps(iStep).parameters,subject,volumes2,iRun);
    end   
    volumes_control{iRun} = volumes2;
    clear('volumes2');
end
sizeVolumeSpace(4) = [];
