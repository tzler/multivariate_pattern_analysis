function data_mean = mvpc_mean(parameters,data)

% data{iRun} is a matrix of size nTimepoints by nDimensions

nRuns = length(data);

% center the runs, important for leave-one run-out prediction
for iRun = 1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},1),size(data{iRun},1),1);
end

for iRun = 1:nRuns
    trainingRuns = [1:nRuns];
    trainingRuns(iRun) = [];
    data_mean{iRun}.test_voxelSpace = data_center{iRun};
    data_mean{iRun}.test = mean(data_center{iRun},2);
    data_mean{iRun}.train = [];
    for jRun = 1:length(trainingRuns)
       data_mean{iRun}.train = [data_mean{iRun}.train, mean(data_center{trainingRuns(jRun)},2)];
    end
    data_mean{iRun}.weights = 1;
    data_mean{iRun}.V = ones(size(data_center{iRun},2),1);
    % Save inverse transformation. This can be used to go back to the
    % original space of voxel responses to evaluate prediction of
    % individual voxels timecourses.
    if isfield(data{iRun},'inverse')
        data_mean{iRun}.inverse = data{iRun}.inverse;
        data_mean{iRun}.inverse{end+1} = @(prediction) prediction*data_mean{iRun}.V';
    else
        data_mean{iRun}.inverse{1} = @(prediction) prediction*data_mean{iRun}.V';
    end
end

% the parameters variable is not used but included for consistency with
% other functions

end

