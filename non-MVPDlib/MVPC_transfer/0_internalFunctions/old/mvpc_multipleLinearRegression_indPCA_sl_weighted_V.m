function results = mvpc_multipleLinearRegression_indPCA_sl_weighted_V(parameters,data)

nRois = length(data);
for iRoi = 2:nRois
    [r, varexpl_temp] = mvpc_iconn_corr_indepPCA_weighted_V(data{1},data{iRoi});
    connectivityVector(1,iRoi-1) = mean(r);
    varexpl(1,iRoi-1) = mean(varexpl_temp);
    clear('varexpl_temp');
end

results(1) = connectivityVector;
results(2) = varexpl;

end

