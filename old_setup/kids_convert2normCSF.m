clear all %% only works on nuna ... not openmind 
addpath('/mindhive/saxelab2/tyler/mvpc/kids/setup/');
addpath('/mindhive/saxelab2/tyler/mvpc/kids/setup/preproctoolsspm/')
addpath('/mindhive/saxelab2/tyler/mvpc/kids/software/spm12/')
addpath('/mindhive/saxelab/scripts/')
tmp = load('subjectPathInfo.mat'); 
subjects = genSubPaths(tmp.data); 
defaults = spm_defaults_alek;

iSubject = 1; 
%for iSubject = 1:length(subjects)
     Cfg_preproc.anatomyFolder = fullfile(subjects(iSubject).subjectDir,'3danat'); 
     cd(fullfile(Cfg_preproc.anatomyFolder));
     
%     %% from spmBatch_masterscript_connectivity.m
%     
%     % Generate missing tissue probablity  (c6, empty space)
%     Cfg_probabilityGenMask.filter = '(^c)(.*\.img)'; % must be RegEx filter
%     Cfg_probabilityGenMask.erodePrefix = 2;
%     Cfg_probabilityGenMask.newPrefix = 'c6';
%     Cfg_probabilityGenMask.path = Cfg_preproc.anatomyFolder;
% 
%     spmBatch_probabilityMaskGen(Cfg_probabilityGenMask);
% 
%     clear('Cfg_probabilityGenMask');
% 
%     p = load(char(adir('s*seg_sn*mat')));
%     t = defaults.normalise.write;
%     t.prefix = 'n_';
%     t.interp = 0;
%     t.interp = 1;
%     
%     emptySpace = adir(fullfile('c6s*.img'));
%     prob_thresh = 0.8; 
%     
%     fprintf('Applying warps to segmentation (csf)\n');
%     gmx = spm_write_sn(char(emptySpace),p,t);
%     fprintf('Binarizing csf into a mask...\n')
%     gmX = spm_read_Vols(gmx);
%     gmX = gmX >= prob_thresh; 
%     delete(gmx.fname);
%     gmx.fname = 'emptySpace.img';
%     spm_write_vol(gmx,gmX);
% 
%     t.interp = 0;
%     clear gmx gmX p t csf

    % Erode white matter, CSF, combined masks

    Cfg_maskSwell.filter = '(^binary_pwc2|^binary_pwc3|^white_matter_mask)(.*\.img)'; % must be RegEx filter
    Cfg_maskSwell.newPrefix = 'eroded_';
    Cfg_maskSwell.path = Cfg_preproc.anatomyFolder;

    spmBatch_maskSwell(Cfg_maskSwell,-1); % positive values swell mask, negative erode mask.

    clear('Cfg_maskSwell');
    
%end