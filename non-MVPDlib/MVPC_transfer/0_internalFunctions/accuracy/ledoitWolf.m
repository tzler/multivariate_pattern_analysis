function [S_lw,parameters] = ledoitWolf(Y)

% Calculate the Ledoit-Wolf covariance estimator for the data Y
digits(32)
nTimepoints = size(Y,1);
nVoxels = size(Y,2);
Y_centered = Y - repmat(mean(Y,1),nTimepoints,1);
S_n = Y_centered'*Y_centered/nTimepoints; % dividing by n rather than n-1 as in the original paper
m_n = trace(S_n*eye(size(S_n))')/nVoxels; % inner product associated with the Frobenius norm
temp1 = S_n-m_n*eye(size(S_n));
d_n = trace(temp1*temp1')/nVoxels;
tempSum = 0;
for iTimepoint = 1:nTimepoints
   tempMat = Y_centered(iTimepoint,:)'*Y_centered(iTimepoint,:)-S_n;
   tempSum = tempSum + trace(tempMat*tempMat')/nVoxels;
end
b_n_temp1 = (1/(nTimepoints^2))*tempSum;
b_n = min(b_n_temp1,d_n);
a_n = d_n-b_n;
S_lw = (b_n/d_n)*m_n*eye(size(S_n)) + (a_n/d_n)*S_n;
parameters.a_n = a_n;
parameters.b_n = b_n;
parameters.d_n = d_n;
parameters.m_n = m_n;