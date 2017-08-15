function connectivityMatrix = mvpc_multipleLinearRegression(parameters,data)

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        [~, meanVarexpl_byComp{iRoi,jRoi},~] = mvpc_iconnIndep_mutualPred_byComponent(data{jRoi},data{iRoi});
        connectivityMatrix(iRoi,jRoi) = mean(meanVarexpl_byComp{iRoi,jRoi});
    end
end

connectivityMatrix(connectivityMatrix<0)=0;

end

