function subjectInfo = generateFullDataPaths_example
% Necessary fields: .ID, .functionalPaths, .roiPaths
% Optional fields: .outliersPaths, .motionRegressorsPaths, .compcorrMaskPaths, .globalSignalMasks

%% Fill in necessary fields
subjects = [1 3 4 5 8 12 13 14 15 16 17];
nRuns= 5;
functionalFilter = 'swaf*.img';
roiFilter = '*.img';
for iSubject = 1:length(subjects)
    subjectInfo(iSubject).ID = sprintf('%02d',subjects(iSubject));
    subjectPath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d',subjects(iSubject));
    for iRun = 1:nRuns
        dataFolderName{iSubject,iRun} = sprintf('run%d',iRun);
        subjectInfo(iSubject).functionalDirs{iRun} = fullfile(subjectPath,dataFolderName{iSubject,iRun});
        cd(subjectInfo(iSubject).functionalDirs{iRun});
        filenames = dir(functionalFilter);
        nVolumes = numel(filenames);
        for iVolume = 1:nVolumes
            subjectInfo(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(functionalDir,filenames(iVolume).name);
        end
        clear('filenames','nVolumes');
        
    end
    % generate paths to the regions of interest
    roiDir = fullfile(subjectPath,'ROIs');
    cd(roiDir);
    filenames = dir(roiFilter);
    nRois = length(filenames);
    for iRoi = 1:nRois
        subjectInfo(iSubject).roiPaths{iRoi} = fullfile(roiDir,filenames(iRoi).name);
    end    
end

%% Fill in optional fields
motionRegressorsFilter = 'rp*.txt';
outliersFilter = 'outl*.txt';
compcorrFilter = 'mask_combWMCSF_*.nii';
for iSubject = 1:length(subjects)
    % Optional field specifying outliers to be scrubbed from the data
    for iRun = 1:nRuns
        cd(subjectInfo(iSubject).functionalDirs{iRun});
        filenames = dir(outliersFilter);
        subjectInfo(iSubject).outliersPaths = fullfile(subjectInfo(iSubject).functionalDirs{iRun},filenames(1).name);
        clear('filenames');
    end
    % Optional field specifying motion parameters to be used as regressors of no interest
    for iRun = 1:nRuns
        cd(subjectInfo(iSubject).functionalDirs{iRun});
        filenames = dir(motionRegressorsFilter);
        subjectInfo(iSubject).motionRegressorsPaths = fullfile(subjectInfo(iSubject).functionalDirs{iRun},filenames(1).name);
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
