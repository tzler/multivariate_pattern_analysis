function MVPDsearchlight_main(Cfg_searchlight,Cfg_smoothing)


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
    MVPDsearchlight_singleSub(Cfg_searchlight.dataInfo.subjects(iSubject),Cfg_searchlight.searchlightInfo, Cfg_searchlight.regionModels, Cfg_searchlight.preprocModels, Cfg_searchlight.interactionModels, Cfg_searchlight.outputPath);
    fprintf('Finished connectivity calculations for subject %d\n',iSubject);
end

