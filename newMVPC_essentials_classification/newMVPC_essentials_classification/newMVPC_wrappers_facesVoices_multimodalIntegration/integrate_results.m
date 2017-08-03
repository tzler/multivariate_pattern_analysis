subjects = [1,3,4,5,8,12:17];
nSubjects = length(subjects);
projectFolderPath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/interactionModels_multimodalIntegration';
subFileTemplate = 'subsub%02d_imodel.mat';

% iRegion, iRun, iNodes, iIteration

for iSubject= 1:nSubjects
    subFilePath = fullfile(projectFolderPath,sprintf(subFileTemplate,subjects(iSubject)));
    data = load(subFilePath);
    varexpl_lin(:,iSubject) = squeeze(mean(data.varexpl_lin_final,2));
    varexpl_nonlin(:,iSubject) = squeeze(mean(data.varexpl_nonlin_final,2));
    clear('subFilePath','data')
end

varexpl_diff = varexpl_nonlin-varexpl_lin;
for iRegion = 1:6
    [h(iRegion) p(iRegion) ci{iRegion} stats{iRegion}] = ttest(varexpl_diff(iRegion,:));
end    