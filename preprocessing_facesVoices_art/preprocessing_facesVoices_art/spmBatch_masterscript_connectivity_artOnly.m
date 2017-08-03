function spmBatch_masterscript_connectivity_artOnly(Cfg_preproc)

for iSubject = 1:length(Cfg_preproc.subjectPath)
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
    Cfg_motion.euclidianThreshold = 1.15; % motion threshold
    Cfg_motion.subjectPath = Cfg_preproc.subjectPath{iSubject};
    Cfg_motion.filesFolders = Cfg_preproc.filesFolders;
    Cfg_motion.runs = Cfg_preproc.filesFolders;
    Cfg_motion.maskPath = Cfg_preproc.anatomyFolder;
    Cfg_motion.maskFilter = '(^mask_wholebrain)(.*\.nii)'; % must be RegEx filter
    Cfg_motion.filesFilter = 'wa*.img'; % Take normalized fuctionals

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
