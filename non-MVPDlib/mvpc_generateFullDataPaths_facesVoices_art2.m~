function subjectInfo = mvpc_generateFullDataPaths_facesVoices_art2

subjects = [1 3 4 5 8 12 13 14 15 16 17];
for iSubject = 1:length(subjects)
    subjectInfo(iSubject).ID = sprintf('sub%02d',subjects(iSubject));
    subjectInfo(iSubject).subjectPath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d',subjects(iSubject));
    nRuns= 5;
    for iRun = 1:nRuns
        dataFolderName{iSubject,iRun} = sprintf('run%d',iRun);
        subjectInfo(iSubject).functionalDirs{iRun} = fullfile(subjectInfo(iSubject).subjectPath,dataFolderName{iSubject,iRun});
    end
end


