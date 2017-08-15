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
    regressorsNI = ones(nVolumes,1);
    for iStep = 1:nSteps
	temp = feval(preprocModels.steps(iStep).functionHandle,preprocModels.steps(iStep).parameters,subject,volumes2);
        regressorsNI = [regressorsNI,temp];
        clear('temp');
    end
    Y = volumes2';
    clear('volumes2');
    b = mldivide(regressors_NI,Y);
    R = Y-X*b;
    volumes_control{iRun} = R';
end
sizeVolumeSpace(4) = [];
