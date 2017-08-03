function net_nonlin = integration_nonlinear_train(inputs_temp,targets,nHiddenNodes,nLayers)

numInputs = length(inputs_temp);
inputs = [];
for iInput = 1:numInputs
    inputs = vertcat(inputs,inputs_temp{iInput});
end

% Define the neural network model

numInputs = 1;%size(inputs,1);
numOutputs = size(targets,1);
numLayers = 1+nLayers;
biasConnect = logical(ones(numLayers,1));
inputConnect = logical([1; zeros(numLayers-1,1)]);
layerConnect = logical([zeros(1,numLayers);[eye(numLayers-1),zeros(numLayers-1,1)]]);
outputConnect = logical([zeros(1,numLayers-1), 1]);

clear('net_nonlin');
net_nonlin = network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect);
for iLayer = 1:numLayers-1;
    net_nonlin.layers{iLayer}.name = sprintf('Hidden%d',iLayer);
    net_nonlin.layers{iLayer}.size = nHiddenNodes;
    net_nonlin.layers{iLayer}.initFcn = 'initnw';
    net_nonlin.layers{iLayer}.transferFcn = 'tansig';
end
net_nonlin.layers{numLayers}.name = 'Output';
net_nonlin.layers{numLayers}.size = numOutputs;
net_nonlin.layers{numLayers}.initFcn = 'initnw';
net_nonlin.derivFcn = 'defaultderiv';
net_nonlin.divideFcn = 'dividerand';
net_nonlin.divideParam.trainRatio = 0.8;
net_nonlin.divideParam.valRatio = 0.2;
net_nonlin.divideParam.testRatio = 0;
net_nonlin.adaptFcn = 'adaptwb';
net_nonlin.trainFcn = 'trainlm';
net_nonlin.trainParam.showWindow = false;

net_nonlin = train(net_nonlin,inputs,targets);

% 
% net = fitnet(5);
% net = train(net,inputs,targets);
