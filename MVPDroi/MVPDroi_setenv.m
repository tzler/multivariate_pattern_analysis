function exit_script = MVPDroi_setenv(Cfg_MVPDroi)

% This function creates the folders where the results will be saved and
% checks that all the file paths exist.

exit_script = 0;
%% Check functional volumes

fprintf('\nChecking functional volumes...');
nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
for iSubject = 1:nSubjects
    nRuns = length(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths);
    for iRun = 1:nRuns
        for iFile = 1:length(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun})
            if exist(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iFile},'file')~=2
               fprintf('\n%s could not be found or is not a file.\n',Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iFile});
               exit_script = 1;
            end
        end
    end
end
fprintf(' Done.\n');

%% Check ROIs

fprintf('\nChecking ROIs...');
for iSubject = 1:nSubjects
if isfield(Cfg_MVPDroi.dataInfo.subjects(iSubject),'compcorrMask')
    if exist(Cfg_MVPDroi.dataInfo.subjects(iSubject).compcorrMask,'file')~=2
        fprintf('\n%s could not be found or is not a file.\n',Cfg_MVPDroi.dataInfo.subjects(iSubject).compcorrMask);
        exit_script = 1;
    end
else
    fprintf('WARNING: Control ROI for compcorr not specified!');
    exit_script = 1;
end
end
for iSubject = 1:nSubjects
    nRois = length(Cfg_MVPDroi.dataInfo.subjects(iSubject).roiPaths);
    for iRoi = 1:nRois
        if exist(Cfg_MVPDroi.dataInfo.subjects(iSubject).roiPaths{iRoi},'file')~=2
            fprintf('\n%s could not be found or is not a file.\n',Cfg_MVPDroi.dataInfo.subjects(iSubject).roiPaths{iRoi});
            exit_script = 1;
        end
    end
end
fprintf(' Done.\n');

%% Make output folders if needed
if exist(Cfg_MVPDroi.outputPaths.regionModels_base,'dir')~=7
    fprintf('\nMaking region models folder at %s\n', Cfg_MVPDroi.outputPaths.regionModels_base);
    try
        mkdir(Cfg_MVPDroi.outputPaths.regionModels_base);
    catch
        fprintf('\nCould not create region models folder. Check permissions.\n');
        exit_script = 1;
    end
end
if exist(Cfg_MVPDroi.outputPaths.interactionModels_base,'dir')~=7
    fprintf('\nMaking figures folder at %s\n', Cfg_MVPDroi.outputPaths.interactionModels_base);
    try
        mkdir(Cfg_MVPDroi.outputPaths.interactionModels_base);
    catch
        fprintf('\nCould not create interaction models folder. Check permissions.\n');
        exit_script = 1;
    end
end

%% Finish
if ~exit_script
    fprintf('\nFile check completed successfully.\n');
else
    warning('File check encoutered errors. Not saving Cfg.')
end