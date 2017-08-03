function mvpc_multiRegionIntegration(iSubject)

% Set inputs
subjects = [1,3,4,5,8,12:17];
regionLabels = {'PCaud'  'PCvis'  'facesOnly_roi'  'lSTG'  'lSTS'  'rSTG'  'rSTS'  'voiceOnly_roi'};
predictorRois = [3, 8];
predicteeRois = [1,2,4:7];
savePath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/interactionModels_multimodalIntegration/subsub%02d_imodel.mat',subjects(iSubject));
nIterations = 2;

% Load data for one subject
regionModel_fileName = sprintf('subsub%02d_rmodel01.mat',subjects(iSubject));
regionModel_filePath = fullfile('/mindhive/saxelab3/anzellotti/facesVoices_art2/regionModels_multimodalIntegration',regionModel_fileName);

load(regionModel_filePath);
nRoisTarget = length(predicteeRois);
nRoisInput = length(predictorRois);
nRuns = length(preprocdata{1});

for iRoi = 1:nRoisTarget  
    % Cross validate across runs
    for iRun = 1:nRuns
        for nLayers = 1:3
        for nHiddenNodes = 1:3
            % Format training and testing data for target regions
            training_targets = preprocdata{predicteeRois(iRoi)}{iRun}.train;
            testing_targets = preprocdata{predicteeRois(iRoi)}{iRun}.test;
            % Format training and testing data for predictor regions
            for jRoi = 1:nRoisInput
                training_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.train;
                testing_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.test;
            end
            
            numInputs = length(training_inputs);
            % Scale inputs
            for iInput = 1:numInputs
                inputsScalingFactor_temp(iInput) = max(max(abs(training_inputs{iInput})));
            end
            inputsScalingFactor = max(inputsScalingFactor_temp);
            for iInput = 1:numInputs
                training_inputs_scaled{iInput} = training_inputs{iInput}/inputsScalingFactor;
                testing_inputs_scaled{iInput} = testing_inputs{iInput}/inputsScalingFactor;
            end
            % Scale targets
            targetsScalingFactor = max(max(abs(training_targets)));
            training_targets_scaled = training_targets/targetsScalingFactor;
            testing_targets_scaled = testing_targets/targetsScalingFactor;
            
            for iIteration = 1:nIterations
                % Train and test model with linear integration of modalities
                net_lin = integration_linear_train(training_inputs_scaled',training_targets_scaled,nHiddenNodes,nLayers);
                varexpl_lin(iRoi,iRun,nHiddenNodes,nLayers,iIteration) = integration_linear_test(net_lin,testing_inputs_scaled',testing_targets_scaled);
                % Train and test model with nonlinear integration of modalities
                net_nonlin = integration_nonlinear_train(training_inputs_scaled',training_targets_scaled,nHiddenNodes,nLayers);
                varexpl_nonlin(iRoi,iRun,nHiddenNodes,nLayers,iIteration) = integration_nonlinear_test(net_nonlin,testing_inputs_scaled',testing_targets_scaled);
                % Store
                net_lin_storage{iRoi,iRun,nHiddenNodes,nLayers,iIteration} = net_lin;
                net_nonlin_storage{iRoi,iRun,nHiddenNodes,nLayers,iIteration} = net_nonlin;
            end
            clear('training_targets','testing_targets','training_inputs','testing_inputs','numIputs',...
                'inputsScalingFactor_temp','inputsScalingFactor','training_inputs_scaled','testing_inputs_scaled',...
                'targetsScalingFactor','training_targets_scaled','testing_targets_scaled','net_lin','net_nonlin');
        end
        end
    end
end

save(savePath, 'net_lin_storage','varexpl_lin','net_nonlin_storage','varexpl_nonlin','-v7.3');
