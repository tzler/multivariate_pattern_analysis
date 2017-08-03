function data_mean = mvpc_mean(parameters,data)

for iRun = 1:length(data)
    data_mean{iRun} = mean(data{iRun},1);
end

% the parameters variable is not used but included for consistency with
% other functions

end

