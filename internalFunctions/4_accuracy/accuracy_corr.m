function r = accuracy_corr(prediction, data_y)

for iRun = 1:length(prediction)
    nPCs = size(prediction{iRun},1);
    for iPC = 1:nPCs
        r_temp(1,iPC) = corr(prediction{iRun}(iPC,:)',data_y{iRun}.test(iPC,:)');
    end
    r_temp2(iRun) = (r_temp*data_y{iRun}.weights)/sum(data_y{iRun}.weights);
    clear('nPCs','r_Temp');
end
r = mean(r_temp2);