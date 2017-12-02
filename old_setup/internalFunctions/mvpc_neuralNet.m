function connectivityMatrix = mvpc_neuralNet(parameters,data)
subjectstart = tic;%%%%%%%%%%%%%%%%
nRois = length(data);
for iRoi = 1:nRois
	iroistart = tic;%%%%%%%%%%%%%%%%%%
	fprintf('\nNNet ROI %d x (',iRoi)
    for jRoi = 1:nRois
    	fprintf('%d ',jRoi)
    	jroistart = tic;%%%%%%%%%%%%%%
        [~, meanVarexpl_byComp{iRoi,jRoi},~] = mvpc_neuralNet_byComponent(parameters,data{jRoi},data{iRoi});
        connectivityMatrix(iRoi,jRoi) = mean(meanVarexpl_byComp{iRoi,jRoi});
        fprintf('\n')%%%%%%%%%%%%%%
        toc(jroistart)%%%%%%%%%%%%%%
    end
    fprintf(')\nNNet ROI %d of %d finished\n',iRoi,nRois)
    toc(iroistart)%%%%%%%%%%%%%%%%%%%%%%%%
end
toc(subjectstart)%%%%%%%%%%%%%%%%%
connectivityMatrix(connectivityMatrix<0)=0;

end
