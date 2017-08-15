function net_nonlin = integration_nonlinear_train(inputs_temp,targets,nHiddenNodes)

numInputs = length(inputs_temp);
inputs = [];
for iInput = 1:numInputs
    inputs = vertcat(inputs,inputs_temp{iInput});
end

% Define the neural network model

numInputs = 1;%size(inputs,1);
numOutputs = size(targets,1);
numLayers = 2;
biasConnect = logical([1; 1]);
inputConnect = logical([1; 0]);
layerConnect = logical([0 0; 1 0]);
outputConnect = logical([0 1]);

clear('net_nonlin');
net_nonlin = network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect);
net_nonlin.layers{1}.name = 'Hidden';
net_nonlin.layers{1}.size = nHiddenNodes;
net_nonlin.layers{1}.initFcn = 'initnw';
net_nonlin.layers{1}.transferFcn = 'tansig';
net_nonlin.layers{2}.name = 'Output';
net_nonlin.layers{2}.size = numOutputs;
net_nonlin.layers{2}.initFcn = 'initnw';
net_nonlin.derivFcn = 'defaultderiv';
net_nonlin.divideFcn = 'dividerand';
net_nonlin.divideParam.trainRatio = 0.8;
net_nonlin.divideParam.valRatio = 0.2;
net_nonlin.divideParam.testRatio = 0.0;
net_nonlin.adaptFcn = 'adaptwb';
net_nonlin.trainFcn = 'trainlm';
net_nonlin.trainParam.showWindow = false;

net_nonlin = train(net_nonlin,inputs,targets);

% 
%  net = fitnet(5);
%  net = train(net,inputs,targets);
