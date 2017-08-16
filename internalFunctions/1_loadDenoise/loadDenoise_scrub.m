function volumes2 = loadDenoise_scrub(parameters,subject,volumes2,iRun)

if isfield(subject,'outlierPaths')
    outliers = load(subject.outlierPaths{iRun});   
    volumes2(outliers,:) = [];
else
   warning('\n Outlier paths not specified.') 
end