Cfg_preproc.dataDir = '/mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/integration_functions_good/integration_functions_good';
subjects = [1,3,4,5,8,12:17];
for iSubject = 1:length(subjects)
	fid = fopen(sprintf('sbatch_run%03d.m',iSubject),'wt');
    fprintf(fid,'cd /mindhive/saxelab3/anzellotti/facesVoices_art2/newMVPC_essentials/integration_functions_good/integration_functions_good_multilayer\n');
    fprintf(fid,'mvpc_multiRegionIntegration_nestedXval(%d);\n',iSubject);
    fclose(fid);
end

