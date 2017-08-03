function data_PCA = mvpc_indepPCA_1PC_weights_V(parameters,data)

nRuns = length(data);
iPC = parameters.iPC;

% center the runs

for iRun = 1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},2),1,size(data{iRun},2));
end

% for each run, concatenate the remaining runs

for iRun=1:nRuns
    data_concat = [];
    for jRun = 1:nRuns
        if jRun ~= iRun
            data_concat = horzcat(data_concat,data_center{jRun});
        end
    end
    % calculate svd
    [U_roi,S_roi,V_roi] = svd(data_concat');
    % generate dimensionality-reduced roi data: extract scores for the requested PC
    data_PCA{iRun}.train = (U_roi(:,iPC:iPC)*S_roi(iPC,iPC))';
    data_PCA{iRun}.test = (data_center{iRun}'*V_roi(:,iPC))';   % project left out run on dimensions
    data_PCA{iRun}.test_voxelSpace = data_center{iRun}; % keep the original data 
    data_PCA{iRun}.weights = S_roi(iPC,iPC);
    data_PCA{iRun}.V = V_roi(:,iPC);%,zeros(size(V_roi,1),size(V_roi,2)-nPCs)];
end
