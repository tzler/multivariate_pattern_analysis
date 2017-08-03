function wrapper_preproc_facesVoices_parallel_art(iSubject)
	Cfg_preproc.debug = false;

	Cfg_preproc.tools = '/mindhive/saxelab3/anzellotti/facesVoices_art2/preprocessing_facesVoices_art';
	Cfg_preproc.dataDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF';
	Cfg_preproc.spm = '/mindhive/saxelab3/anzellotti/software/spm12';
	foldernames = dir(fullfile(Cfg_preproc.dataDir,'sub*'));


	Cfg_preproc.subjectPath{1} = fullfile(Cfg_preproc.dataDir,foldernames(iSubject).name);

	addpath(Cfg_preproc.tools);
	addpath(genpath(Cfg_preproc.spm));

	
Cfg_preproc.leaveOutFirstNVolumes = 4;
Cfg_preproc.numSlices = 43;
Cfg_preproc.tr = 2; % in seconds
Cfg_preproc.sliceOrder = [1:2:43 2:2:42];
Cfg_preproc.referenceSlice = 43;
Cfg_preproc.voxelSize = [2 2 2];

	Cfg_preproc.smoothingYN = 1;
	Cfg_preproc.smoothingKernel = [4 4 4]; % 4 FWHM for multivariate

	Cfg_preproc.anatomyFolderName = 'anatomy1';
	Cfg_preproc.anatomyFilter = 's*.img';
    Cfg_preproc.runFolderNames = {'loc1','loc2','run1','run2','run2','run3','run4','run5'};
    
	timerStart = tic;
    lastTimepoint = toc(timerStart);

	spmBatch_masterscript_connectivity(Cfg_preproc);
	
	fprintf('\n\n\n------PREPROCESSING FINISHED------\n');
	timerSplit = toc(timerStart);
	fprintf('Subject: %d\n      %d h %d m %f s.\n\n\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));

end
