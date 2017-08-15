function prediction = interactionModel_nn(parameters,data_y,data_x)

% data_x is the data used as independent variable
% data_y is the data used as dependent variable

% Intitialize
nRuns = length(data_x);

for iRun = 1:nRuns
    nPCs = size(data_y{iRun}.train,1);
    nVolumes = size(data_y{iRun}.train,2);
    
    % Estimate the model (train network)
    net = fitnet(parameters.nNodes);
     net.trainParam.showWindow=0; % prevent MATLAB from generating a popup window
    [net,tr] = train(net,data_x{iRun}.train,data_y{iRun}.train);
    
    % Predict left out data
    prediction{iRun} = net(data_x{iRun}.test);
    
    % Evaluate quality of predictions using user-specified measures
    for iMeasure = 1:length(parameters.measures)
        results_temp{iMeasure}{iRun} = feval(parameters.measureHandle{iMeasure},prediction,data_y);
    end

    clear('net','tr');
end

for iMeasure = 1:length(parameters.measures)
    results{iMeasure} = mean(results_temp{iMeasure});
end


