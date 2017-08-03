function  subjectInfo = mvpc_generateFullDataPaths_facesViewpoint(subjects,subjectTemplatePath,runTemplatePath,nRuns,seedTemplatePath,searchSpaceTemplatePath,compcorrMaskTemplatePath)

for iSubject= 1:length(subjects)
    subjectInfo(iSubject).ID = subjects(iSubject);
    subjectInfo(iSubject).seedPath = sprintf(seedTemplatePath,subjects(iSubject));
    subjectInfo(iSubject).searchSpacePath = searchSpaceTemplatePath;
%     subjectInfo(iSubject).compcorrMaskPath = compcorrMaskTemplatePath;
    subjectInfo(iSubject).subjectPath = sprintf(subjectTemplatePath,subjects(iSubject));
    for iRun = 1:nRuns
        subjectInfo(iSubject).functionalDirs{iRun} = sprintf(runTemplatePath,subjects(iSubject),iRun);
    end
end