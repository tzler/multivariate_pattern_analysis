function exit_script = mvpc_rois_makedirs( Cfg_mvpcRoi )
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

%% Make output folders if needed
if exist(Cfg_mvpcRoi.outputPaths.results,'dir')~=7
    fprintf('\nMaking results folder at %s\n', Cfg_mvpcRoi.outputPaths.results);
    try
        mkdir(Cfg_mvpcRoi.outputPaths.results);
    catch
        fprintf('\nCould not create results folder. Check permissions.\n');
    end
end
if exist(Cfg_mvpcRoi.outputPaths.fig,'dir')~=7
    fprintf('\nMaking figures folder at %s\n', Cfg_mvpcRoi.outputPaths.fig);
    try
        mkdir(Cfg_mvpcRoi.outputPaths.fig);
    t
        fprintf('\nCould not create figures folder. Check permissions.\n');
    end
end

if ~exit_script
    fprintf('\nFile check completed successfully.\n');
end