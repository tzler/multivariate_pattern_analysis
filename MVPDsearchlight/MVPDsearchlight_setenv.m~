function exit_script = MVPDroi_setenv(Cfg_MVPDroi)

% This function creates the folders where the results will be saved and
% checks that all the file paths exist.

%% Check inputs
exit_script = 0;
fprintf('\nChecking input paths...');
subjectFields = fieldnames(Cfg_MVPDroi.dataInfo.subjects);
for iField =1:length(subjectFields)
   if ~isempty(strfind(subjectFields{iField},'Path'))
       temp = Cfg_MVPDroi.dataInfo.subjects.(subjectFields{iField});
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
if exist(Cfg_MVPDroi.outputPaths.regionModels,'dir')~=7
    fprintf('\nMaking region models folder at %s\n', Cfg_MVPDroi.outputPaths.regionModels);
    try
        mkdir(Cfg_MVPDroi.outputPaths.regionModels);
    catch
        fprintf('\nCould not create region models folder. Check permissions.\n');
        exit_script = 1;
    end
end
if exist(Cfg_MVPDroi.outputPaths.interactionModels,'dir')~=7
    fprintf('\nMaking interaction models folder at %s\n', Cfg_MVPDroi.outputPaths.interactionModels);
    try
        mkdir(Cfg_MVPDroi.outputPaths.interactionModels);
    catch
        fprintf('\nCould not create interaction models folder. Check permissions.\n');
        exit_script = 1;
    end
end
if exist(Cfg_MVPDroi.outputPaths.products,'dir')~=7
    fprintf('\nMaking products folder at %s\n', Cfg_MVPDroi.outputPaths.products);
    try
        mkdir(Cfg_MVPDroi.outputPaths.products);
    catch
        fprintf('\nCould not create products folder. Check permissions.\n');
        exit_script = 1;
    end
end
fprintf(' Done.\n');

%% Save Cfg file
fprintf('\nSaving Cfg file...');
try
    save(Cfg_MVPDroi.outputPaths.cfgPath,'Cfg_MVPDroi','-v7.3');
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