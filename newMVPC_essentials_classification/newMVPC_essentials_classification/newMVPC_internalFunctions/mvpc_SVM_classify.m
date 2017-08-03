function accuracy = mvpc_SVM_classify(trainingInputs, trainingTargets, testingInputs, testingTargets)

trainingInputs = trainingInputs';
testingInputs = testingInputs';
trainingTargets(end+1:size(trainingInputs,1)) = NaN;
testingTargets(end+1:size(testingInputs,1)) = NaN;

Mdl = fitcsvm(trainingInputs,trainingTargets(1:size(trainingInputs,1)));
label = predict(Mdl,testingInputs);
accuracy = sum(label==testingTargets(1:size(testingInputs,1)))/sum(~isnan(testingTargets(1:size(testingInputs,1))));