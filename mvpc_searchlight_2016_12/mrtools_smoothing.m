function matlabbatch = mrtools_smoothing(Cfg_smoothing)

% Cfg_smoothing.filesFolders = {'F:\learningFaceIdentity\analysis_longtraining\sub01\loc1'}; % ;'F:\learningFaceIdentity\analysis_longtraining\sub01\run1';'F:\learningFaceIdentity\analysis_longtraining\sub01\run2';'F:\learningFaceIdentity\analysis_longtraining\sub01\run3'
% Cfg_smoothing.filesFilter = 'warf*.img';
% 
% Cfg_smoothing.smoothingKernel = [6 6 6];
% 
% Cfg_smoothing.runYN = 1;

for i = 1:size(Cfg_smoothing.filesFolders,1)    
        cd(Cfg_smoothing.filesFolders{i});
        files{i} = dir(Cfg_smoothing.filesFilter);
        for j = 1:length(files{i})
            filePaths{j} = strcat(Cfg_smoothing.filesFolders{i},'/',files{i}(j,1).name,',1');
        end
        smoothingData = filePaths'; 
        % data path
        matlabbatch{i}.spm.spatial.smooth.data = cellstr(smoothingData);
        % info and options
        matlabbatch{i}.spm.spatial.smooth.fwhm = Cfg_smoothing.smoothingKernel;      %<----------------------------------------------THIS PART DEPENDS ON YOUR TASTE
        matlabbatch{i}.spm.spatial.smooth.dtype = 0;
        matlabbatch{i}.spm.spatial.smooth.prefix = sprintf('sm_%d_%d_%d_',Cfg_smoothing.smoothingKernel(1),Cfg_smoothing.smoothingKernel(2),Cfg_smoothing.smoothingKernel(3));           
        clear('filePaths');
end

% run
if Cfg_smoothing.runYN
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end