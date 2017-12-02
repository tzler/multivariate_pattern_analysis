
load('/mindhive/saxelab2/tyler/mvpc/kids/results/mvpc_123PM_2016_0726/Cfg_mvpcRoi.mat')

% Load libraries
libs = fieldnames(Cfg_mvpcRoi.libraryPaths);
for dependency = 1:numel(libs)
    addpath(genpath( Cfg_mvpcRoi.libraryPaths.(libs{dependency}) ));
end
rmpath(genpath(fullfile(Cfg_mvpcRoi.libraryPaths.spm12,'external')));
rmpath(genpath('/software/pkg/matlab/matlab-2015b/toolbox/stats/eml'));

% Calculate connectivity between the rois
iSubject = 1;
global mvpc_iSubject
mvpc_iSubject = iSubject;

results = mvpc_rois_singleSub(Cfg_mvpcRoi.dataInfo.subjects(iSubject),Cfg_mvpcRoi.compcorr.nPCs,Cfg_mvpcRoi.regionModels,Cfg_mvpcRoi.interactionModels);
fprintf('Finished connectivity calculations for subject %d\n',iSubject);

% Save
cd(Cfg_mvpcRoi.outputPaths.results);
filename_persubject = sprintf('results_subject001');
subjectData = Cfg_mvpcRoi.dataInfo.subjects(iSubject);
save(filename_persubject,'results','subjectData')

