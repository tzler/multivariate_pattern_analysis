function [Cfg_mvpcRoi, exit_script] = mvpc_populateCfg(Cfg_mvpcRoi)

fprintf('\nPopulating Cfg variable...');
exit_script = 0;
% 
% % generate translation and rotation parameters based on SPM rp*.txt files
% try
%     Cfg_mvpcRoi.dataInfo.subjects = mvpc_generateMotionParameters(Cfg_mvpcRoi.dataInfo.subjects);
% catch
%     fprintf(' Failed generating motion parameters.\n');
%     exit_script = 1;
%     return
% end


% generate paths to the functional volumes
try
    nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            volumesFolder = Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalDirs{iRun};
            cd(volumesFolder);
            filenames = dir(Cfg_mvpcRoi.dataInfo.functionalFilter);
            nVolumes = length(filenames);
            for iVolume = 1:nVolumes
                Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iVolume} = fullfile(volumesFolder,filenames(iVolume).name);
            end
        end
    end
catch
    fprintf(' Failed generating paths to the functional volumes.\n');
    exit_script = 1;
    return
end
% 
% 
% % generate paths to the regions of interest
% try
%     for iSubject = 1:nSubjects
%         cd(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir);
%         filenames = dir(Cfg_mvpcRoi.dataInfo.roiFilter);
%         nRois = length(filenames);
%         for iRoi = 1:nRois
%             Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi} = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir,filenames(iRoi).name);
%         end
%     end
% catch
%     fprintf(' Failed generating paths to the regions of interest.\n');
%     exit_script = 1;
%     return
% end


% add empty parameter fields for regionModel functions that do not need
% parameters
for i = 1:length(Cfg_mvpcRoi.regionModels)
    for j = 1:length(Cfg_mvpcRoi.regionModels(i).steps)
        if ~isfield(Cfg_mvpcRoi.regionModels(i).steps(j),'parameters')
            Cfg_mvpcRoi.regionModels(i).steps(j).parameters = [];
        end
    end
end

% add empty parameter fields for interactionModel functions that do not need
% parameters
for i = 1:length(Cfg_mvpcRoi.interactionModels)
    if ~isfield(Cfg_mvpcRoi.interactionModels(i),'parameters')
        Cfg_mvpcRoi.interactionModels(i).parameters = [];
    end
end


% set output details
try
    date_id = num2str(datenum(date));
    outputFolder = strcat('searchlight_',date_id);
    results_baseFolderPath = fullfile(Cfg_mvpcRoi.dataInfo.project,'results');
    Cfg_mvpcRoi.outputPath = fullfile(results_baseFolderPath,outputFolder);
catch
    fprintf(' Failed setting output folders.\n');
    exit_script = 1;
    return
end

if ~exit_script
    fprintf(' Done.\n');
end
