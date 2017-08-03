function mvpc_searchlight_only(Cfg_searchlight,Cfg_smoothing)


nSubjects = length(Cfg_searchlight.dataInfo.subjects);

%% STEP 0: add libraries to the MATLAB path
libraryNames = fieldnames(Cfg_searchlight.libraryPaths);
for iLibrary = 1:length(libraryNames)
    fieldname = libraryNames{iLibrary};
    addpath(genpath(Cfg_searchlight.libraryPaths.(fieldname)));
end
rmpath(genpath(fullfile(Cfg_searchlight.libraryPaths.spm12,'external')));
rmpath(genpath('/software/pkg/matlab/matlab-2015b/toolbox/stats/eml'));

%% STEP 1: run iconn
for iSubject = 1:nSubjects
%    try     
%       parpool local
%        poolobj = gcp;
%        addAttachedFiles(poolobj, {paths.spm12, paths.mrtools, paths.signal,paths.stats});
%    catch
%    end
    mvpc_searchlight_singleSub(Cfg_searchlight.dataInfo.subjects(iSubject),Cfg_searchlight.searchlightInfo, Cfg_searchlight.regionModels, Cfg_searchlight.interactionModels, Cfg_searchlight.outputPath);
    fprintf('Finished connectivity calculations for subject %d\n',iSubject);
end
% 
% %% STEP 2: zscore - not needed when using r instead of abs(r)
% inputFolder = Cfg_searchlight.outputPath;
% nAnalyses = length(Cfg_searchlight.interactionModels);
% cd(inputFolder);
% for iSub = 1:nSubjects
%     sub=Cfg_searchlight.dataInfo.subjects(iSub).ID;
%     if sub<10
%         string = sprintf('0%d',sub);
%     else
%         string = sprintf('%d',sub);
%     end
%     for iAnalysis = 1:nAnalyses
%         fname = sprintf('analysis%d_sub%s',iAnalysis,string);
%         vol_info = spm_vol(sprintf('%s.img',fname));
%         volume = spm_read_vols(vol_info);
%         volume(volume == 0) = NaN;
%         volume_zscored = ones(size(volume))*NaN;
%         %meanVolume = nanmean(nanmean(nanmean(volume)));
%         volume_zscored(~isnan(volume)) = zscore(volume(~isnan(volume))); %volume-meanVolume;
%         vol_info.fname = strcat('z_',fname,'.img');
%         spm_write_vol(vol_info,volume_zscored);
%     end
% end
% 
% %% STEP 3: smooth
% 
% Cfg_smoothing.filesFolders{1} = Cfg_searchlight.outputPath;
% Cfg_smoothing.filesFilter = 'z_analysis*.img';
% Cfg_smoothing.runYN = 1;
% Cfg_smoothing.smoothingKernel =[4 4 4];
% mrtools_smoothing(Cfg_smoothing);
% % 
% % %% STEP 4: average runs
% % 
% % inputFolder = Cfg_searchlight.outputPath;
% % filterTemplate = strcat(sprintf('sm_%d_%d_%d_z_r_meanCompWise',Cfg_smoothing.smoothingKernel(1),Cfg_smoothing.smoothingKernel(2),Cfg_smoothing.smoothingKernel(3)),'_sub%s*.img');
% % outputTemplate = strcat(sprintf('average_sm_%d_%d_%d_z_r_meanCompWise',Cfg_smoothing.smoothingKernel(1),Cfg_smoothing.smoothingKernel(2),Cfg_smoothing.smoothingKernel(3)),'_sub%s.img');
% % 
% % for iSub = 1:length(Cfg_searchlight.dataInfo.subjects)
% %     sub=Cfg_searchlight.dataInfo.subjects(iSub).ID;
% %     if sub<10
% %         string = sprintf('0%d',sub);
% %     else
% %         string = sprintf('%d',sub);
% %     end
% %     filter = sprintf(filterTemplate,string);
% %     cd(inputFolder);
% %     volumeNames_temp = dir(filter);
% %     volumeNames = {volumeNames_temp.name};
% %     for iVolume = 1:length(volumeNames)
% %         volumePaths{iVolume} = fullfile(inputFolder,volumeNames{iVolume});
% %     end
% %     outputPath=inputFolder;
% %     outputName=sprintf(outputTemplate,string);
% %     mrtools_volumesAverage(volumePaths,outputPath,outputName);
% % end
% 
% 
% %% STEP 5: snpm
% 
% cd(Cfg_searchlight.libraryPaths.mrtools);
% load('snpm_batch.mat');
% snpmDir = fullfile(Cfg_searchlight.outputPath,'snpm');
% mkdir(snpmDir);
% matlabbatch{1,1}.spm.tools.snpm.des.OneSampT.dir{1,1} = snpmDir;
% cd(Cfg_searchlight.outputPath);
% files = dir('sm_4_4_4_z_analysis1*.img');
% % model specification
% for iSubject = 1:nSubjects
%     matlabbatch{1,1}.spm.tools.snpm.des.OneSampT.P{iSubject,1} = fullfile(Cfg_searchlight.outputPath,files(iSubject).name);
% end
% matlabbatch{1,1}.spm.tools.snpm.des.OneSampT.vFWHM = Cfg_smoothing.smoothingKernel;
% % compute permutations
% matlabbatch{1,2}.spm.tools.snpm.cp.snpmcfg{1,1} = fullfile(snpmDir,'SnPMcfg.mat');
% % inference
% matlabbatch{1,3}.spm.tools.snpm.inference.SnPMmat{1,1} = fullfile(snpmDir,'SnPM.mat');
% % run
% spm_jobman('run',matlabbatch);
