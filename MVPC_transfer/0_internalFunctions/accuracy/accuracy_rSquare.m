function r2 = accuracy_rSquare(prediction, data_y)

for iRun = 1:length(prediction)
    nPCs = size(prediciton{iRun},2);
    for iPC = 1:nPCs
        r2_temp(1,iPC) = corr(prediction(:,iPC),data_y.test)^2;
    end
    r2_temp2 = (iRun) = (r2_temp*data_y.weights)/sum(data_y.weights);
    clear('nPCs','r_Temp');
end
r2 = mean(r2_temp2);