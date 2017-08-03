% Script generator

% for iScript = 1:nScripts
%     fid = fopen(sprintf('script%03d.mat',iScript),'w');
%     fprintf(fid,'function script%03d\n',iScript);
%     fprintf('cd(''/mindhive/saxelab3/anzellotti/LANG_ISC/preprocessing_ISC'')\n');
%     fprintf('wrapper_preproc_LANG_ISC_parallel(%d);',iScript); 
% end

nScripts = 11;

for iScript = 1:nScripts
    fid = fopen(sprintf('script%03d.m',iScript),'w');
    fprintf(fid,'function script%03d\n',iScript);
    fprintf(fid,'cd(''/mindhive/saxelab3/anzellotti/facesVoices_art2/preprocessing_facesVoices_art'')\n');
    fprintf(fid,'wrapper_preproc_facesVoices_parallel_artOnly(%d);',iScript); 
    fclose(fid);
end
