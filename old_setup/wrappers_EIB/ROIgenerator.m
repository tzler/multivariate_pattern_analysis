addpath('/mindhive/gablab/users/daeda/software/spm12');
addpath(genpath('/home/daeda/software/mindhivemirror/wfu_pickatlas/'));

% Generate ROIs for the brodmann atlas
outputPath = ('/mindhive/gablab/users/daeda/analyses/EIB/ROIs');
cd('/home/daeda/software/mindhivemirror/wfu_pickatlas/MNI_atlas_templates');
vol_info = spm_vol('aal_MNI_V4.img');
A = spm_read_vols(vol_info);
names = load('aal_MNI_V4_List.mat');
cd(outputPath);
for iRoi = 1:length(names.ROI)
    B = zeros(size(A));
    B(A==names.ROI(iRoi).ID) = 1;
    vol_info_new = vol_info;
    if  iRoi<10
        string = sprintf('00%d',names.ROI(iRoi).ID);
    elseif (iRoi>9)&&(iRoi<100)
        string = sprintf('0%d',names.ROI(iRoi).ID);
    else
       string = sprintf('%d',names.ROI(iRoi).ID); 
    end
    vol_info_new.fname = sprintf('%s.img',string);
    spm_write_vol(vol_info_new,B);
end

% Adjust the ROIs to fit the size and orientation of the functional volumes
rmpath(genpath('/home/daeda/software/mindhivemirror/wfu_pickatlas/'));
addpath(genpath('/mindhive/gablab/users/daeda/software/marsbar-0-2.44'));
rmpath(genpath('/mindhive/gablab/users/daeda/software/marsbar-0-2.44/spm99/'));
vol_info_image = spm_vol('/mindhive/gablab/users/daeda/analyses/EIB/EIB_data/SAX_EIB_10/bold/011/swafSAX_EIB_10-0011-00005-000005-01.nii'); % CHANGE THIS LINE FOR THE NEW DATASET
roi_space.mat = vol_info_image.mat;
roi_space.dim = vol_info_image.dim;
cd(outputPath);
for iRoi = 1:116
    if  iRoi<10
        string = sprintf('00%d',names.ROI(iRoi).ID);
    elseif (iRoi>9)&&(iRoi<100)
        string = sprintf('0%d',names.ROI(iRoi).ID);
    else
       string = sprintf('%d',names.ROI(iRoi).ID); 
    end
    roiName = sprintf('%s.img',string);
    mars_img2rois(roiName, outputPath,num2str(iRoi),'i');
    filename_in = sprintf('%d_%d_roi.mat',iRoi,1);
    filename_out = sprintf('%s_EIB.img',string);
    mars_rois2img(filename_in,filename_out,roi_space,'i');
end