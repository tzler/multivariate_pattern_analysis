function results = MVPDsearchlight_applyInteractionModels(preprocessedData,interactionModels)

% ######## Estimate models of the interactions ######## 
nInteractionModels = length(interactionModels);
for iInteractionModel = 1:nInteractionModels
    results{iInteractionModel} = feval(interactionModels(iInteractionModel).functionHandle,interactionModels(iInteractionModel).parameters,preprocessedData{interactionModels(iInteractionModel).regionModel}{1},preprocessedData{interactionModels(iInteractionModel).regionModel}{2});
%     fprintf('\nInteraction model %d completed.\n',iInteractionModel);
end