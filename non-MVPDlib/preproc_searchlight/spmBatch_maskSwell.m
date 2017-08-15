function spmBatch_maskSwell( Cfg_maskErode, voxels )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if voxels < 0
    increase = false;
    voxels = abs(voxels);
elseif voxels > 0
    increase = true;
else
    error('voxel size required');
end

% get files
cd(Cfg_maskErode.path);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_maskErode.filter)))=[];

% erode file
for iFile = 1:length(filenames)
    header = spm_vol(filenames(iFile).name);
    vol = spm_read_vols(header);
    
    mask = vol;
    
    temp = vol;
    tempvec = temp(1:voxels,:,:);
    temp(1:voxels,:,:) = [];
    temp = cat(1, temp, zeros(size(tempvec)));
    mask = mask + temp;
    
    temp = vol;
    tempvec = temp(end-voxels:end-1,:,:);
    temp(end-voxels:end-1,:,:) = [];
    temp = cat(1, zeros(size(tempvec)), temp);
    mask = mask + temp;
    
    
    temp = vol;
    tempvec = temp(:,1:voxels,:);
    temp(:,1:voxels,:) = [];
    temp = cat(2, temp, zeros(size(tempvec)));
    mask = mask + temp;
    
    temp = vol;
    tempvec = temp(:,end-voxels:end-1,:);
    temp(:,end-voxels:end-1,:) = [];
    temp = cat(2, zeros(size(tempvec)), temp);
    mask = mask + temp;
    
    
    temp = vol;
    tempvec = temp(:,:,1:voxels);
    temp(:,:,1:voxels) = [];
    temp = cat(3, temp, zeros(size(tempvec)));
    mask = mask + temp;
    
    temp = vol;
    tempvec = temp(:,:,end-voxels:end-1);
    temp(:,:,end-voxels:end-1) = [];
    temp = cat(3, zeros(size(tempvec)), temp);
    mask = mask + temp;
    
    if increase
        mask(mask>0) = 1;
    else
        mask(mask<7) = 0;
    end
    
    %set new filename
    [pathstr,name,ext] = fileparts(header.fname);
    header.fname = strcat(pathstr,Cfg_maskErode.newPrefix,name,ext);
    
    %write nifti
    spm_write_vol(header,mask);
    
end

end

