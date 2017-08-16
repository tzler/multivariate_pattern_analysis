function volumes2 = loadDenoise_scrub(parameters,subject,volumes2,iRun)

if isfield(subject,'outliersPaths')
    outliers = load(subject.outliersPaths{iRun});   
    volumes2(:,outliers) = [];
else
   warning('Outlier paths not specified.') 
end