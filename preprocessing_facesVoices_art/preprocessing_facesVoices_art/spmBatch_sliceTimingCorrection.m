function matlabbatch = spmBatch_sliceTimingCorrection(Cfg_sliceTimingCorrection)

% select the files for which slice-timing needs to be corrected

files{size(Cfg_sliceTimingCorrection.filesFolders,1)} = [];
for iRun = 1:size(Cfg_sliceTimingCorrection.filesFolders,1)
    cd(Cfg_sliceTimingCorrection.filesFolders{iRun});
    files{iRun} = dir(Cfg_sliceTimingCorrection.filesFilter);
end

filePaths{size(Cfg_sliceTimingCorrection.filesFolders,1)} = []; % preallocate cell
for iRun = 1:size(Cfg_sliceTimingCorrection.filesFolders,1)
	filePathsTemp{length(files{iRun})-Cfg_sliceTimingCorrection.leaveOutFirstNVolumes} = []; % preallocate cell
    for iFile = (1+Cfg_sliceTimingCorrection.leaveOutFirstNVolumes):length(files{iRun})
        filePathsTemp{iFile-Cfg_sliceTimingCorrection.leaveOutFirstNVolumes} = strcat(fullfile(Cfg_sliceTimingCorrection.filesFolders{iRun},files{iRun}(iFile,1).name),',1');
    end
    filePaths{iRun} = filePathsTemp';
    clear('filePathsTemp');
end

% data paths
for iFile = 1:size(Cfg_sliceTimingCorrection.filesFolders,1)
    matlabbatch{1}.spm.temporal.st.scans{1,iFile} = filePaths{iFile}; % paths of the realigned files
end

% set parameters
matlabbatch{1}.spm.temporal.st.nslices = Cfg_sliceTimingCorrection.numSlices;
matlabbatch{1}.spm.temporal.st.tr = Cfg_sliceTimingCorrection.tr;
matlabbatch{1}.spm.temporal.st.ta = matlabbatch{1}.spm.temporal.st.tr - matlabbatch{1}.spm.temporal.st.tr/matlabbatch{1}.spm.temporal.st.nslices;
matlabbatch{1}.spm.temporal.st.so = Cfg_sliceTimingCorrection.sliceOrder;  % slice order
matlabbatch{1}.spm.temporal.st.refslice = Cfg_sliceTimingCorrection.referenceSlice;
matlabbatch{1}.spm.temporal.st.prefix = 'a';



% run
if Cfg_sliceTimingCorrection.runYN
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end