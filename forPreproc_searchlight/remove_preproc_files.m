%% Remove preprocessed files
projectFolderPath = 'C:\stefano\halfFaces';
functionalFolderNames = {'loc1','run1','run2','run3','run4'};
anatomicalFolderNames = {'anatomy1'};
for iSubject = 1:12
    % Remove functional preprocessed volumes
    for iFolder = 1:length(functionalFolderNames);
        cd(fullfile(projectFolderPath,sprintf('sub%02d',iSubject)));
        cd(functionalFolderNames{iFolder})
        filenames = dir;
        for iFile = 1:length(filenames)
            if (filenames(iFile).name(1) ~='f')&&(~isdir(filenames(iFile).name))
                delete(filenames(iFile).name);
            end
        end
        clear('filenames','filenames_new');
    end
    % Remove anatomical preprocessed volumes
    for iFolder = 1:length(anatomicalFolderNames);
        cd(fullfile(projectFolderPath,sprintf('sub%02d',iSubject)));
        cd(anatomicalFolderNames{iFolder})
        filenames = dir;
        for iFile = 1:length(filenames)
            if (filenames(iFile).name(1) ~='s')&&(~isdir(filenames(iFile).name));
                delete(filenames(iFile).name);
            end
        end
        clear('filenames','filenames_new');
    end
end
for iSubject = 14:14
    % Remove functional preprocessed volumes
    for iFolder = 1:length(functionalFolderNames);
        cd(fullfile(projectFolderPath,sprintf('sub%02d',iSubject)));
        cd(functionalFolderNames{iFolder})
        filenames = dir;
        for iFile = 1:length(filenames)
            if (filenames(iFile).name(1) ~='f')&&(~isdir(filenames(iFile).name))
                delete(filenames(iFile).name);
            end
        end
        clear('filenames','filenames_new');
    end
    % Remove anatomical preprocessed volumes
    for iFolder = 1:length(anatomicalFolderNames);
        cd(fullfile(projectFolderPath,sprintf('sub%02d',iSubject)));
        cd(anatomicalFolderNames{iFolder})
        filenames = dir;
        for iFile = 1:length(filenames)
            if (filenames(iFile).name(1) ~='s')&&(~isdir(filenames(iFile).name));
                delete(filenames(iFile).name);
            end
        end
        clear('filenames','filenames_new');
    end
end