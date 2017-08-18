function r2 = accuracy_rSquare(prediction, data_y)

for iRun = 1:length(prediction)
    nPCs = size(prediction{iRun},1);
    for iPC = 1:nPCs
        r2_temp(1,iPC) = corr(prediction{iRun}(iPC,:)',data_y{iRun}.test')^2;
    end
    r2_temp2(iRun) = (r2_temp*data_y{iRun}.weights)/sum(data_y{iRun}.weights);
    clear('nPCs','r_Temp');
end
r2 = mean(r2_temp2);