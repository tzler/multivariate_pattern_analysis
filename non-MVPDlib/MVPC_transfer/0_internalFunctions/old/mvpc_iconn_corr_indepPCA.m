function r = mvpc_iconn_corr_indepPCA(seedData_reduced,sphereData_reduced)


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
           r(iRun,iPC) = corr(predicted(:,iPC),seedData_test(iPC,:)');
       end
    else
       r(iRun,:) = zeros(1,nPCsSeed);
   end   
end

