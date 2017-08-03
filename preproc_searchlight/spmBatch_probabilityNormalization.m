function spmBatch_probabilityNormalization( Cfg_probabilityNormalization )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% get files
cd(Cfg_probabilityNormalization.path);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_probabilityNormalization.filter)))=[];

nFiles = length(filenames);
if nFiles ~= 6
    warning('Warning: Fewer segments than expected\n')
end

for iFile = 1:nFiles
    header{iFile} = spm_vol(filenames(iFile).name);
    vol(:,:,:,iFile) = spm_read_vols(header{iFile});
end

catvol = sum(vol,4);

for iFile = 1:nFiles
    normheader = header{iFile};
    normvol = vol(:,:,:,iFile);
    
    normvol = normvol./catvol;
    
    %set new filename
    [pathstr,name,ext] = fileparts(normheader.fname);
    normheader.fname = strcat(pathstr,Cfg_probabilityNormalization.newPrefix,name,ext);
    
    %write nifti
    spm_write_vol(normheader,normvol);
    
end


end