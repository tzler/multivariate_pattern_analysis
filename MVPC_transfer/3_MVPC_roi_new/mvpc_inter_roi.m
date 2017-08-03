function connectivityMatrix = mvpc_inter_roi(functionHandle, parameters,data)

nRois = length(data);
for iRoi = 1:nRois
    for jRoi = 1:nRois
        results_temp = feval(functionHandle,parameters,data{jRoi},data{iRoi});
        nMeasures = length(results_temp);
        for iMeasure = 1:nMeasures % reformat with measures outside
            connectivityMatrix{iMeasure}(iRoi,jRoi) = results_temp{iMeasure};
        end
    end
end

end

