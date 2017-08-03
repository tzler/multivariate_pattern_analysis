function [Cfg_mvpcRoi, exit_script] = newMvpc_populateCfg(Cfg_mvpcRoi)

fprintf('\nPopulating Cfg variable...');
exit_script = 0;


% generate paths to the functional volumes
try
    nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            clear('motion_temp','nOutliers','nVolumes');
            runFolder = Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalDirs{iRun};
            cd(runFolder);
            
            filenames = dir(Cfg_mvpcRoi.dataInfo.functionalFilter);
            volumesSelect = 1:numel(filenames);
            
            % store initial number of volumes
            Cfg_mvpcRoi.dataInfo.motionStats.totalVolumes(iSubject,iRun) = numel(volumesSelect);

            % scrub volumes associated with outliers if expungVols
            if (~isempty('Cfg_mvpcRoi.dataInfo.expungeVols'))
                motion_temp = dir(Cfg_mvpcRoi.dataInfo.regressorRunFilter);
                if (Cfg_mvpcRoi.dataInfo.expungeVols && numel(motion_temp) > 0)
                    outliers = load(motion_temp(1).name); % loads variable R
                    outliers.out_idx = find(sum(outliers.R,2));
                    [nVolumes,nOutliers] = size(outliers.R);
                    volumesSelect(outliers.out_idx) = [];
                else
                    warning('\nNo motion file located, Subject: %d, run: %d\n', iSubject, iRun);
                end
            end
            
            % populate functionalPaths
            for iVolume = 1:numel(volumesSelect);
                Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(runFolder,filenames(volumesSelect(iVolume)).name);
            end
            
            %%% different idea of how to do runs purge. not working code yet
            %             for iVolume = volumesSelect
            %                 Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(runFolder,filenames(iVolume).name);
            %                 Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun}(~cellfun(@isempty, Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun})); % include if no gap in indices is desired
            %             end
            
            % Purge runs with less than threshold of retained runs following scrubbing of motion outliers
            if (~isempty('Cfg_mvpcRoi.dataInfo.expungeRuns'))
                if (Cfg_mvpcRoi.dataInfo.expungeRuns && numel(motion_temp) > 0)
                    if (Cfg_mvpcRoi.dataInfo.expungeRunsThreshold < nOutliers/nVolumes) % purge run if more than threshold volumes are scrubbed
                        Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun} = []; % purge run
                        Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths(~cellfun(@isempty, Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths)); % restructure array
                    end
                end
            end
        end
        
        % Purge subjects with less than 2 retained runs following removal of runs not meeting threshold of retained data following motion scrubbing
        if numel(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths) < 2
            Cfg_mvpcRoi.dataInfo.subjects(iSubject) = [];
        end
        
    end
catch
    fprintf(' Failed generating paths to the functional volumes.\n');
    exit_script = 1;
    return
end


% locate subject compcorr mask
try
    nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        Cfg_mvpcRoi.dataInfo.subjects(iSubject).anatPath = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).subjectPath,Cfg_mvpcRoi.dataInfo.anatDirName);
        cd(Cfg_mvpcRoi.dataInfo.subjects(iSubject).anatPath);
        mask_temp = dir(Cfg_mvpcRoi.dataInfo.compcorrFilter);
        Cfg_mvpcRoi.dataInfo.subjects(iSubject).compcorrMask = fullfile(pwd,mask_temp(1).name);
    end
catch
    fprintf(' Failed generating paths to the motion regression mask.\n');
    exit_script = 1;
    return
end


% calculate second level motion regressor
try
    nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        Cfg_mvpcRoi.dataInfo.subjects(iSubject).motionPath = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).subjectPath,Cfg_mvpcRoi.dataInfo.motionDirName);
        cd(Cfg_mvpcRoi.dataInfo.subjects(iSubject).motionPath);
        var_temp = dir(Cfg_mvpcRoi.dataInfo.totalMotionFilter);
        load(var_temp(1).name); % loads 'Regressor' variable
    end
catch
    fprintf(' Failed generating paths to the motion regression variable.\n');
    exit_script = 1;
    return
end


% % generate paths to the regions of interest
% if ~isempty(Cfg_mvpcRoi.dataInfo.subjects(1).roiDir)
%     try
%         for iSubject = 1:nSubjects
%             cd(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir);
%             filenames = dir(Cfg_mvpcRoi.dataInfo.roiFilter);
%             nRois = length(filenames);
%             for iRoi = 1:nRois
%                 Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiPaths{iRoi} = fullfile(Cfg_mvpcRoi.dataInfo.subjects(iSubject).roiDir,filenames(iRoi).name);
%             end
%         end
%     catch
%         fprintf(' Failed generating paths to the regions of interest.\n');
%         exit_script = 1;
%         return
%     end
% end


% add empty parameter fields for regionModel functions that do not need parameters
for idx1 = 1:length(Cfg_mvpcRoi.regionModels)
    for idx2 = 1:length(Cfg_mvpcRoi.regionModels(idx1).seed.steps)
        if ~isfield(Cfg_mvpcRoi.regionModels(idx1).seed.steps(idx2),'parameters')
            Cfg_mvpcRoi.regionModels(idx1).seed.steps(idx2).parameters = [];
        end
    end
    for idx2 = 1:length(Cfg_mvpcRoi.regionModels(idx1).spheres.steps)
        if ~isfield(Cfg_mvpcRoi.regionModels(idx1).spheres.steps(idx2),'parameters')
            Cfg_mvpcRoi.regionModels(idx1).spheres.steps(idx2).parameters = [];
        end
    end
end

% add empty parameter fields for interactionModel functions that do not need parameters
for idx1 = 1:length(Cfg_mvpcRoi.interactionModels)
    if ~isfield(Cfg_mvpcRoi.interactionModels(idx1),'parameters')
        Cfg_mvpcRoi.interactionModels(idx1).parameters = [];
    end
end

try
    nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            Cfg_mvpcRoi.dataInfo.motionStats.retainedDataRun(iSubject,iRun) = numel(Cfg_mvpcRoi.dataInfo.subjects(iSubject).functionalPaths{iRun});
            Cfg_mvpcRoi.dataInfo.motionStats.retainedDataSubject(iSubject).mean = mean(Cfg_mvpcRoi.dataInfo.motionStats.retainedDataRun(iSubject,:),2);
            Cfg_mvpcRoi.dataInfo.motionStats.retainedDataSubject(iSubject).variance = var(Cfg_mvpcRoi.dataInfo.motionStats.retainedDataRun(iSubject,:),0,2);
        end
    end
catch
    fprintf(' Failed generating motion statistics.\n');
    exit_script = 1;
    return
end


if ~exit_script
    fprintf(' Done.\n');
else
	warning('Errors Encountered in Populating Cfg\n')
end
