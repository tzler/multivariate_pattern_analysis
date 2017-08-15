function matlabbatch = spmBatch_preproc_spatialRealignment(Cfg_spatialRealignment)

% Select the files that have to be spatially realigned

nFilesFolders = size(Cfg_spatialRealignment.filesFolders,1);

files{nFilesFolders} = []; % preallocate cell
for iRun = 1:nFilesFolders
    cd(Cfg_spatialRealignment.filesFolders{iRun});
    files{iRun} = dir(Cfg_spatialRealignment.filesFilter);
end

filePaths{nFilesFolders,1} = []; % preallocate cell
for iRun = 1:nFilesFolders
    filePathsTemp{length(files{iRun})-Cfg_spatialRealignment.leaveOutFirstNVolumes} = [];  % preallocate cell
    for iFile = (1+Cfg_spatialRealignment.leaveOutFirstNVolumes):length(files{iRun})
        filePathsTemp{iFile-Cfg_spatialRealignment.leaveOutFirstNVolumes} = strcat(fullfile(Cfg_spatialRealignment.filesFolders{iRun},files{iRun}(iFile,1).name),',1');
    end
    filePaths{iRun} = filePathsTemp';
    clear('filePathsTemp');
end

% data paths
for iRun = 1:nFilesFolders
    matlabbatch{1}.spm.spatial.realign.estwrite.data(1,iRun) = filePaths(iRun);  %'filename,1' - path of all files from the run to be analyzed
end

% estimate options
if Cfg_spatialRealignment.debug
    sprintf('DEBUG\n');
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.2
else
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
end
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;

if Cfg_spatialRealignment.debug
    sprintf('DEBUG\n');
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 1;
else
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 7;
end

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};

% reslice options
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1]; % [0 1] = create mean images only. [1 1] = create all imgs + mean. [2 1] = ??

if Cfg_spatialRealignment.debug
    sprintf('DEBUG\n');
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 1;
else
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 7;
end

matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

% run
if Cfg_spatialRealignment.runYN
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end
