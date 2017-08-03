function varexpl = varPC_varexpl(Y,Y_pred)
% generalized variance calculated with a diagonal approximation of covariance matrices
warning('varPC_varexpl produces very unstable results.')
nTimepoints = size(Y,1);
digits(32);
[U, S, V] = svd(Y);
nPCs = min(find(cumsum(diag(S))/sum(diag(S))>0.9));
Y_reduced = Y*V(:,1:nPCs);
Y_pred_reduced = Y_pred*V(:,1:nPCs);

genvar_Y = det(cov(Y_reduced)); % determinant of covariance matrix of Y
genvar_R = det(cov(Y_reduced-Y_pred_reduced)); % determinant of covariance matrix of residuals 
varexpl = (genvar_Y-genvar_R)/genvar_Y;
digits(16);