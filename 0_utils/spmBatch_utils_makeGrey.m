% this script makes average gray for a set of subjects

for iSubject = 1:10
    cd(sprintf('C:\\stefano\\facesViewpoint\\2_data_preproc\\sub%02d\\anatomy1',iSubject));
    filename = dir('wc1s*.nii');
    img(:,:,:,iSubject) = smooth3(spm_read_vols(spm_vol(filename.name)),'gaussian',[3 3 3]);
    meanImg = mean(img,4);
end
header = spm_vol(filename.name);
header.fname = 'C:\stefano\facesViewpoint\2_data_preproc\meanGray.nii';
spm_write_vol(header,meanImg);
meanImg_discrete = meanImg > 0.5;
header_discrete = header;
header_discrete.fname = 'C:\stefano\facesViewpoint\2_data_preproc\meanGray_discrete.nii';
spm_write_vol(header_discrete,meanImg_discrete);

