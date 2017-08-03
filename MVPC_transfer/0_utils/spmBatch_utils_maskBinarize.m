function spmBatch_utils_maskBinarize( Cfg_maskBinerize, type, cat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% get files
cd(Cfg_maskBinerize.path);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_maskBinerize.filter)))=[];

% binarize file
for iFile = 1:length(filenames)
    header = spm_vol(filenames(iFile).name);
    vol = spm_read_vols(header);

    if iFile == 1;
        tempvol = zeros(size(vol));
        allvol = repmat(tempvol,[1,1,1,4]);
    end

    allvol(:,:,:,iFile) = vol;
    
    % binarize individual volumes if specified
    if strcmpi(cat, 'individual') || strcmpi(cat, 'all')
        
        if strcmpi(type,'liberal')
            vol(vol>0) = 1;
        elseif strcmpi(type,'conservative')
            vol(vol>Cfg_maskBinerize.threshold) = 1;
            vol(vol<Cfg_maskBinerize.threshold) = 0;
        else
            error('type not recognized');
        end
        
        %set new filename
        [pathstr,name,ext] = fileparts(header.fname);
        header.fname = strcat(pathstr,Cfg_maskBinerize.newPrefix,name,ext);
        
        %write nifti
        spm_write_vol(header,vol);
    end
    
end

% binarize concatonated volumes if specified
if strcmpi(cat, 'concatenate') || strcmpi(cat, 'all')

    catvol = sum(allvol,4);

    if strcmpi(type,'liberal')
        catvol(catvol>0) = 1;
    elseif strcmpi(type,'conservative')
        catvol(catvol>Cfg_maskBinerize.threshold) = 1;
        catvol(catvol<Cfg_maskBinerize.threshold) = 0;
    else
        error('type not recognized');
    end
    
    %set new filename
    [pathstr,~,ext] = fileparts(header.fname);
    header.fname = strcat(pathstr,Cfg_maskBinerize.catName,ext);
    
    %write nifti
    spm_write_vol(header,catvol);
end

end

