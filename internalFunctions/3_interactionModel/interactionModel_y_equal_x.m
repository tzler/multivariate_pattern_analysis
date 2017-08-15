function results = interactionModel_y_equal_x(parameters,data_y,data_x)

% data_x is the data used as independent variable
% data_y is the data used as dependent variable

% initialize
nRuns = length(data_x);

for iRun = 1:nRuns

    % Predict left out data
    prediction{iRun} = data_x{iRun}.test;
    
    % Evaluate quality of predictions using user-specified measures
    for iMeasure = 1:length(parameters.measures)
        results_temp{iMeasure}{iRun} = feval(parameters.measureHandle{iMeasure},prediction,data_y);
    end
    
end

for iMeasure = 1:length(parameters.measures)
    results{iMeasure} = mean(results_temp{iMeasure});
end

