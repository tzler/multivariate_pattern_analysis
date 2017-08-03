function [varexpl, meanVarexpl_byComp, varexpl_byComp] = mvpc_iconnIndep_mutualPred_byComponent_indepPCA(seedData_reduced,sphereData_reduced)


% calculate mutual predictivity
nRuns = length(sphereData_reduced);
% calculate beta values for each run
for iRun = 1:nRuns
    
    % simplify the names of training and testing data
    nPCs = size(seedData_reduced{iRun}.train,1);
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
        beta{iRun} = ones(nPCs+1,nPCs)*NaN;
    end
    
    % predict left out data
    if ~sum(sum(isnan(beta{iRun})))
    predicted = [ones(size(sphereData_test,2),1),sphereData_test']*beta{iRun};
    residual = seedData_test' - predicted;
     % calculate variance explained by dimension
       for iPC = 1:nPCs
           vartot = var(seedData_test(iPC,:));
           varpred = vartot-var(residual(:,iPC));
           varexpl_byComp(iRun,iPC) = varpred/vartot;
       end
       % calculate generalized variance
       vartot = det(cov(seedData_test'));
       varpred = det(cov(predicted));
       if vartot>0
           varexpl(iRun) = varpred/vartot;
       else
           varexpl(iRun) = 0;
       end
   else
       varexpl(iRun) = 0;
       varexpl_byComp(iRun,:) = zeros(1,nPCs);
   end   
end

meanVarexpl_byComp = mean(varexpl_byComp,2);
