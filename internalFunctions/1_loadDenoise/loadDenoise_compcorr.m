function controlData_reduced = loadDenoise_compcorr(parameters, subject, volumes2)

nPCs = parameters.nPCs;
controlPath = subject.compcorrMask;
controlROI = logical(spm_read_vols(spm_vol(controlPath)));
volumes_control{iRun} = zeros(size(volumes2));
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
controlData_reduced = U_control(:,1:nPCs)*S_control(1:nPCs,1:nPCs);
