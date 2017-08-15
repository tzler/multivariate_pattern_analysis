function results = mvpc_neuralNet_indepPCA_classification(parameters,data,labels)

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        [~, meanVarexpl_byComp{iRoi,jRoi},~,weights{iRoi,jRoi},accuracy_real(iRoi,jRoi),accuracy_predicted(iRoi,jRoi)] = mvpc_neuralNet_byComponent_indepPCA_classification(parameters,data{jRoi},data{iRoi},labels);
        connectivityMatrix(iRoi,jRoi) = mean(meanVarexpl_byComp{iRoi,jRoi});
    end
end

connectivityMatrix(connectivityMatrix<0)=0;
results.connectivityMatrix = connectivityMatrix;
results.parameters = weights;
results.accuracy_real = accuracy_real;
results.accuracy_predicted = accuracy_predicted;

end
