clear;
Cfg_preproc.debug = false;

Cfg_preproc.tools = 'C:\stefano\github_repos\saxe\preproc';
Cfg_preproc.dataDir = 'C:\stefano\facesViewpoint\2_data_preproc';
Cfg_preproc.spm = 'C:\stefano\spm12';
% Cfg_preproc.art = '/mindhive/gablab/u/daeda/software/art/';
foldernames = dir(fullfile(Cfg_preproc.dataDir,'sub*'));

for iSubject = 1:length(foldernames)
	Cfg_preproc.subjectPath{iSubject} = fullfile(Cfg_preproc.dataDir,foldernames(iSubject).name);
end
addpath(Cfg_preproc.tools);
addpath(genpath(Cfg_preproc.spm));

Cfg_preproc.leaveOutFirstNVolumes = 4;
Cfg_preproc.numSlices = 63;
Cfg_preproc.tr = 2;
Cfg_preproc.sliceOrder = [1:2:63,2:2:62];
Cfg_preproc.referenceSlice = 63;
Cfg_preproc.voxelSize = [2 2 2];

Cfg_preproc.smoothingYN = 1;
Cfg_preproc.smoothingKernel = [5 5 5]; % 5 FWHM for multivariate

Cfg_preproc.anatomyFolderName = 'anat';
Cfg_preproc.anatomyFilter = 's*.nii';

timerStart = tic;

spmBatch_masterscript_connectivity(Cfg_preproc);

fprintf('\n\n\n------PREPROCESSING FINISHED------\n');
timerSplit = toc(timerStart);
fprintf('      %d h %d m %f s.\n\n\n', floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
