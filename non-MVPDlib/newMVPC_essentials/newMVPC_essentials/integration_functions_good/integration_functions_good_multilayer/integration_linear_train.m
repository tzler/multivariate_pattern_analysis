function net_lin = integration_linear_train(inputs,targets,nHiddenNodes,nLayers)


% Define the neural network model
numInputs = length(inputs);
numOutputs = size(targets,1);
numLayers = 1+nLayers*2;
biasConnect = logical(ones(numLayers,1));
inputConnect = logical([1, 0; 0, 1;zeros(numLayers-2,2)]);
layerConnect = logical([zeros(2,numLayers);[eye(numLayers-3),zeros(numLayers-3,3)];[zeros(1,numLayers-3), 1, 1, 0]]);
outputConnect = logical([zeros(1,numLayers-1), 1 ]);

net_lin = network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect);

for iLayer = 1:numLayers-1
    net_lin.layers{iLayer}.name = sprintf('Hidden%d',iLayer);
    net_lin.layers{iLayer}.size = nHiddenNodes;
    net_lin.layers{iLayer}.initFcn = 'initnw';
    net_lin.layers{iLayer}.transferFcn = 'tansig';
end

net_lin.layers{numLayers}.name = 'Output';
net_lin.layers{numLayers}.size = numOutputs;
net_lin.layers{numLayers}.initFcn = 'initnw';
net_lin.trainFcn = 'trainlm';
net_lin.derivFcn = 'defaultderiv';
net_lin.divideFcn = 'dividerand';
net_lin.divideParam.trainRatio = 0.8;
net_lin.divideParam.valRatio = 0.2;
net_lin.divideParam.testRatio = 0;
net_lin.trainParam.showWindow = false;

net_lin = train(net_lin,inputs,targets);