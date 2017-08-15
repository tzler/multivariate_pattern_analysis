function varexpl = ledoitWolf_varexpl(Y,Y_pred)

% Given two multivariate timecourses scaled_data_temp, scaled_data_red_vox,
% where scaled_data_red_vox is a prediction of scaled_data_temp, this
% function uses the Ledoit-Wolf well-conditioned covariance matrix
% estimator to calculate the ratio of generalized variance explained by a
% multivariate model. 

% For the underlying theory, see Ledoit and Wolf (2004), A well-conditioned
% estimator for large-dimensional covariance matrices.

% First calculate the Ledoit-Wolf covariance estimator for the data Y
nTimepoints = size(Y,1);
% nVoxels = size(Y,2);
% Y_centered = Y - repmat(mean(Y,1),nTimepoints,1);
% S_n = Y_centered'*Y_centered/nTimepoints; % dividing by n rather than n-1 as in the original paper
% m_n = trace(S_n*eye(size(S_n))')/nVoxels; % inner product associated with the Frobenius norm
% temp1 = S_n-m_n*eye(size(S_n));
% d_n = trace(temp1*temp1')/nVoxels;
% tempSum = 0;
% for iTimepoint = 1:nTimepoints
%    tempMat = Y_centered(iTimepoint,:)'*Y_centered(iTimepoint,:)-S_n;
%    tempSum = tempSum + trace(tempMat*tempMat')/nVoxels;
% end
% b_n_temp1 = (1/(nTimepoints^2))*tempSum;
% b_n = min(b_n_temp1,d_n);
% a_n = d_n-b_n;
% S_good = (b_n/d_n)*m_n*eye(size(S_n)) + (a_n/d_n)*S_n;
[S_good,S_parameters] = ledoitWolf(Y);
% Then calculate the residuals and apply the same parameters: the idea is
% that to the extent that we are uncertain of the covariance matrix of the
% residuals, we add the identity matrix to the same extent as we added it
% to the covariance matrix of the data Y (S_n), thus making the covariance
% matrix of the residuals more similar to the covariance matrix of the
% original data. This will reduce the difference between the determinants
% of the two matrices: it means that to the extent that we are uncertain
% about the covariance matrix of the residuals, we consider the
% corresponding variance unexplained.
residuals = Y-Y_pred;
residuals_centered = residuals;% - repmat(mean(residuals,1),size(residuals,1),1);
R_n = residuals_centered'*residuals_centered/nTimepoints;
R_good = (S_parameters.b_n/S_parameters.d_n)*S_parameters.m_n*eye(size(R_n)) + (S_parameters.a_n/S_parameters.d_n)*R_n;
%  [R_good,R_parameters] = ledoitWolf(Y-Y_pred);

varexpl = (det(S_good)-det(R_good))/det(S_good);
