function data_demean = regionModel_demean(parameters,data)

for iRun = 1:length(data)
    data_mean{iRun} = mean(data{iRun},1);
    data_demean{iRun} = data{iRun}-repmat(data_mean{iRun},size(data{iRun},1),1);
end

end

