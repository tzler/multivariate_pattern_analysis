function motionParameters = loadDenoise_motionParameters(parameters, subject, volumes2)

motionRegressors = load(subject.motionRegressorsPaths{iRun});
motionRegressors(subject.outliers{iRun},:) = [];
