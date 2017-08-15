function varexpl_mean = accuracy_varexpl_ledoitWolf(prediction, data_y)

for iRun = 1:length(prediction)
    prediction_vox = feval(data_y.inverse,prediction{iRun});
     [varexpl(iRun),vardiff(iRun)] = ledoitWolf_varexpl(data_y{iRun}.test_voxelSpace,prediction_vox);
     clear('prediction_vox');
end

varexpl_mean = mean(varexpl);
