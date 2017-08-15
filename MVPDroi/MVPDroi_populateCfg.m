function [exit_script, Cfg_MVPDroi] = MVPDroi_populateCfg(Cfg_MVPDroi)

fprintf('\nPopulating Cfg variable...');
exit_script = 0;

%% generate paths to the functional volumes
try
    nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            
            clear('runFolder','filenames','nVolumes','volumesSelect','outliersFile','motion_temp');
            runFolder = Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalDirs{iRun};
            cd(runFolder);
            filenames = dir(Cfg_MVPDroi.dataInfo.functionalFilter);
            nVolumes = numel(filenames);
            volumesSelect = 1:nVolumes;
            
            % store initial number of volumes
            totalVolumes(iSubject,iRun) = nVolumes;

            % scrub volumes associated with outliers if expungeVols
            if Cfg_MVPDroi.dataInfo.expungeVols
                if isfield(Cfg_MVPDroi.dataInfo,'outliersFilter')
                    outliersFile = dir(Cfg_MVPDroi.dataInfo.outliersFilter);
    	        else
    	            warning('\nFilter for motion outlier files not provided.')
    	        end
                if numel(outliersFile) > 0
		            outliers = load(outliersFile(1).name);
                    nOutliers(iSubject,iRun) = length(outliers);
                    volumesSelect(outliers) = [];
                else
                    warning('\nNo outlier file located, Subject: %d, run: %d\n', iSubject, iRun);
                end
            end
            
            % populate functionalPaths
            for iVolume = 1:numel(volumesSelect)
                Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(runFolder,filenames(volumesSelect(iVolume)).name);
            end
            
            % Purge runs with less than threshold of retained volumes
            if Cfg_MVPDroi.dataInfo.expungeRuns
                if  (Cfg_MVPDroi.dataInfo.expungeRunsThreshold < nOutliers(iSubject,iRun)/totalVolumes(iSubject,iRun)) % purge run if more than threshold volumes are scrubbed
                    Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun} = []; % purge run
                    Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths(~cellfun(@isempty, Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths)); % restructure array
                end   
            end
        end
		    
        % Purge subjects with less than 2 retained runs
        if numel(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths) < 2
            Cfg_MVPDroi.dataInfo.subjects(iSubject) = [];
        end
	
    end
	
catch
    fprintf(' Failed generating paths to the functional volumes.\n');
        exit_script = 1;
    return
end

%% If requested, generate paths to motion regressors

if strcmp(Cfg_MVPDroi.searchlightInfo.compcorr.includeMotionRegressors,'yes')
    try
    nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            volumesFolder = Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalDirs{iRun};
            cd(volumesFolder);
            motionRegressorFileInfo = dir('rp*');
            if length(motionRegressorFileInfo)>1	    
                  fprintf('There are too many motion regressor files.');
            end
            Cfg_MVPDroi.dataInfo.subjects(iSubject).motionRegressorsPaths{iRun} = fullfile(volumesFolder,motionRegressorFileInfo.name);
        end
    end
    catch
        fprintf(' Failed generating paths to the motion regressors.\n');
        exit_script = 1;
        return
    end
end

%% locate subject compcorr mask
try
    nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        Cfg_MVPDroi.dataInfo.subjects(iSubject).anatPath = fullfile(Cfg_MVPDroi.dataInfo.subjects(iSubject).subjectPath,Cfg_MVPDroi.dataInfo.anatDirName);
        cd(Cfg_MVPDroi.dataInfo.subjects(iSubject).anatPath);
        mask_temp = dir(Cfg_MVPDroi.dataInfo.compcorrFilter);
        Cfg_MVPDroi.dataInfo.subjects(iSubject).compcorrMask = fullfile(pwd,mask_temp(1).name);
    end
catch
    fprintf(' Failed generating paths to the motion regression mask.\n');
    exit_script = 1;
    return
end


%% calculate second level motion regressor
try
    nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        Cfg_MVPDroi.dataInfo.subjects(iSubject).motionPath = fullfile(Cfg_MVPDroi.dataInfo.subjects(iSubject).subjectPath,Cfg_MVPDroi.dataInfo.motionDirName);
        cd(Cfg_MVPDroi.dataInfo.subjects(iSubject).motionPath);
        var_temp = dir(Cfg_MVPDroi.dataInfo.totalMotionFilter);
        load(var_temp(1).name); % loads 'Regressor' variable
    end
catch
    fprintf(' Failed generating paths to the motion regression variable.\n');
    exit_script = 1;
    return
end


% generate paths to the regions of interest
if ~isempty(Cfg_MVPDroi.dataInfo.subjects(1).roiDir)
    try
        for iSubject = 1:nSubjects
            cd(Cfg_MVPDroi.dataInfo.subjects(iSubject).roiDir);
            filenames = dir(Cfg_MVPDroi.dataInfo.roiFilter);
            nRois = length(filenames);
            for iRoi = 1:nRois
                Cfg_MVPDroi.dataInfo.subjects(iSubject).roiPaths{iRoi} = fullfile(Cfg_MVPDroi.dataInfo.subjects(iSubject).roiDir,filenames(iRoi).name);
            end
        end
    catch
        fprintf(' Failed generating paths to the regions of interest.\n');
        exit_script = 1;
        return
    end
end


% add empty parameter fields for preprocModel functions that do not need parameters
for idx1 = 1:length(Cfg_MVPDroi.preprocModels)
    for idx2 = 1:length(Cfg_MVPDroi.regionModels(idx1).steps)
        if ~isfield(Cfg_MVPDroi.regionModels(idx1).steps(idx2),'parameters')
            Cfg_MVPDroi.regionModels(idx1).steps(idx2).parameters = [];
        end
    end
end

% add empty parameter fields for regionModel functions that do not need parameters
for idx1 = 1:length(Cfg_MVPDroi.regionModels)
    for idx2 = 1:length(Cfg_MVPDroi.regionModels(idx1).steps)
        if ~isfield(Cfg_MVPDroi.regionModels(idx1).steps(idx2),'parameters')
            Cfg_MVPDroi.regionModels(idx1).steps(idx2).parameters = [];
        end
    end
end
% 
% add empty parameter fields for interactionModel functions that do not need parameters
for idx1 = 1:length(Cfg_MVPDroi.interactionModels)
    if ~isfield(Cfg_MVPDroi.interactionModels(idx1),'parameters')
        Cfg_MVPDroi.interactionModels(idx1).parameters = [];
    end
end

try
    nSubjects = length(Cfg_MVPDroi.dataInfo.subjects);
    for iSubject = 1:nSubjects
        nRuns = length(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalDirs);
        for iRun = 1:nRuns
            Cfg_MVPDroi.dataInfo.motionStats.retainedDataRun(iSubject,iRun) = numel(Cfg_MVPDroi.dataInfo.subjects(iSubject).functionalPaths{iRun});
            Cfg_MVPDroi.dataInfo.motionStats.retainedDataSubject(iSubject).mean = mean(Cfg_MVPDroi.dataInfo.motionStats.retainedDataRun(iSubject,:),2);
            Cfg_MVPDroi.dataInfo.motionStats.retainedDataSubject(iSubject).variance = var(Cfg_MVPDroi.dataInfo.motionStats.retainedDataRun(iSubject,:),0,2);
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
