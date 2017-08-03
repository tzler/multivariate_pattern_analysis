function data_lowPass = mvpc_lowPass(parameters,data)

% generate low pass filter
lowPassFrequencyRadSamp = (2*pi*parameters.lowPassFrequencyHz)/parameters.TR;
lowPassFilter = fir1(34,lowPassFrequencyRadSamp);

% filter data
for iRun = 1:length(data)
    for iDimension = 1:size(data,1)
        data_lowPass{iRun}(iDimension,:) = filter(lowPassFilter,1,data{iRun}(iDimension,:));
    end
end

end

