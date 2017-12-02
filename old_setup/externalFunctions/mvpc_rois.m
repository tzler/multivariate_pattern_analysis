function results = mvpc_rois(Cfg_mvpcRoi)

global mvpc_iSubject

%% Load libraries
libs = fieldnames(Cfg_mvpcRoi.libraryPaths);
for dependency = 1:numel(libs)
    addpath(genpath( Cfg_mvpcRoi.libraryPaths.(libs{dependency}) ));
end
rmpath(genpath(fullfile(Cfg_mvpcRoi.libraryPaths.spm12,'external')));
rmpath(genpath('/software/pkg/matlab/matlab-2015b/toolbox/stats/eml'));

%% Calculate connectivity between the rois
nSubjects = length(Cfg_mvpcRoi.dataInfo.subjects);
for iSubject = 1:nSubjects
	mvpc_iSubject = iSubject; % set global variable for nnet parallelization
    results{iSubject} = mvpc_rois_singleSub(Cfg_mvpcRoi.dataInfo.subjects(iSubject),Cfg_mvpcRoi.compcorr.nPCs,Cfg_mvpcRoi.regionModels,Cfg_mvpcRoi.interactionModels); % receives results{iInteractionModel}
    fprintf('Finished connectivity calculations for subject %d\n',iSubject);
end 

%% Save
cd(Cfg_mvpcRoi.outputPaths.results);
filename = strcat('mvpc_connectivityMatrices_',Cfg_mvpcRoi.outputPaths.date_id);
save(filename,'-v7.3');
