function data_PCA = mvpc_indepPCA_BIC(parameters,data)

nRuns = length(data);

% center the runs

for iRun = 1:nRuns
    data_center{iRun} = data{iRun} - repmat(mean(data{iRun},2),1,size(data{iRun},2));
end

% for each run, concatenate the remaining runs
data_concat = [];
for iRun=1:nRuns
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
       p(k) =  prod(eigenVal(1:k))^(-N/2)*v^(-N*(d-k)/2)*N^(-(m+k)/2);
    end
    nPCs = find(p==max(p));
    nPCs = max(nPCs(1),parameters.minPCs);
    
    % generate dimensionality-reduced roi data: extract scores for the PCs that account for most variance
    data_PCA{iRun}.train = (U_roi(:,1:nPCs)*S_roi(1:nPCs,1:nPCs))';
    data_PCA{iRun}.test = (data_center{iRun}'*V_roi(:,1:nPCs))';   % project left out run on dimensions
end
