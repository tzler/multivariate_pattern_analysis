function varexpl_vox_mean = accuracy_varexpl_vox_mean(prediction, data_y)

for iRun = 1:length(prediction)
    prediction_vox = feval(data_y.inverse,prediction{iRun});
    vardiff_vox = mean(var(data_y{iRun}.test_voxelSpace,[],1)-var(data_y{iRun}.test_voxelSpace-prediction_vox,[],1));
   varexpl_vox(iRun) = mean(vardiff_vox./var(data_y{iRun}.test_voxelSpace,[],1));
   clear('prediction_vox','vardiff_vox');
end

varexpl_vox_mean = mean(varexpl_vox);