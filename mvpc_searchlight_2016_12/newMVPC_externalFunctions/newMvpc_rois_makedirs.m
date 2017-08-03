function exit_script = newMvpc_rois_makedirs( Cfg_mvpcRoi )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

exit_script = 0;
% Check functional volumes
fprintf('\nChecking functional volumes...');
nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);

for iSubject = 1:nSubjects
    nRuns = length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths);
    for iRun = 1:nRuns
        for iFile = 1:length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun});
            if exist(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iFile},'file')~=2
               fprintf('\n%s could not be found or is not a file.\n',Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iFile});
               exit_script = 1;
            end
        end
    end
end
fprintf(' Done.\n');

% Check ROIs
fprintf('\nChecking ROIs...');
for iSubject = 1:nSubjects
    for iRoi = 1:numel(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths)
        if exist(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi},'file')~=2
            fprintf('\n%s could not be found or is not a file.\n',Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi});
            exit_script = 1;
        end
    end
end

for iSubject = 1:nSubjects
if isfield(Cfg_mvpcRoi.dataInfo.subjects(iSubject),'compcorrMask')
    if exist(Cfg_mvpcRoi.dataInfo.subjects(iSubject).compcorrMask,'file')~=2
        fprintf('\n%s could not be found or is not a file.\n',Cfg_mvpcRoi.dataInfo.subjects(iSubject).compcorrMask);
        exit_script = 1;
    end
else
    fprintf('WARNING: Control ROI for compcorr not specified!');
    exit_script = 1;
end
end

nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
for iSubject = 1:nSubjects
    nRois = length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths);
    for iRoi = 1:nRois
        if exist(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi},'file')~=2
            fprintf('\n%s could not be found or is not a file.\n',Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi});
            exit_script = 1;
        end
    end
end
fprintf(' Done.\n');

% Make output folders if needed
if exist(Cfg_mvpcRoi.outputPaths.regionModels_base,'dir')~=7
    fprintf('\nMaking region models folder at %s\n', Cfg_mvpcRoi.outputPaths.regionModels_base);
    try
        mkdir(Cfg_mvpcRoi.outputPaths.regionModels_base);
    catch
        fprintf('\nCould not create region models folder. Check permissions.\n');
        exit_script = 1;
    end
end
if exist(Cfg_mvpcRoi.outputPaths.interactionModels_base,'dir')~=7
    fprintf('\nMaking figures folder at %s\n', Cfg_mvpcRoi.outputPaths.interactionModels_base);
    try
        mkdir(Cfg_mvpcRoi.outputPaths.interactionModels_base);
    catch
        fprintf('\nCould not create interaction models folder. Check permissions.\n');
        exit_script = 1;
    end
end

if ~exit_script
    fprintf('\nFile check completed successfully.\n');
else
    warning('File check encoutered errors. Not saving Cfg.')
end