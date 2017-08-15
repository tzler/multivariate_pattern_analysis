function data_PCA = regionModel_indepPCA_BIC_weights_V(parameters,data)

nRuns = length(data);

% center the runs

for iRun = 1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},2),1,size(data{iRun},2));
end

% for each run, concatenate the remaining runs

for iRun=1:nRuns
    data_concat = [];
    for jRun = 1:nRuns
        if jRun ~= iRun
            data_concat = horzcat(data_concat,data_center{jRun});
        end
    end
    % calculate svd
    [U_roi,S_roi,V_roi] = svd(data_concat');
    
% calculate optimal number of components
   d = size(data_concat,1);   % d is the dimensionality of the data (nVoxels)
   eigenVal = zeros(1,d);
   dmin = min(size(data_concat));
   eigenVal(1:dmin) = diag(S_roi(1:dmin,1:dmin));
   N = size(data_concat,2); % (N is the number of datapoints)
   for k = 1:d-1
      m = d*k+k*(k+1)/2;
      v = sum(eigenVal(k+1:d))/(d-k);
%        p(k) =  prod(eigenVal(1:k))^(-N/2)*v^(-N*(d-k)/2)*N^(-(m+k)/2);
      log_p(k) = log(prod(eigenVal(1:k))^(-N/2))+log(v^(-N*(d-k)/2))+log(N^(-(m+k)/2));
      scalingFactor = 1;
      while isnan(log_p(k))&&scalingFactor<1000
          e1 = (-N/2);
          e2 = (-N*(d-k)/2)/scalingFactor;
          e3 = (-(m+k)/2);
          maxExp = max([e2,e3]);
%            p(k) =  prod(eigenVal(1:k))^(-N/2)*(v^scalingFactor*N)^maxExp*v^(scalingFactor*(e2-maxExp))*N^(e3-maxExp);
          log_p(k) =  log(prod(eigenVal(1:k))^(-N/2))+log((v^scalingFactor*N)^maxExp)+log(v^(scalingFactor*(e2-maxExp)))+log(N^(e3-maxExp));
          scalingFactor = scalingFactor+1;
      end
      if scalingFactor == 1000
              log_p(k) = NaN;
      end
   end
   nPCs = find(log_p==max(log_p));
   nPCs = nPCs(1);
   if nPCs<parameters.minPCs
    nPCs = parameters.minPCs;
   end
   if nPCs>parameters.maxPCs
    nPCs = parameters.maxPCs;
   end
    % generate dimensionality-reduced roi data: extract scores for the PCs that account for most variance
    data_PCA{iRun}.train = (U_roi(:,1:nPCs)*S_roi(1:nPCs,1:nPCs))';
    data_PCA{iRun}.test = (data_center{iRun}'*V_roi(:,1:nPCs))';   % project left out run on dimensions
    data_PCA{iRun}.test_voxelSpace = data_center{iRun}; % keep the original data 
    data_PCA{iRun}.weights = diag(S_roi(1:nPCs,1:nPCs));
    data_PCA{iRun}.V = V_roi(:,1:nPCs);%,zeros(size(V_roi,1),size(V_roi,2)-nPCs)];
end
