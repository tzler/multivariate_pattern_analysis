function connectivityMatrix = mvpc_multipleLinearRegression_r(parameters,data)

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        r{iRoi,jRoi} = mvpc_iconnIndep_mutualPred_byComponent_r(data{jRoi},data{iRoi});
        connectivityMatrix(iRoi,jRoi) = mean(r{iRoi,jRoi});
    end
end

end

