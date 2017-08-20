function exit_script = MVPDsearchlight_setenv(Cfg_MVPDsearchlight)

% This function creates the folders where the results will be saved and
% checks that all the file paths exist.

%% Check inputs
exit_script = 0;
fprintf('\nChecking input paths...');
subjectFields = fieldnames(Cfg_MVPDsearchlight.dataInfo.subjects);
for iField =1:length(subjectFields)
   if ~isempty(strfind(subjectFields{iField},'Path'))
       temp = Cfg_MVPDsearchlight.dataInfo.subjects.(subjectFields{iField});
       allPaths = extractmycells(temp);
       for iFile = 1:length(allPaths)
           if exist(allPaths{iFile},'file')~=2
               fprintf('\n%s could not be found or is not a file.\n',allPaths{iFile});
               exit_script = 1;
           end
       end
       clear('temp','allPaths');
   end
end
fprintf(' Done.\n');


%% Make output folders if needed
fprintf('\nMaking output paths...');
if exist(Cfg_MVPDsearchlight.outputPaths.results,'dir')~=7
    fprintf('\nMaking region models folder at %s\n', Cfg_MVPDsearchlight.outputPaths.results);
    try
        mkdir(Cfg_MVPDsearchlight.outputPaths.results);
    catch
        fprintf('\nCould not create region models folder. Check permissions.\n');
        exit_script = 1;
    end
end
if exist(Cfg_MVPDsearchlight.outputPaths.products,'dir')~=7
    fprintf('\nMaking products folder at %s\n', Cfg_MVPDsearchlight.outputPaths.products);
    try
        mkdir(Cfg_MVPDsearchlight.outputPaths.products);
    catch
        fprintf('\nCould not create products folder. Check permissions.\n');
        exit_script = 1;
    end
end
fprintf(' Done.\n');

%% Save Cfg file
fprintf('\nSaving Cfg file...');
try
save(Cfg_MVPDsearchlight.outputPaths.cfgPath,sprintf('Cfg_MVPDsearchlight_%d',Cfg_MVPDsearchlight.dataInfo.subjects(1).ID),'-v7.3');
    fprintf(' Done.\n');
catch
    fprintf('Could not save Cfg file. Check permissions.');
    exit_script = 1;
end

%% Finish
if ~exit_script
    fprintf('\nFile check completed successfully.\n');
else
    warning('File check encoutered errors. Not saving Cfg.')
end
