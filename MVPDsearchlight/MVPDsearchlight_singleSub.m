function mvpc_searchlight_singleSub(subject,searchlightInfo,preprocModels,regionModels,interactionModels,outputPath)

tic

%% ######## Load search space ########
searchSpace = spm_read_vols(spm_vol(subject.searchSpacePath));

%% ######## Make searchlight spheres ########
radius = searchlightInfo.sphereRadius;
voxelSize = searchlightInfo.voxelSize;
% define coordinates of voxels in a box centered in zero
IBox = floor(-radius/voxelSize(1)):ceil(+radius/voxelSize(1));
JBox = floor(-radius/voxelSize(2)):ceil(+radius/voxelSize(2));
KBox = floor(-radius/voxelSize(3)):ceil(+radius/voxelSize(3));
BOX = combvec(IBox,JBox,KBox)';
% define coordinates of voxels in a sphere centered in zero
radius2=radius^2;
coordsGeneralAffine = BOX((BOX(:,1)*voxelSize(1)).^2+(BOX(:,2)*voxelSize(2)).^2+(BOX(:,3)*voxelSize(3)).^2<=radius2,:);
% find indexes
[I,J,K] = ind2sub(size(searchSpace),find(searchSpace));
coordsSpheres = cell(length(I),1);
for iSphere = 1:length(I)
    if min([I(iSphere)*voxelSize(1) J(iSphere)*voxelSize(2) K(iSphere)*voxelSize(3) (size(searchSpace,1)-I(iSphere))*voxelSize(1) (size(searchSpace,2)-J(iSphere))*voxelSize(2) (size(searchSpace,3)-K(iSphere))*voxelSize(3)]) < radius+min([voxelSize(1),voxelSize(2),voxelSize(3)])
        IBox = max(I(iSphere)-ceil(radius/voxelSize(1)),1):min(I(iSphere)+ceil(radius/voxelSize(1)),size(searchSpace,1));
        JBox = max(J(iSphere)-ceil(radius/voxelSize(2)),1):min(J(iSphere)+ceil(radius/voxelSize(2)),size(searchSpace,2));
        KBox = max(K(iSphere)-ceil(radius/voxelSize(3)),1):min(K(iSphere)+ceil(radius/voxelSize(3)),size(searchSpace,3));
        BOX = combvec(IBox,JBox,KBox)';
        coordsSpheres = BOX(((BOX(:,1)-I(iSphere))*voxelSize(1).^2+(BOX(:,2)-J(iSphere))*voxelSize(2).^2+(BOX(:,3)-K(iSphere))*voxelSize(3).^2)<=radius2,:);
        coordsSpheresInd{iSphere} = sub2ind(size(searchSpace),coordsSpheres(:,1),coordsSpheres(:,2),coordsSpheres(:,3));
    else
        coordsSpheres = coordsGeneralAffine + repmat([I(iSphere) J(iSphere) K(iSphere)],size(coordsGeneralAffine,1),1);
        coordsSpheresInd{iSphere} = sub2ind(size(searchSpace),coordsSpheres(:,1),coordsSpheres(:,2),coordsSpheres(:,3));
    end
end
clear('coordsSpheres');
inputs.compcorr = searchlightInfo.compcorr;
inputs.coordsSpheres = coordsSpheresInd;
inputs.searchSpace = searchSpace;
inputs.I = I;
inputs.J = J;
inputs.K = K;
inputs.preprocModels = preprocModels;
inputs.regionModels = regionModels;
inputs.interactionModels = interactionModels;
clear('coordsSpheresInd','searchSpace');

%% Run searchlight
MVPDsearchlight_computations(subject,inputs,outputPath);

%% Communicate conclusion
time = toc;
fprintf('\n Searchlight completed in %d seconds.',time);
fprintf('\n Results map saved to %s\n',outputPath);


