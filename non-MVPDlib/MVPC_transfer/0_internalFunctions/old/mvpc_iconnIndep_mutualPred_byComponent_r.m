function r = mvpc_iconnIndep_mutualPred_byComponent_r(seedData_reduced,sphereData_reduced)


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
   if size(meanBeta,1)<size(meanBeta,2)
      meanBeta = meanBeta'; 
   end
   if ~sum(sum(isnan(meanBeta)))
       nVolumes = size(sphereData_reduced{iRun},2);
       predicted = [ones(nVolumes,1),sphereData_reduced{iRun}']*meanBeta;
       % calculate variance by dimension
       nPCs = size(sphereData_reduced{iRun},1);
       for iPC = 1:nPCs
           r_temp(iRun,iPC) = corr(predicted,sphereData_reduced{iRun}(iPC,:)');
       end
   else
       for iPC = 1:nPCs
           r_temp(iRun,iPC) = 0;
       end
   end   
end
r = squeeze(mean(r_temp,2));
   