function connectivityVector = mvpc_multipleLinearRegression_indepPCA_forSearchlight_weighted(parameters,data)

nRois = length(data);
for iRoi = 2:nRois
    r = mvpc_iconn_corr_indepPCA_weighted(data{1},data{iRoi});
    connectivityVector(1,iRoi-1) = mean(r);
    clear('r');
end

end

