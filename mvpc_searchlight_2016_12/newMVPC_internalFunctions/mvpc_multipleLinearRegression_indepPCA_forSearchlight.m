function connectivityVector = mvpc_multipleLinearRegression_indepPCA_forSearchlight(parameters,data)

nRois = length(data);
for iRoi = 2:nRois
    r = mvpc_iconn_corr_indepPCA(data{1},data{iRoi});
    connectivityVector(1,iRoi-1) = mean(mean(r));
    clear('r');
end

end

