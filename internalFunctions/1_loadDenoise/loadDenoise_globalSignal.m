function volumes2 = loadDenoise_globalSignal(parameters, subject, volumes2,iRun)

controlPath = subject.globalSignalMaskPaths;
controlROI = logical(spm_read_vols(spm_vol(controlPath)));
volumes_control = zeros(size(volumes2));
nVoxRoi = size(controlROI,1)*size(controlROI,2)*size(controlROI,3);
if nVoxRoi ~= size(volumes2,1)
        fprintf('\nNumber of voxels in global signal mask does not match the number of functional voxels.');
end
controlROI2 = reshape(controlROI,nVoxRoi,1);
controlData = volumes2(controlROI2,:);
globalSignal = mean(controlData,1);
if size(globalSignal,2)>1
    globalSignal = globalSignal';
end
nVolumes = size(volumes2,2);
regressors_NI = [ones(nVolumes,1),globalSignal];
Y = volumes2';
clear('volumes2');
b = mldivide(regressors_NI,Y);
R = Y-regressors_NI*b;
volumes2 = R';
