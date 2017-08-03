function matlabbatch = spmBatch_smoothing(Cfg_smoothing)

files{size(Cfg_smoothing.filesFolders,1)} = []; % preallocate cell
for iRun = 1:size(Cfg_smoothing.filesFolders,1)
    
        cd(Cfg_smoothing.filesFolders{iRun});
        files{iRun} = dir(Cfg_smoothing.filesFilter);

        filePaths{length(files{iRun}),1} = []; % preallocate cell
        for iVol = 1:length(files{iRun})
            filePaths{iVol,1} = strcat(fullfile(Cfg_smoothing.filesFolders{iRun},files{iRun}(iVol,1).name),',1');
        end
        
        % data path
        matlabbatch{iRun}.spm.spatial.smooth.data = cellstr(filePaths);
        % info and options
        matlabbatch{iRun}.spm.spatial.smooth.fwhm = Cfg_smoothing.smoothingKernel;      %<----------------------------------------------THIS PART DEPENDS ON YOUR TASTE
        matlabbatch{iRun}.spm.spatial.smooth.dtype = 0;
        matlabbatch{iRun}.spm.spatial.smooth.im = 0;
        matlabbatch{iRun}.spm.spatial.smooth.prefix = 's';   
        
        clear('filePaths');
end

% run
if Cfg_smoothing.runYN
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end