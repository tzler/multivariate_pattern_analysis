function [r, varexpl,vardiff,r_vox,r2_vox,varexpl_vox,vardiff_vox] = mvpc_lin_wV_manyStats(seedData_reduced,sphereData_reduced)


% calculate mutual predictivity
nRuns = length(sphereData_reduced);
% calculate beta values for each run
for iRun = 1:nRuns
    
    % simplify the names of training and testing data
    nPCsSeed = size(seedData_reduced{iRun}.train,1);
    nPCsSphere = size(sphereData_reduced{iRun}.train,1);
    seedData_train = seedData_reduced{iRun}.train;
    seedData_test = seedData_reduced{iRun}.test;
    sphereData_train = sphereData_reduced{iRun}.train;
    sphereData_test = sphereData_reduced{iRun}.test;

    % estimate the model
    try
        X = [ones(size(sphereData_train,2),1),sphereData_train'];
        Y = seedData_train';
        beta{iRun} = mldivide(X,Y);
    catch
        beta{iRun} = ones(nPCsSphere+1,nPCsSeed)*NaN;
    end
    
    % predict left out data
    if ~sum(sum(isnan(beta{iRun})))
    predicted = [ones(size(sphereData_test,2),1),sphereData_test']*beta{iRun};
%     residual = seedData_test' - predicted;
     % calculate variance explained by dimension
       for iPC = 1:nPCsSeed
           r_temp(iPC) = corr(predicted(:,iPC),seedData_test(iPC,:)');
       end
    else
       r_temp = zeros(1,nPCsSeed);
    end   
   r(iRun) = (r_temp*seedData_reduced{iRun}.weights)/sum(seedData_reduced{iRun}.weights);
   [varexpl(iRun),vardiff(iRun)] = ledoitWolf_varexpl_manyStats(seedData_reduced{iRun}.test_voxelSpace',predicted*seedData_reduced{iRun}.V');
   r_vox = mean(corr(predicted,seedData_reduced{iRun}.test_voxelSpace'));
   r2_vox = mean(corr(predicted,seedData_reduced{iRun}.test_voxelSpace').^2);
   vardiff_vox = mean(var(seedData_reduced{iRun}.test_voxelSpace',[],2)-var(seedData_reduced{iRun}.test_voxelSpace'-predicted*seedData_reduced{iRun}.V',[],2));
   varexpl_vox = mean(vardiff_vox./var(seedData_reduced{iRun}.test_voxelSpace',[],2));
end

