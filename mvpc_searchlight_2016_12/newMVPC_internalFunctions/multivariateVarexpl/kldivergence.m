function dkl = kldivergence(Y,Y_pred)

% kl divergence calculated approximating the distributions as normal
nTimepoints = size(Y,1);
nVoxels = size(Y,2);
digits(32);
mean_Y = mean(Y,1);
cov_Y = cov(Y);
mean_Y_pred = mean(Y_pred,1);
cov_Y_pred = cov(Y_pred); 
% inv_cov_Y_pred = inv(cov_Y_pred); 
meanDiff = mean_Y_pred-mean_Y;
dkl = (1/2)*(trace(cov_Y_pred\cov_Y)+(cov_Y_pred\meanDiff')'*meanDiff'-nVoxels+log(det(cov_Y_pred))-log(det(cov_Y)));
digits(16);