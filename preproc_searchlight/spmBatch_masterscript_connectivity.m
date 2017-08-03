function spmBatch_masterscript_connectivity(Cfg_preproc)

for iSubject = 1:1%length(Cfg_preproc.subjectPath)
    if Cfg_preproc.debug
        fprintf('WARNING: DEBUG MODE ACTIVE\n');
    end
    timerStart = tic;
    lastTimepoint = toc(timerStart);
    

    % find structural file
    Cfg_preproc.anatomyFolder = fullfile(Cfg_preproc.subjectPath{iSubject},Cfg_preproc.anatomyFolderName);
    cd(Cfg_preproc.anatomyFolder);
    filename = dir(Cfg_preproc.anatomyFilter);
    Cfg_preproc.anatomyFile = fullfile(Cfg_preproc.anatomyFolder,filename(1).name);
    clear('filename');

    % get 4d directories.
%     allfiles = dir(fullfile(Cfg_preproc.subjectPath{iSubject});
%     allfiles(~cellfun(@isempty,regexp({allfiles.name}, '^[.]')))=[];
%     dirFlag = [allfiles.isdir];
%     subRuns = allfiles(dirFlag);

    for iFolder = 1:length(Cfg_preproc.runFolderNames)
        Cfg_preproc.filesFolders{iFolder,1} = fullfile(Cfg_preproc.subjectPath{iSubject},Cfg_preproc.runFolderNames{iFolder});
    end


    %% Slice timing correction

    Cfg_sliceTimingCorrection.filesFolders = Cfg_preproc.filesFolders;
    Cfg_sliceTimingCorrection.filesFilter = 'f*.img';
    Cfg_sliceTimingCorrection.leaveOutFirstNVolumes =  Cfg_preproc.leaveOutFirstNVolumes;
    Cfg_sliceTimingCorrection.numSlices = Cfg_preproc.numSlices;
    Cfg_sliceTimingCorrection.tr = Cfg_preproc.tr;
    Cfg_sliceTimingCorrection.sliceOrder = Cfg_preproc.sliceOrder;
    Cfg_sliceTimingCorrection.referenceSlice = Cfg_preproc.referenceSlice;
    Cfg_sliceTimingCorrection.runYN = 1;

    spmBatch_sliceTimingCorrection(Cfg_sliceTimingCorrection);

    clear('Cfg_sliceTimingCorrection');

timerSplit = toc(timerStart);
fprintf('Subject %d, Slice Timing Correction: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);
    

    %% Spatial realignment
    % Estimate all images, reslice mean image only

    Cfg_spatialRealignment.filesFolders = Cfg_preproc.filesFolders;
    Cfg_spatialRealignment.filesFilter = 'a*.img';
    Cfg_spatialRealignment.leaveOutFirstNVolumes = 0;
    Cfg_spatialRealignment.debug = Cfg_preproc.debug;
    Cfg_spatialRealignment.runYN = 1;

    spmBatch_spatialRealignment(Cfg_spatialRealignment);

    clear('Cfg_spatialRealignment');

timerSplit = toc(timerStart);
fprintf('Subject %d, Spatial Realignment: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);

    %% Coregistration

    Cfg_coregistration.fileFolder = Cfg_preproc.filesFolders{1};
    Cfg_coregistration.filesFilter = 'mean*.img';
    Cfg_coregistration.anatomyFile = Cfg_preproc.anatomyFile;
    Cfg_coregistration.runYN = 1;

    spmBatch_coregistration(Cfg_coregistration);

    clear('Cfg_coregistration');

timerSplit = toc(timerStart);
fprintf('Subject %d, Coregistration: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);


    %% Segmentation (& Normalization Estimation)

    Cfg_segmentation.anatomyFile = Cfg_preproc.anatomyFile;
    Cfg_segmentation.tpm = fullfile(Cfg_preproc.spm,'tpm','TPM.nii');
    Cfg_segmentation.runYN = 1;

    spmBatch_segmentation(Cfg_segmentation);

    

    clear('Cfg_segmentation');

timerSplit = toc(timerStart);
fprintf('Subject %d, Segmentation: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);


    %% Normalization (Write Normalization & Realignment to: functional files)

    Cfg_normalization.voxelSize = Cfg_preproc.voxelSize;

    Cfg_normalization.anatomyFolder = Cfg_preproc.anatomyFolder;
    Cfg_normalization.filesFolders = Cfg_preproc.filesFolders;

    Cfg_normalization.filesFilter = 'a*.img'; % slice timerSplit corrected functional volumes
    Cfg_normalization.debug = Cfg_preproc.debug;
    Cfg_normalization.runYN = 1;

    spmBatch_normalization(Cfg_normalization);



    clear('Cfg_normalization');

timerSplit = toc(timerStart);
fprintf('Subject %d, Normalization of functionals: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);


    %% Normalization (Write Normalization & Realignment to: mean functional)

    Cfg_normalization.voxelSize = Cfg_preproc.voxelSize;

    Cfg_normalization.anatomyFolder = Cfg_preproc.anatomyFolder;
    Cfg_normalization.filesFolders = {Cfg_preproc.filesFolders{1}}; % must be cellstring, call with {Cfg_preproc.filesFolders{1}} or Cfg_preproc.filesFolders(1)

    Cfg_normalization.filesFilter = 'mean*.img'; % slice timerSplit corrected and realigned mean functional volume
    Cfg_normalization.debug = Cfg_preproc.debug;
    Cfg_normalization.runYN = 1;

    spmBatch_normalization(Cfg_normalization);

    clear('Cfg_normalization');

timerSplit = toc(timerStart);
fprintf('Subject %d, Normalization of mean image: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);

    %% Smoothing

    Cfg_smoothing.smoothingKernel = Cfg_preproc.smoothingKernel;
    Cfg_smoothing.runYN = Cfg_preproc.smoothingYN;
    Cfg_smoothing.filesFolders = Cfg_preproc.filesFolders;
    Cfg_smoothing.filesFilter = 'wa*.img';

    spmBatch_smoothing(Cfg_smoothing);

    clear('Cfg_smoothing');

timerSplit = toc(timerStart);
fprintf('Subject %d, Smoothing: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
lastTimepoint = toc(timerStart);



%% Generate missing tissue probablity  (c6, empty space)

Cfg_probabilityGenMask.filter = '(^c)(.*\.nii)'; % must be RegEx filter
Cfg_probabilityGenMask.erodePrefix = 2;
Cfg_probabilityGenMask.newPrefix = 'c6';
Cfg_probabilityGenMask.path = Cfg_preproc.anatomyFolder;

spmBatch_probabilityMaskGen(Cfg_probabilityGenMask);

clear('Cfg_probabilityGenMask');


    %% Normalization (Write Normalization to: tissue masks)

    Cfg_normalization.voxelSize = Cfg_preproc.voxelSize;

    Cfg_normalization.anatomyFolder = Cfg_preproc.anatomyFolder;
    Cfg_normalization.filesFolders = {Cfg_preproc.anatomyFolder}; % must be cellstring

    Cfg_normalization.filesFilter = 'c*.nii'; 
    Cfg_normalization.debug = Cfg_preproc.debug;
    Cfg_normalization.runYN = 1;

    spmBatch_normalization(Cfg_normalization);

    clear('Cfg_normalization');


%% Normalize the probability distribution of the standard-space probability masks
% Produces standard-space segmentation masks where sum(c*.nii) = 1 for each standard-space voxel

Cfg_probabilityNormalization.filter = '(^wc)(.*\.nii)'; % must be RegEx filter
Cfg_probabilityNormalization.newPrefix = 'p';
Cfg_probabilityNormalization.path = Cfg_preproc.anatomyFolder;

spmBatch_probabilityNormalization(Cfg_probabilityNormalization);

clear('Cfg_probabilityNormalization');


    %% Binerize (Normalized Grey matter mask)

    Cfg_maskBinerize.filter = '(^pwc1)(.*\.nii)'; % must be RegEx filter
    Cfg_maskBinerize.newPrefix = 'binary_'; % only used for individual binarization
    Cfg_maskBinerize.threshold = 1; % only used for conservative binarization
    Cfg_maskBinerize.path = Cfg_preproc.anatomyFolder;

    spmBatch_maskBinerize(Cfg_maskBinerize,'liberal','individual');

    clear('Cfg_maskBinerize');

    %% Binerize (Normalized White matter & Normalized CSF masks)

    Cfg_maskBinerize.filter = '(^pwc2|^pwc3)(.*\.nii)'; % must be RegEx filter
    Cfg_maskBinerize.newPrefix = 'binary_'; % only used for individual binarization
    Cfg_maskBinerize.catName = 'binary_combined_WM_CSF'; % only used for concatenate binarization
    Cfg_maskBinerize.threshold = 1; % only used for conservative binarization
    Cfg_maskBinerize.path = Cfg_preproc.anatomyFolder;

    spmBatch_maskBinerize(Cfg_maskBinerize,'conservative','all');

    clear('Cfg_maskBinerize');


    %% Erode white matter, CSF, combined masks

    Cfg_maskSwell.filter = '(^binary_pwc2|^binary_pwc3|^binary_combined_WM_CSF)(.*\.nii)'; % must be RegEx filter
    Cfg_maskSwell.newPrefix = 'eroded_';
    Cfg_maskSwell.path = Cfg_preproc.anatomyFolder;

    spmBatch_maskSwell(Cfg_maskSwell,-1); % positive values swell mask, negative erode mask.

    clear('Cfg_maskSwell');


%% Create whole brain mask for ART

    Cfg_maskBinerize.filter = '(^pwc1|^pwc2|^pwc3)(.*\.nii)'; % must be RegEx filter
    Cfg_maskBinerize.catName = 'mask_wholebrain'; % only used for concatenate binarization
    Cfg_maskBinerize.path = Cfg_preproc.anatomyFolder;

    spmBatch_maskBinerize(Cfg_maskBinerize,'liberal','concatenate');

    clear('Cfg_maskBinerize');


%     %% Swell wholebrain mask
% 
%     Cfg_maskSwell.filter = '(^wholebrain)(.*\.nii)'; % must be RegEx filter
%     Cfg_maskSwell.newPrefix = 'mask_';
%     Cfg_maskSwell.path = Cfg_preproc.anatomyFolder;
% 
%     spmBatch_maskSwell(Cfg_maskSwell,1); % positive values swell mask, negative erode mask.
% 
%     clear('Cfg_maskSwell');


%% This functionality replaced with ART - manual
% 
%     %% ART
%     % make Cfg
%     Cfg_artMakeCfg.subjectPath = Cfg_preproc.subjectPath{iSubject};
%     Cfg_artMakeCfg.filesFolders = Cfg_preproc.filesFolders;
%     Cfg_artMakeCfg.runs = subRuns;
%     Cfg_artMakeCfg.maskPath = Cfg_preproc.anatomyFolder;
%     Cfg_artMakeCfg.maskFilter = '(^mask_wholebrain)(.*\.nii)'; % must be RegEx filter
%     Cfg_artMakeCfg.filesFilter = 'wa*.nii'; % Take normalized fuctionals
% 
%     artFilePath = spmBatch_artMakeCfg(Cfg_artMakeCfg);
% 
% 
%     addpath(Cfg_preproc.art);
%     % run ART
%     art(artFilePath);
%     rmpath(Cfg_preproc.art);
%     clear('Cfg_artMakeCfg');
% 
% timerSplit = toc(timerStart);
% fprintf('Subject %d, ART: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
% lastTimepoint = toc(timerStart);


%% ART - manual

    Cfg_motion.zThreshold = 5; % global signal threshold
    Cfg_motion.euclidianThreshold = 1; % motion threshold
    Cfg_motion.subjectPath = Cfg_preproc.subjectPath{iSubject};
    Cfg_motion.filesFolders = Cfg_preproc.filesFolders;
    Cfg_motion.runs = Cfg_preproc.filesFolders;
    Cfg_motion.maskPath = Cfg_preproc.anatomyFolder;
    Cfg_motion.maskFilter = '(^mask_wholebrain)(.*\.nii)'; % must be RegEx filter
    Cfg_motion.filesFilter = 'wa*.hdr'; % Take normalized fuctionals

    spmBatch_motion(Cfg_motion);

    clear('Cfg_motion');

    %% Renames Masks
    cd(Cfg_preproc.subjectPath{iSubject});
    [~, subjectName, ~] = fileparts(pwd);
    cd(Cfg_preproc.anatomyFolderName);
    inputfiles = {'eroded_binary_pwc2*.nii','eroded_binary_pwc3*.nii','eroded_binary_combined_WM_CSF*.nii'};
    outputfiles = {sprintf('mask_whitematter_%s.nii',subjectName), sprintf('mask_csf_%s.nii',subjectName), sprintf('mask_combWMCSF_%s.nii',subjectName)};
    for iFile = 1:numel(inputfiles)
        fname = dir(inputfiles{iFile});
        movefile(fname(1).name, outputfiles{iFile});
    end
    clear('subjectName', 'inputfiles', 'outputfiles', 'fname');

    %% move mean functional files
    cd(Cfg_preproc.filesFolders{1});
    files = dir('*mean*');
    for iFile=1:numel(files)
        fname = fullfile(files(iFile).name);
        movefile(fname, Cfg_preproc.anatomyFolder);
    end

    clear('files', 'fname');

    %% Clear job-specific information

    clear('Cfg_preproc.subjectPath','Cfg_preproc.anatomyFolder','Cfg_preproc.filesFolders')


timerSplit = toc(timerStart);
fprintf('Subject %d, Cleanup: %d h %d m %f s.\n', iSubject, floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));
fprintf('\n\n------Subject %d Finished------\n', iSubject)
fprintf('      %d h %d m %f s.\n\n\n', floor((timerSplit-lastTimepoint)/3600), floor(rem(timerSplit-lastTimepoint,3600)/60), rem(timerSplit-lastTimepoint, 60));

end