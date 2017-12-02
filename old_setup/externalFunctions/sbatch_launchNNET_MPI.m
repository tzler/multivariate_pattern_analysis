function [ output_args ] = sbatch_launchNNET_MPI( resultsDir, nSubjects, nROI )
%UNTITLED2 Summary of this function goes here
%   To be run with screen. Launches NNET jobs in serial.
%   e.g.: screen ;;; matlab -nodesktop -nosplash -singleCompThread -nodisplay -nojvm ;;; sbatch_launchNNET_MPI('/mindhive/gablab/users/daeda/analyses/EIB/results/mvpc_736507',30,90)

%%DEBUG START
% warning('DEBUG')
% resultsDir = '/mountpoints/mh/mindhive/gablab/users/daeda/analyses/EIB/results_old/mvpc_736500';
% nSubjects = 2;
% nROI = 90;
%%DEBUG END

pause(60);

nnetDir = (fullfile(resultsDir,'temp_nnet'));
cd(nnetDir);
subDirs = dir('Sub*');
if ~isequal(length(subDirs),nSubjects)
    error('mismatch between subject nnet directory number and expected number of subjects\n');
end

subjectsToRun.subjectNumber = 1:nSubjects;
subjectsToRun.submitted = zeros(nSubjects,1);
subjectsToRun.active = zeros(nSubjects,1);
subjectsToRun.complete = zeros(nSubjects,1);

subjectsToRun.dir = subDirs;


while ~all(subjectsToRun.complete)
    remainingSubjects = find(subjectsToRun.complete == 0);
    for iSubject = 1:length(remainingSubjects)
        
        cd(fullfile(nnetDir,subjectsToRun.dir(remainingSubjects(iSubject)).name));

        if length(dir(sprintf('nnetcpnt_Sub%0.3d_Roi*.mat',remainingSubjects(iSubject)))) == nROI
            if isequal(subjectsToRun.complete(remainingSubjects(iSubject)),0)
                subjectsToRun.complete(remainingSubjects(iSubject)) = 1;
                subjectsToRun.submitted(remainingSubjects(iSubject)) = 1;
                fprintf('\nSubject %d complete\n',remainingSubjects(iSubject))
            end
        else
            if isequal(subjectsToRun.complete(remainingSubjects(iSubject)),1)
                subjectsToRun.complete(remainingSubjects(iSubject)) = 0;
                subjectsToRun.submitted(remainingSubjects(iSubject)) = 0;
                fprintf('\nRESETTING Subject %d to incomplete\n',remainingSubjects(iSubject))
            end
        end

        if ~isempty(dir('sbatch_MVPC_NNET_std*.txt'))
            if isequal(subjectsToRun.active(remainingSubjects(iSubject)),0) && isequal(subjectsToRun.complete(remainingSubjects(iSubject)),0)
                subjectsToRun.active(remainingSubjects(iSubject)) = 1;
                subjectsToRun.submitted(remainingSubjects(iSubject)) = 1;
                fprintf('\nSubject %d running\n',remainingSubjects(iSubject))
            end
        else
            if isequal(subjectsToRun.active(remainingSubjects(iSubject)),1)
                subjectsToRun.active(remainingSubjects(iSubject)) = 0;
                subjectsToRun.submitted(remainingSubjects(iSubject)) = 0;
                fprintf('\nRESETTING Subject %d to inactive\n',remainingSubjects(iSubject))
            end
        end

    end

    if sum(subjectsToRun.submitted) <= sum(subjectsToRun.active)
        nextSubject = find(subjectsToRun.submitted == 0,1);
        cd(fullfile(nnetDir,subjectsToRun.dir(nextSubject).name));
        cd('batchscripts');
        system('sbatch sbatch_nnet_parallel.sh');
        subjectsToRun.submitted(nextSubject) = 1;
        fprintf('\nSubject %d submitted\n',nextSubject)
    else
        pause(60*20); % 20 minutes in seconds
        fprintf('.');
    end

	cd(nnetDir);
	save('nnetSlumLog.mat','subjectsToRun');
    pause(120);
end

fprintf('\nALL SUBJECTS COMPLETE. EXITING SCRIPT.\n\n')

end

