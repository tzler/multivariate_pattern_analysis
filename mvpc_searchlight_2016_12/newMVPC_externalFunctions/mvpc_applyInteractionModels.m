function results = mvpc_applyInteractionModels(preprocessedData,interactionModels)

% ######## Estimate models of the interactions ######## 
nInteractionModels = length(interactionModels);
for iInteractionModel = 1:nInteractionModels
    results{iInteractionModel} = feval(interactionModels(iInteractionModel).functionHandle,interactionModels(iInteractionModel).parameters,preprocessedData{interactionModels(iInteractionModel).regionModel});
%     fprintf('\nInteraction model %d completed.\n',iInteractionModel);
end