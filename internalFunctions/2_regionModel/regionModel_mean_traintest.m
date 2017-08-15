function data_mean = regionModel_mean_traintest(parameters,data)

% center the runs, important for leave-one run-out prediction
nRuns = length(data);
for iRun = 1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},2),1,size(data{iRun},2));
end

nRuns = length(data);
for iRun = 1:nRuns
    trainingRuns = [1:nRuns];
    trainingRuns(iRun) = [];
    data_mean{iRun}.test_voxelSpace = data_center{iRun};
    data_mean{iRun}.test = mean(data_center{iRun},1);
    data_mean{iRun}.train = [];
    for jRun = 1:length(trainingRuns)
       data_mean{iRun}.train = [data_mean{iRun}.train, mean(data_center{trainingRuns(jRun)},1)];
    end
    data_mean{iRun}.weights = 1;
    data_mean{iRun}.V = ones(size(data_center{iRun},1),1);
end

% the parameters variable is not used but included for consistency with
% other functions

end

