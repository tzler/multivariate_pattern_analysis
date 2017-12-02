function data_PCA = mvpc_PCA(parameters,data)

nRuns = length(data);
% center and concatenate the runs
data_concat = [];
for iRun=1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},2),1,size(data{iRun},2));
    data_concat = horzcat(data_concat,data_center{iRun});
end
% calculate svd
[U_roi,S_roi,V_roi] = svd(data_concat');
% generate dimensionality-reduced roi data: extract scores for the PCs that account for most variance
data_concat_reduced = (U_roi(:,1:parameters.nPCs)*S_roi(1:parameters.nPCs,1:parameters.nPCs))';
% separate the different runs
startVolume = 1;
for iRun = 1:nRuns
    nVolumes = size(data{iRun},2);
    data_PCA{iRun} = data_concat_reduced(:,startVolume:startVolume+nVolumes-1);
    startVolume = startVolume + nVolumes;
end

end

