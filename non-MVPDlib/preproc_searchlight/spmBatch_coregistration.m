function matlabbatch = spmBatch_coregistration(Cfg_coregistration)


% Select the files to be spatially realigned

cd(Cfg_coregistration.fileFolder);
fileFunctional{1} = dir(Cfg_coregistration.filesFilter);
filePathFunctional{1} = strcat(fullfile(Cfg_coregistration.fileFolder,fileFunctional{1}.name),',1');

% data paths
matlabbatch{1}.spm.spatial.coreg.estimate.ref = filePathFunctional; % path of functional image
matlabbatch{1}.spm.spatial.coreg.estimate.source = {strcat(Cfg_coregistration.anatomyFile,',1')}; % path of structural image

matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

% run
if Cfg_coregistration.runYN
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end