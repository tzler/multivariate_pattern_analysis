function volumes2 = loadDenoise_compcorr(parameters,subject,volumes2,iRun)

nPCs = parameters.nPCs;
controlPath = subject.compcorrMaskPaths;
controlROI = logical(spm_read_vols(spm_vol(controlPath)));
volumes_control = zeros(size(volumes2));
nVoxRoi = size(controlROI,1)*size(controlROI,2)*size(controlROI,3);
if nVoxRoi~=size(volumes2,1)
    warning('Number of voxels in compcorr mask does not match the number of functional voxels.');
end
controlROI2 = reshape(controlROI,nVoxRoi,1);
controlData = volumes2(controlROI2,:);
% center for svd
controlData_center = controlData - repmat(mean(controlData,2),1,size(controlData,2));
% calculate svd
[U_control,S_control,V_control] = svd(controlData_center');
% extract scores for the PCs that account for most variance
controlData_reduced = U_control(:,1:nPCs)*S_control(1:nPCs,1:nPCs);
% make regressors of no interest
nVolumes = size(volumes2,2);
regressors_NI = [ones(nVolumes,1),controlData_reduced];
Y = volumes2';
clear('volumes2');
b = mldivide(regressors_NI,Y);
R = Y-regressors_NI*b;
volumes2 = R';