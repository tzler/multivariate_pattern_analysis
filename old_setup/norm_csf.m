
addpath('/mindhive/saxelab/scripts/cleanup_2014/');
subjects = makeIDs('KMVPA',[1:9,11:19,21,22,24:29]);
study_dir = '/mindhive/saxelab2/KMVPA';

defaults = spm_defaults_alek;

for i = 3:length(subjects)
    cd(study_dir);
    cd(subjects{i})
    cd 3danat
    
    p = load(char(adir('s*seg_sn*mat')));
    t = defaults.normalise.write;
    t.prefix = 'n_';
    t.interp = 0;
    t.interp = 1;
    
    csf = adir(fullfile('c3s*.img'));
    prob_thresh = 0.8; 
    
    fprintf('Applying warps to segmentation (csf)\n');
    gmx = spm_write_sn(char(csf),p,t);
    fprintf('Binarizing csf into a mask...\n')
    gmX = spm_read_Vols(gmx);
    gmX = gmX >= prob_thresh; 
    delete(gmx.fname);
    gmx.fname = 'csf_mask.img';
    spm_write_vol(gmx,gmX);

    t.interp = 0;
    clear gmx gmX p t csf
    
end