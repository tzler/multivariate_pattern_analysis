function mvpc_searchlight_computations(subject,inputs,outputPath)

%% ######## Initialize ########
regionModels = inputs.regionModels;
interactionModels = inputs.interactionModels;

%% ######## Load functional volumes ########
[volumes_control,sizeVolumeSpace] = mvpc_load_compcorr(subject,inputs.compcorr);

%% ######## Extract seed data ########
seed = logical(spm_read_vols(spm_vol(subject.seedPath)));
sizeSpace = size(seed,1)*size(seed,2)*size(seed,3);
seed2 = reshape(seed,sizeSpace,1);

%% ######## Apply region models to seed ########
nRuns = length(volumes_control);
nRegionModels = length(regionModels);
for iRun = 1:nRuns
    data_seed{iRun} = volumes_control{iRun}(seed2,:);
end
for iRegionModel = 1:nRegionModels
		     regionModels_seed(iRegionModel) = regionModels(iRegionModel).seed;
end
for iRegionModel = 1:nRegionModels
		     regionModels_spheres(iRegionModel) = regionModels(iRegionModel).spheres;
end
preprocessedData_seed = mvpc_applyRegionModels(data_seed,regionModels_seed);
clear('data_seed');
fprintf('\nRegion models for seed region completed.\n');

%% ######## Run searchlight ########
tic

nSpheres = length(inputs.coordsSpheres);
warning('off','all')
for iSphere = 1:nSpheres  % FOR DEBUGGING
    %% Extract sphere data
    thisSphere = inputs.coordsSpheres{iSphere};
    for iRun = 1:nRuns
        data_sphere{iRun} = volumes_control{iRun}(thisSphere,:);
    end
    
    %% Apply region models to sphere
    if any(~cell2mat(cellfun(@size,data_sphere,'UniformOutput',false)))
        for iRegionModel = 1:nRegionModels
            results{iRegionModel} = zeros(1);
        end
    else
        preprocessedData_sphere = mvpc_applyRegionModels(data_sphere,regionModels_spheres);
        %% Calculate mutual predictivity -- try using mldivide to see if it matters to consider covariance
        for iRegionModel = 1:nRegionModels
            preprocessedData{iRegionModel}{1} = preprocessedData_seed{iRegionModel};
            preprocessedData{iRegionModel}{2} = preprocessedData_sphere{iRegionModel};
        end
        results = mvpc_applyInteractionModels(preprocessedData,interactionModels);
    end
    %     [varexpl_temp, meanVarexpl_byComp_temp, varexpl_byComp_temp] = mrtools_iconnIndep_mutualPred_byComponent(seedData_reduced,sphereData_reduced);
    nInteractionModels = length(results);
    for iInteractionModel = 1:nInteractionModels
        nStatistics = length(results{iInteractionModel});
        for iStatistic = 1:nStatistics
            try
                r{iInteractionModel}{iStatistic}(iSphere) = results{iInteractionModel}(iStatistic);
            catch
                r{iInteractionModel}{iStatistic}(iSphere) =  0;
            end
        end
    end
    if ~mod(iSphere,1000)
        fprintf('%d ',iSphere);
    end
end
toc
warning('on','all')
%% Reformat and save searchlight map
linearIndexes = sub2ind(size(seed),inputs.I,inputs.J,inputs.K);
% linearIndexes = linearIndexes(1:100); % FOR DEBUGGING
for iInteractionModel = 1:nInteractionModels
    nStatistics = length(r{iInteractionModel});
    for iStatistic = 1:nStatistics
    searchlightMap3D_r = zeros(size(seed));
    searchlightMap3D_r(linearIndexes) = r{iInteractionModel}{iStatistic};
    vol_write = spm_vol(subject.functionalPaths{1}{1});
    fname = sprintf('analysis%d_stat%d_sub%02d.img',iInteractionModel,iStatistic,subject.ID);
    vol_write.fname = fname;
    dataType = spm_type('float32');
    vol_write.dt(1) = dataType;
    try
        mkdir(outputPath);
        cd(outputPath);
        spm_write_vol(vol_write,searchlightMap3D_r);
    catch
        warning('Could not save results to the specified path.');
    end
    end
end
