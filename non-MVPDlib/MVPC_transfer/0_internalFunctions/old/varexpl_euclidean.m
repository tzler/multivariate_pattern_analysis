function varexpl = euclidean_varexpl(Y,Y_pred)

nTimepoints = size(Y,1);

% Calculate the sum of square euclidean distances from 0 of the original data
Y_centered = Y - repmat(mean(Y,1),nTimepoints,1); % first remove the mean
distances2_Y = diag(Y_centered*Y_centered');
SS_Y = sum(distances2_Y);
% Calculate residuals
residuals = Y-Y_pred;
% residuals_centered = residuals - repmat(mean(residuals,1),nTimepoints,1); % first remove the mean
distances2_residuals = diag(residuals*residuals');
SS_R = sum(distances2_residuals);
varexpl = (SS_Y-SS_R)/SS_Y;