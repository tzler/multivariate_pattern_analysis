function results = interactionModel_lin(parameters,data_y,data_x)

% data_x is the data used as independent variable
% data_y is the data used as dependent variable

% initialize
nRuns = length(data_x);

for iRun = 1:nRuns
    
    % simplify the names of training and testing data
    nPCsSeed = size(data_y{iRun}.train,1);
    nPCsSphere = size(data_x{iRun}.train,1);
    seedData_train = data_y{iRun}.train;
    seedData_test = data_y{iRun}.test;
    sphereData_train = data_x{iRun}.train;
    sphereData_test = data_x{iRun}.test;

    % Estimate the model (fit regression parameters)
    try
        X = [ones(size(sphereData_train,2),1),sphereData_train'];
        Y = seedData_train';
        beta{iRun} = mldivide(X,Y);
    catch
        beta{iRun} = ones(nPCsSphere+1,nPCsSeed)*NaN;
    end
    
    % Predict left out data
    if ~sum(sum(isnan(beta{iRun})))
        prediction{iRun} = [ones(size(sphereData_test,2),1),sphereData_test']*beta{iRun};
    else
       prediction{iRun} = zeros(size(sphereData_test,2),nPCsSeed);
    end   
    
    % Evaluate quality of predictions using user-specified measures
    for iMeasure = 1:length(parameters.measures)
        results_temp{iMeasure}{iRun} = feval(parameters.measureHandle{iMeasure},prediction,data_y);
    end
    
end

for iMeasure = 1:length(parameters.measures)
    results{iMeasure} = mean(results_temp{iMeasure});
end

