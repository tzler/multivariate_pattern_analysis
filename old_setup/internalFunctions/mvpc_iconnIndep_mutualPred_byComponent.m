function [varexpl, meanVarexpl_byComp, varexpl_byComp] = mvpc_iconnIndep_mutualPred_byComponent(seedData_reduced,sphereData_reduced)


% calculate mutual predictivity
nRuns = length(sphereData_reduced);
nPCs = size(sphereData_reduced{1},1);
% calculate beta values for each run
for iRun = 1:nRuns
    seedData_reduced_run = seedData_reduced{iRun};
    sphereData_reduced_run = sphereData_reduced{iRun};
    nVolumes = size(sphereData_reduced_run,2);
    try
        X = [ones(nVolumes,1),sphereData_reduced_run'];
        Y = seedData_reduced_run';
        beta(iRun,:,:) = mldivide(X,Y);
    catch
        beta(iRun,:,:) = ones(nPCs+1,nPCs)*NaN;
    end
end
% for each run, average the betas from the other runs and predict it
for iRun = 1:nRuns
   beta_temp = beta;
   beta_temp(iRun,:,:) = [];
  meanBeta = squeeze(nanmean(beta_temp,1)); %DAE changed to nanmean2 b/c nanmean appeared to have been overwritten
%    if size(meanBeta,1)<size(meanBeta,2)
%       meanBeta = meanBeta'; 
%    end
   if ~sum(sum(isnan(meanBeta)))
       nVolumes = size(sphereData_reduced{iRun},2);
       predicted = [ones(nVolumes,1),sphereData_reduced{iRun}']*meanBeta;
       residual = seedData_reduced{iRun}' - predicted;
       % calculate variance by dimension
       nPCs = size(residual,2);
       for iPC = 1:nPCs
           vartot = var(seedData_reduced{iRun}(iPC,:));
           varpred = vartot-var(residual(:,iPC));
           varexpl_byComp(iRun,iPC) = varpred/vartot;
       end
       % calculate generalized variance
       vartot = det(cov(seedData_reduced{iRun}'));
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
