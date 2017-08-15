
subjects = [1,3:5,8,12:17];
nRuns = 5;
saveFolder = '/media/stefano/HIPPOCAMPUS/experiments_italy_2016/facesVoices/modality_labels';

nSubjects = length(subjects);
for iSubject = 1:nSubjects
    for iRun = 1:nRuns
        load(fullfile('/media/stefano/HIPPOCAMPUS/experiments_italy_2016/facesVoices/2_raw_data/mat',sprintf('S%dR%d',subjects(iSubject),iRun)));
        % find visual trials (class==1) and auditory trials (class==2)
        for iTrial = 1:length(ExpInfo.TrialInfo)
            if (ExpInfo.TrialInfo(iTrial).trial.code>0)&& (ExpInfo.TrialInfo(iTrial).trial.code<7)
                class((ExpInfo.TrialInfo(iTrial).trial.tOnset-8)/2+1) = 1;
            elseif (ExpInfo.TrialInfo(iTrial).trial.code>6)&& (ExpInfo.TrialInfo(iTrial).trial.code<13)
                class((ExpInfo.TrialInfo(iTrial).trial.tOnset-8)/2+1) = 2;
            end
        end
        % add 6 seconds to account for haemodynamic delay
        class = [ones(1,3)*NaN,class];
        class(class==0) = NaN;
        class_storage{iRun} = class';
        clear('ExpInfo','class');
    end
    for iRun = 1:nRuns
        labels(iRun).test = class_storage{iRun};
        runs = [1:nRuns];
        runs(iRun) = [];
        labels(iRun).train = [];
        for jRun = 1:length(runs)
            labels(iRun).train = [labels(iRun).train; class_storage{runs(jRun)}];
        end
        clear('runs');
    end
    filename = sprintf('sub%02d',subjects(iSubject));
    cd(saveFolder);
    save(filename,'labels');
    clear('class_storage','labels','filename');
end