function mvpc_multiRegionIntegration_nestedXval(iSubject)

% Set inputs
subjects = [1,3,4,5,8,12:17];
regionLabels = {'PCaud'  'PCvis'  'facesOnly_roi'  'lSTG'  'lSTS'  'rSTG'  'rSTS'  'voiceOnly_roi'};
predictorRois = [3, 8];
predicteeRois = [1,2,4:7];
savePath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/interactionModels_multimodalIntegration/subsub%02d_imodel.mat',subjects(iSubject));
nIterations = 1;

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
           runs = [1:5];
           runs(iRun)=[];
        % Choose model with nested cross-validation
        for jRun = 1:nRuns-1
            indexesStart = 0;
            for kRun = 1:length(runs)
                if kRun~=jRun
                    indexes{kRun} = indexesStart+1:indexesStart+size(preprocdata{predicteeRois(iRoi)}{runs(kRun)}.test,2);
                else
                    indexes{kRun} = [];
                end
                indexesStart = indexesStart+size(preprocdata{predicteeRois(iRoi)}{runs(kRun)}.test,2);
            end
            allindexes = [indexes{:}];
            logicindexes = zeros(1,size(preprocdata{predicteeRois(iRoi)}{iRun}.train,2));
            logicindexes(allindexes)=1;
            logicindexes = logical(logicindexes);
            for nLayers = 1:4
                for nHiddenNodes = 1:10
                    % Format training and testing data for target regions
                    training_targets = preprocdata{predicteeRois(iRoi)}{iRun}.train(logicindexes);
                    testing_targets = preprocdata{predicteeRois(iRoi)}{iRun}.train(~logicindexes);
                    % Format training and testing data for predictor regions
                    for jRoi = 1:nRoisInput
                        training_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.train(logicindexes);
                        testing_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.train(~logicindexes);
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
                        varexpl_lin(jRun,nHiddenNodes,nLayers,iIteration) = integration_linear_test(net_lin,testing_inputs_scaled',testing_targets_scaled);
                        % Train and test model with nonlinear integration of modalities
                        net_nonlin = integration_nonlinear_train(training_inputs_scaled',training_targets_scaled,nHiddenNodes,nLayers);
                        varexpl_nonlin(jRun,nHiddenNodes,nLayers,iIteration) = integration_nonlinear_test(net_nonlin,testing_inputs_scaled',testing_targets_scaled);
                    end
                    clear('training_targets','testing_targets','training_inputs','testing_inputs','numIputs',...
                        'inputsScalingFactor_temp','inputsScalingFactor','training_inputs_scaled','testing_inputs_scaled',...
                        'targetsScalingFactor','training_targets_scaled','testing_targets_scaled','net_lin','net_nonlin');
                end
            end
            clear('indexes','allindexes','logicindexes');
        end
        meanVarexpl_lin = reshape(mean(varexpl_lin,1),nHiddenNodes,nLayers);
        meanVarexpl_nonlin = reshape(mean(varexpl_nonlin,1),nHiddenNodes,nLayers);
        [I,J] = find(meanVarexpl_lin==max(max(meanVarexpl_lin)));
        optimalNodes_lin = I(1);
        optimalLayers_lin = J(1);
        clear('I','J');
        [I,J] = find(meanVarexpl_nonlin==max(max(meanVarexpl_nonlin)));
        optimalNodes_nonlin = I(1);
        optimalLayers_nonlin = J(1);
        clear('I','J');
        % Format training and testing data for target regions
        training_external_targets = preprocdata{predicteeRois(iRoi)}{iRun}.train;
        testing_external_targets = preprocdata{predicteeRois(iRoi)}{iRun}.test;
        % Format training and testing data for predictor regions
        for jRoi = 1:nRoisInput
            training_external_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.train;
            testing_external_inputs{jRoi} = preprocdata{predictorRois(jRoi)}{iRun}.test;
        end
        
        % Scale inputs
        for iInput = 1:numInputs
            inputsScalingFactor_temp(iInput) = max(max(abs(training_external_inputs{iInput})));
        end
        inputsScalingFactor = max(inputsScalingFactor_temp);
        for iInput = 1:numInputs
            training_external_inputs_scaled{iInput} = training_external_inputs{iInput}/inputsScalingFactor;
            testing_external_inputs_scaled{iInput} = testing_external_inputs{iInput}/inputsScalingFactor;
        end
        % Scale targets
        targetsScalingFactor = max(max(abs(training_external_targets)));
        training_external_targets_scaled = training_external_targets/targetsScalingFactor;
        testing_external_targets_scaled = testing_external_targets/targetsScalingFactor;
        
        for iIteration = 1:nIterations
            % Train and test model with linear integration of modalities
            net_lin = integration_linear_train(training_external_inputs_scaled',training_external_targets_scaled,optimalNodes_lin,optimalLayers_lin);
            varexpl_lin_final(iRoi,iRun,iIteration) = integration_linear_test(net_lin,testing_external_inputs_scaled',testing_external_targets_scaled);
            net_lin_storage{iRoi,iRun,iIteration} = net_lin;
            % Train and test model with nonlinear integration of modalities
            net_nonlin = integration_nonlinear_train(training_external_inputs_scaled',training_external_targets_scaled,optimalNodes_nonlin,optimalLayers_nonlin);
            varexpl_nonlin_final(iRoi,iRun,iIteration) = integration_nonlinear_test(net_nonlin,testing_external_inputs_scaled',testing_external_targets_scaled);
            net_nonlin_storage{iRoi,iRun,iIteration} = net_nonlin;
        end
        
        clear('meanVarexpl_lin','meanVarexpl_nonlin','optimalNodes_lin','optimalLayers_lin','optimalNodes_nonlin','optimalLayers_nonlin','training_external_targets',...
            'testing_external_targets','training_external_inputs','testing_external_inputs','inputsScalingFactor', 'traning_external_inputs_scaled','testing_external_inputs_scaled',...
            'targetsScalinFactor','training_external_Targets_scaled', 'testing_external_targets_scaled');
        
    end
end

save(savePath, 'net_lin_storage','varexpl_lin_final','net_nonlin_storage','varexpl_nonlin_final','-v7.3');
