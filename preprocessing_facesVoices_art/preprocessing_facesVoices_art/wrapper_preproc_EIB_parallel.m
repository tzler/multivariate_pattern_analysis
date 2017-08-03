function wrapper_preproc_EIB_parallel(iSubject)
	Cfg_preproc.debug = false;

	Cfg_preproc.tools = '/mindhive/gablab/u/daeda/analyses/EIB/preproctoolsspm';
	Cfg_preproc.dataDir = '/mindhive/gablab/u/daeda/analyses/EIB/EIB_data';
	Cfg_preproc.spm = '/mindhive/gablab/u/daeda/software/spm12';
	Cfg_preproc.art = '/mindhive/gablab/u/daeda/software/art/';
	foldernames = dir(fullfile(Cfg_preproc.dataDir,'SAX_EIB_*'));


	Cfg_preproc.subjectPath{1} = fullfile(Cfg_preproc.dataDir,foldernames(iSubject).name);

	addpath(Cfg_preproc.tools);
	addpath(genpath(Cfg_preproc.spm));

	Cfg_preproc.leaveOutFirstNVolumes = 4;  
	Cfg_preproc.numSlices = 32;
	Cfg_preproc.tr = 2; 
	Cfg_preproc.sliceOrder = [2:2:32,1:2:31];
	Cfg_preproc.referenceSlice = 32;
	Cfg_preproc.voxelSize = [2 2 2]; % default is [2 2 2]

	Cfg_preproc.smoothingYN = 1;
	Cfg_preproc.smoothingKernel = [5 5 5]; % 5 FWHM for multivariate

	Cfg_preproc.anatomyFolderName = 'anat';
	Cfg_preproc.anatomyFilter = 's*.img';

	timerStart = tic;
    lastTimepoint = toc(timerStart);

	spmBatch_masterscript_connectivity(Cfg_preproc);
	
	fprintf('\n\n\n------PREPROCESSING FINISHED------\n');
	timerSplit = toc(timerStart);
	fprintf('Subject: %d\n      %d h %d m %f s.\n\n\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));

end
