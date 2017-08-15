function spmBatch_preproc_probabilityMaskGen( Cfg_probabilityGenMask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% get files
cd(Cfg_probabilityGenMask.path);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_probabilityGenMask.filter)))=[];

nFiles = length(filenames);
if nFiles ~= 5
    warning('Warning: Unexpected number of tissue segments\n')
end

for iFile = 1:nFiles
    header = spm_vol(filenames(iFile).name);
    vol(:,:,:,iFile) = spm_read_vols(header);
end

catvol = sum(vol,4);

diffvol = ones(size(catvol));
diffvol = diffvol - catvol;

%set new filename
[pathstr,name,ext] = fileparts(header.fname);
erodedName = name(Cfg_probabilityGenMask.erodePrefix+1:end); % remove c5 from start of file name
header.fname = strcat(pathstr,Cfg_probabilityGenMask.newPrefix,erodedName,ext);  % add c6 to start of file name

%write nifti
spm_write_vol(header,diffvol);

end
