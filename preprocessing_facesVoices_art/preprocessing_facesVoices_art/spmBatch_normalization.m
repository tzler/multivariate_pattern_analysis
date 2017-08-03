function matlabbatch = spmBatch_normalization(Cfg_normalization)

% select deformation matrix
cd(Cfg_normalization.anatomyFolder);
deformationFieldName = dir('y_*');

% select files to normalize

for iRun = 1:length(Cfg_normalization.filesFolders)

    matlabbatch{1}.spm.spatial.normalise.write.subj.def{1} = fullfile(Cfg_normalization.anatomyFolder,deformationFieldName(1).name);

    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85]; % bounding box in mm
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = Cfg_normalization.voxelSize;
    if Cfg_normalization.debug
        sprintf('DEBUG\n');
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 1; % degree B-spline (interpolation quality)
    else
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 7; % degree B-spline (interpolation quality)
    end

    %matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

    cd(Cfg_normalization.filesFolders{iRun});
    filenames = dir(Cfg_normalization.filesFilter);

    for iFile = 1:length(filenames)
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample{iFile,1} = strcat(fullfile(Cfg_normalization.filesFolders{iRun},filenames(iFile).name),',1');
    end

    % run
    if Cfg_normalization.runYN
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch);
    end

    clear('matlabbatch','filenames');

end