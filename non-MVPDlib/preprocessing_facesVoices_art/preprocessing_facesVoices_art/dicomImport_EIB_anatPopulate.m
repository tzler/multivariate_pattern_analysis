subjectID = [10 16 17 18 21 22 23 25 26 27 38 39 40 41 42 28 29 31 32 33 34 36 57 63 64 66 67 68 69 70];
nSubjects = numel(subjectID);

for iSubject = 1:nSubjects
    file = fullfile(sprintf('/mindhive/saxelab3/moveSaxelab2/EIB/SAX_EIB_%02d/report',subjectID(iSubject)),'scan_info');
    fid = fopen(file);
    
    tline = fgetl(fid);
    while ischar(tline)
        if strfind(tline,'MPRAGE')
            integers = sscanf(tline,'%u');
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    EIBanat(iSubject).ID = subjectID(iSubject);
    EIBanat(iSubject).run = integers(1);
end

cd('/mindhive/gablab/u/daeda/analyses/EIB_data/');
save('EIBanat','EIBanat');