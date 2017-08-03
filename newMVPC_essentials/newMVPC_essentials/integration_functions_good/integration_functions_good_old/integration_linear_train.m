function net_lin = integration_linear_train(inputs,targets,nHiddenNodes)


% Define the neural network model
numInputs = length(inputs);
numOutputs = size(targets,1);
numLayers = 3;
biasConnect = logical([1 1 1]');
inputConnect = logical([1, 0; 0, 1;0 0]);
layerConnect = logical([0 0 0; 0 0 0; 1 1 0]);
outputConnect = logical([0 0 1]);

net_lin = network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect);

net_lin.layers{1}.name = 'Hidden1';
net_lin.layers{1}.size = nHiddenNodes;
net_lin.layers{1}.initFcn = 'initnw';
net_lin.layers{1}.transferFcn = 'tansig';
net_lin.layers{2}.name = 'Hidden2';
net_lin.layers{2}.size = nHiddenNodes;
net_lin.layers{2}.initFcn = 'initnw';
net_lin.layers{2}.transferFcn = 'tansig';
net_lin.layers{3}.name = 'Output';
net_lin.layers{3}.size = numOutputs;
net_lin.layers{3}.initFcn = 'initnw';
net_lin.trainFcn = 'trainlm';
net_lin.derivFcn = 'defaultderiv';
net_lin.divideFcn = 'dividerand';
net_lin.divideParam.trainRatio = 0.8;
net_lin.divideParam.valRatio = 0.2;
net_lin.divideParam.testRatio = 0;
net_lin.trainParam.showWindow = false;

net_lin = train(net_lin,inputs,targets);