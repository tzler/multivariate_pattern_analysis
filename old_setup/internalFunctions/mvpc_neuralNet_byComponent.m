function [varexpl,meanVarexpl_byComp, varexpl_byComp] = mvpc_neuralNet_byComponent(parameters,data_predicteeRegion,data_predictorRegion)

% Intitialize
nRuns = length(data_predictorRegion);
nPCs = size(data_predicteeRegion{1},1);
nVolumes = size(data_predicteeRegion{1},2);

for iRun = 1:nRuns
    
    % Generate training and testing sets
    training_predictorRegion = [];
    training_predicteeRegion = [];
    testing_predictorRegion = [];
    testing_predicteeRegion = [];
    for jRun = 1:nRuns
        if jRun~=iRun
            training_predictorRegion = horzcat(training_predictorRegion,data_predictorRegion{jRun});
            training_predicteeRegion = horzcat(training_predicteeRegion,data_predicteeRegion{jRun});
        else
            testing_predictorRegion = horzcat(testing_predictorRegion,data_predictorRegion{jRun});
            testing_predicteeRegion = horzcat(testing_predicteeRegion,data_predicteeRegion{jRun});
        end
    end
    
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
    
    clear('training_predictorRegion','training_predicteeRegion','testing_predictorRegion',...
        'testing_predicteeRegion','net','tr','prediction','vartot','varpred');
end

meanVarexpl_byComp = mean(varexpl_byComp,2);