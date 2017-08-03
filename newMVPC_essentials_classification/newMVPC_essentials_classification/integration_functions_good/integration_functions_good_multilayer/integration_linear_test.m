function varexpl = integration_linear_test(net,inputs,targets)

prediction = net(inputs);
for iDim = 1:size(targets,1);
    r(iDim) = corr(prediction{1}(iDim,:)',targets(iDim,:)');
    if r(iDim) <0
        r(iDim) = 0;
    end
end

varexpl = mean(r.^2);
