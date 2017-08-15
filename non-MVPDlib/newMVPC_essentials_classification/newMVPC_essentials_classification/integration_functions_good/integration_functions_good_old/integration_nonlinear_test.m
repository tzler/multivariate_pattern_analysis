function varexpl = integration_nonlinear_test(net,inputs_temp,targets)

inputs = [];
for iInput = 1:length(inputs_temp)
    inputs = vertcat(inputs,inputs_temp{iInput});
end

prediction = net(inputs);
for iDim = 1:size(targets,1);
    r(iDim) = corr(prediction(iDim,:)',targets(iDim,:)');
    if r(iDim) <0
        r(iDim) = 0;
    end
end

varexpl = mean(r.^2);
