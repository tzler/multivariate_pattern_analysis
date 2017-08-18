function data_lowPass = regionModel_lowPass(parameters,data)

% generate low pass filter
lowPassFrequencyRadSamp = (2*pi*parameters.lowPassFrequencyHz)/parameters.TR;
lowPassFilter = fir1(34,lowPassFrequencyRadSamp);

% filter data
for iRun = 1:length(data)
    for iDimension = 1:size(data{iRun},2)
        data_lowPass{iRun}.train(iDimension,:) = filter(lowPassFilter,1,data{iRun}.train(iDimension,:));
        data_lowPass{iRun}.test(iDimension,:) = filter(lowPassFilter,1,data{iRun}.test(iDimension,:));
    end
    data_lowPass{iRun}.V = data{iRun}.V;
    data_lowPass{iRun}.weights = data{iRun}.weights;
    data_lowPass{iRun}.inverse = data{iRun}.inverse;
    data_lowPass{iRun}.test_voxelSpace = data{iRun}.test_voxelSpace;
end

end

