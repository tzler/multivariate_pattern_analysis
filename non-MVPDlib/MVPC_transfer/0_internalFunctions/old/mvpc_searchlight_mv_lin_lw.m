function connectivityVector = mvpc_searchlight_mv_lin_lw(parameters,data)

nRois = length(data);
for iRoi = 2:nRois
    varexpl = mvpc_searchlight_mv_lin_lw_inside(data{1},data{iRoi});
    connectivityVector(1,iRoi-1) = mean(varexpl);
    clear('varexpl');
end

end

