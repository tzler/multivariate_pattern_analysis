function volumes2 = loadDenoise_motionParameters(parameters, subject, volumes2,iRun)

if isfield(subject,'motionRegressorsPaths')
    motionRegressors = load(subject.motionRegressorsPaths{iRun});
    if isfield(subject,'outliersPaths')
        outliers = load(subject.outliersPaths{iRun});   
        motionRegressors(outliers,:) = [];
    end
    nVolumes = size(volumes2,2);
    if size(motionRegressors,1)~=nVolumes
       warning('\nThe number of motion regressors does not match the number of functional volumes.') 
    end
    % make regressors of no interest
    regressors_NI = [ones(nVolumes,1),motionRegressors];
    Y = volumes2';
    clear('volumes2');
    b = mldivide(regressors_NI,Y);
    R = Y-regressors_NI*b;
    volumes2 = R';
else
   warning('\n Outlier paths not specified.') 
end