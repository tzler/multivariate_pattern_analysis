function varexpl = mvpc_searchlight_mv_lin_lw_inside(seedData_reduced,sphereData_reduced)


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
     % calculate variance explained with Ledoit-Wolf generalized variance
        vaerxpl(iRun) = ledoitWolf_varexpl(predicted,seedData_test');
    else
       varexpl(iRun) = 0;
   end   
end

