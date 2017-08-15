function [varexpl,meanVarexpl_byComp, varexpl_byComp,weights] = mvpc_neuralNet_byComponent_indepPCA(parameters,data_predicteeRegion,data_predictorRegion)

% Intitialize
nRuns = length(data_predictorRegion);


for iRun = 1:nRuns
    nPCs = size(data_predicteeRegion{iRun}.train,1);
    nVolumes = size(data_predicteeRegion{iRun}.train,2);
    
    % Generate training and testing sets
    training_predictorRegion = data_predictorRegion{iRun}.train;
    training_predicteeRegion = data_predicteeRegion{iRun}.train;
    testing_predictorRegion = data_predictorRegion{iRun}.test;
    testing_predicteeRegion = data_predicteeRegion{iRun}.test;
    
    % Train network
    net = fitnet(parameters.nNodes);
     net.trainParam.showWindow=0; % prevent MATLAB from generating a popup window
    [net,tr] = train(net,training_predictorRegion,training_predicteeRegion);
    
    % Test network
    prediction = net(testing_predictorRegion);
    
    % calculate variance by dimension
    for iPC = 1:nPCs
        r(iPC) = corr(testing_predicteeRegion(iPC,:)',prediction(iPC,:)');
        if r(iPC)>0
            varexpl_byComp(iRun,iPC) = r(iPC).^2;
        else
            varexpl_byComp(iRun,iPC) = 0;
        end
    end
    
    % calculate generalized variance
    vartot = det(cov(testing_predicteeRegion'));
    varpred = det(cov(prediction'));
    if vartot>0
        varexpl(iRun) = varpred/vartot;
    else
        varexpl(iRun) = 0;
    end
    weights{iRun}.IW = net.IW;
    weights{iRun}.LW = net.LW;
    weights{iRun}.b = net.b;

    clear('training_predictorRegion','training_predicteeRegion','testing_predictorRegion',...
        'testing_predicteeRegion','net','tr','prediction','vartot','varpred');
end

meanVarexpl_byComp = mean(varexpl_byComp,2);
