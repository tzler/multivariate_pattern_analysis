Cfg_preproc.dataDir = '/mindhive/gablab/u/daeda/analyses/EIB/EIB_data';
foldernames = dir(fullfile(Cfg_preproc.dataDir,'SAX_EIB_*'));

for iSubject = 1:length(foldernames)
	fid = fopen(sprintf('sbatch_run%03d.m',iSubject),'wt');
    fprintf(fid,'cd /mindhive/gablab/u/daeda/analyses/EIB/preproctoolsspm\n');
    fprintf(fid,'wrapper_preproc_EIB_parallel(%d);\n',iSubject);
    fclose(fid);
end

