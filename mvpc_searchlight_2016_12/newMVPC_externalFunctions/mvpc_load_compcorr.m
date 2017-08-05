function [volumes_control,sizeVolumeSpace] = mvpc_load_compcorr(subject,compCorrParams)

volumePaths = subject.functionalPaths;
controlPath = subject.compCorrMask;
nPCs = compCorrParams.nPCs;

%% Load data and remove noise using compcorr
nRuns = length(volumePaths);
for iRun = 1:nRuns
    % obtain functional volumes
    nVolumes = length(volumePaths{iRun});
    for iVolume = 1:nVolumes
        volumes(:,:,:,iVolume) = spm_read_vols(spm_vol(volumePaths{iRun}{iVolume})); % Load volume
    end
    globalSignal = squeeze(mean(mean(mean(volumes,3),2),1));
    % reshape volumes
    sizeVolumeSpace = size(volumes);
    volumes2 = reshape(volumes,sizeVolumeSpace(1)*sizeVolumeSpace(2)*sizeVolumeSpace(3),sizeVolumeSpace(4));
    clear('volumes');
    % remove noise from all voxels if control ROI if provided
    volumes_control{iRun} = zeros(size(volumes2));
    controlROI = logical(spm_read_vols(spm_vol(controlPath)));
    nVoxRoi = size(controlROI,1)*size(controlROI,2)*size(controlROI,3);
    if nVoxRoi ~=(sizeVolumeSpace(1)*sizeVolumeSpace(2)*sizeVolumeSpace(3))
        fprintf('WARNING: size of control ROI and size of functional volumes do not match.');
    end
    controlROI2 = reshape(controlROI,nVoxRoi,1);
    controlData = volumes2(controlROI2,:);
    % center for svd
    controlData_center = controlData - repmat(mean(controlData,2),1,size(controlData,2));
    % calculate svd
    [U_control,S_control,V_control] = svd(controlData_center');
    % extract scores for the PCs that account for most variance
    controlData_reduced = (U_control(:,1:nPCs)*S_control(1:nPCs,1:nPCs))';

    % if requested, load motion regressors
    if strcmp(Cfg_searchlight.searchlightInfo.compcorr.includeMotionRegressors,'yes')
	    motionRegressors = load(subject.motionRegressorsPaths{iRun})
    end					  
    % for each voxel in the brain regress out the PCs in the control
    % data
    X = [ones(nVolumes,1) controlData_reduced' motionRegressors globalSignal];
    Y = volumes2';
    b = mldivide(X,Y);
    R = Y-X*b;
    volumes_control{iRun} = R';
    clear('volumes2');
end
sizeVolumeSpace(4) = [];
