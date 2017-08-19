function subjectInfo = generateFullDataPaths_example_searchlight(iSubject)
  % Necessary fields: .ID, .functionalPaths, .seedPath, .searchSpacePath
% Optional fields: .outliersPaths, .motionRegressorsPaths, .compcorrMaskPaths, .globalSignalMasks

%% Fill in necessary fields
subjects_temp = [1 3 4 5 8 12 13 14 15 16 17];
subjects = subjects_temp(iSubject);
nRuns= 5;
functionalFilter = 'swaf*.img';
roiFilter = '*.img';
seedTemplatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/5_ROIs_222/facesVShouses/ROI03_S%02d_sphere6mm.img';
searchSpaceTemplatePath = '/mindhive/saxelab3/anzellotti/facesViewpoint/2_data_preproc/meanGray_discrete.nii';
for iSubject = 1:length(subjects)
    subjectInfo(iSubject).ID = sprintf('%02d',subjects(iSubject));
    subjectPath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d',subjects(iSubject));
    for iRun = 1:nRuns
        dataFolderName{iSubject,iRun} = sprintf('run%d',iRun);
        functionalDirs{iSubject}{iRun} = fullfile(subjectPath,dataFolderName{iSubject,iRun});
        cd(functionalDirs{iSubject}{iRun});
        filenames = dir(functionalFilter);
        nVolumes = numel(filenames);
        for iVolume = 1:nVolumes
            subjectInfo(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(functionalDirs{iSubject}{iRun},filenames(iVolume).name);
        end
        clear('filenames','nVolumes');
        
    end
    % generate paths to the seed and search space
    subjectInfo(iSubject).seedPath = sprintf(seedTemplatePath,subjects(iSubject));
    subjectInfo(iSubject).searchSpacePath = searchSpaceTemplatePath;
end

%% Fill in optional fields
motionRegressorsFilter = 'rp*.txt';
outliersFilter = 'outl*.txt';
compcorrFilter = 'mask_combWMCSF_*.nii';
for iSubject = 1:length(subjects)
    % Optional field specifying outliers to be scrubbed from the data
    for iRun = 1:nRuns
        cd(functionalDirs{iSubject}{iRun});
        filenames = dir(outliersFilter);
        subjectInfo(iSubject).outliersPaths{iRun} = fullfile(functionalDirs{iSubject}{iRun},filenames(1).name);
        clear('filenames');
    end
    % Optional field specifying motion parameters to be used as regressors of no interest
    for iRun = 1:nRuns
        cd(functionalDirs{iSubject}{iRun});
        filenames = dir(motionRegressorsFilter);
        subjectInfo(iSubject).motionRegressorsPaths{iRun} = fullfile(functionalDirs{iSubject}{iRun},filenames(1).name);
        clear('filenames');
    end   
    % Optional field specifying path to mask of no interest for CompCorr
    anatDirPath = fullfile(subjectPath,'anatomy1');
    cd(anatDirPath);
    filenames = dir(compcorrFilter);
    subjectInfo(iSubject).compcorrMaskPaths = fullfile(anatDirPath,filenames(1).name);
    clear('filenames');
    % Optional field specifying path to mask of no interest for removing global signal
    anatDirPath = fullfile(subjectPath,'anatomy1');
    cd(anatDirPath);
    filenames = dir(compcorrFilter);
    subjectInfo(iSubject).globalSignalMaskPaths = fullfile(anatDirPath,filenames(1).name);
    clear('filenames');
end
