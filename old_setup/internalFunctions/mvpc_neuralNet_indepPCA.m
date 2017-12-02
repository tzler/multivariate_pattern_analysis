function connectivityMatrix = mvpc_neuralNet_indepPCA(parameters,data)

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        [~, meanVarexpl_byComp{iRoi,jRoi},~] = mvpc_neuralNet_byComponent_indepPCA(parameters,data{jRoi},data{iRoi});
        connectivityMatrix(iRoi,jRoi) = mean(meanVarexpl_byComp{iRoi,jRoi});
    end
end

connectivityMatrix(connectivityMatrix<0)=0;

end
