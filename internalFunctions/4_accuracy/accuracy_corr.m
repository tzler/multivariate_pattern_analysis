function r = accuracy_corr(prediction, data_y)

for iRun = 1:length(prediction)
    nPCs = size(prediciton{iRun},2);
    for iPC = 1:nPCs
        r_temp(1,iPC) = corr(prediction(:,iPC),data_y.test)
    end
    r_temp2 = (iRun) = (r_temp*data_y.weights)/sum(data_y.weights);
    clear('nPCs','r_Temp');
end
r = mean(r_temp2);