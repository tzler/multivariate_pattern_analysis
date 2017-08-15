function varexpl = diagGenVar_varexpl(Y,Y_pred)
% generalized variance calculated with a diagonal approximation of covariance matrices
nTimepoints = size(Y,1);
digits(32);
genvar_Y = prod(diag(cov(Y))); % determinant of covariance matrix of Y
genvar_R = prod(diag(cov(Y-Y_pred))); % determinant of covariance matrix of residuals 
varexpl = (genvar_Y-genvar_R)/genvar_Y;
digits(16);