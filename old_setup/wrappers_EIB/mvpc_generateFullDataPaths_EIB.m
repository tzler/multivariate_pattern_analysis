function subjectInfo = mvpc_generateFullDataPaths_EIB(projectFolderPath,subjectInfo)

for iSubject = 1:length(subjectInfo)
    subjectInfo(iSubject).subjectPath = fullfile(projectFolderPath,subjectInfo(iSubject).ID);
    nRuns(iSubject) = length(subjectInfo(iSubject).EIB_main);
    for iRun = 1:nRuns
        dataFolderName{iSubject,iRun} = sprintf('0%d',subjectInfo(iSubject).EIB_main(iRun));
        subjectInfo(iSubject).functionalDirs{iRun} = fullfile(subjectInfo(iSubject).subjectPath,'bold',dataFolderName{iSubject,iRun});
    end
    subjectInfo(iSubject).group = subjectInfo(iSubject).ASD;
end

subjectInfo = rmfield(subjectInfo,'ASD');
