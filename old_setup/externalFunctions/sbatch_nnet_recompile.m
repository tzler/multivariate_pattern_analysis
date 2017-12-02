function sbatch_nnet_recompile( resultsPath, nnetIndex, nSubjects, nRois )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%	resultsPath = path to results folder of current run (e.g. 'results/mvpc_000000/')
%	nnetIndex = which feval index nnet was set to (e.g. 4)
%	nRois = number of ROI files to search for (e.g. 90)
%	Requires MATLAB 16b or higher

cd(resultsPath);

allSubResultsDir = dir('results_subject*.mat');

if ~isequal(length(allSubResultsDir),nSubjects)
    error('mismath in number of subjects\n')
end

% check that data is intact
for iSubject = 1:nSubjects
    resultsSubjectPath = fullfile(allSubResultsDir(iSubject).folder,allSubResultsDir(iSubject).name);
    load(resultsSubjectPath); % loads variable 'results' and 'subjectData'

    if ~isequal(results{nnetIndex},zeros(nRois))
        error('mismatch in connectivityMatrix to be replaced for subject %d',iSubject)
    end
    
    cd(fullfile(allSubResultsDir(1).folder,'temp_nnet',sprintf('Sub%0.3d',iSubject)));
    
    nnetRoi = dir('nnetcpnt_Sub*.mat');
    
    if ~isequal(length(nnetRoi),nRois)
        error('mismatch in number of NNET ROI for subject %d',iSubject)
    end

    for iRoi = 1:nRois
        if ~exist(sprintf('nnetcpnt_Sub%0.3d_Roi%0.3d.mat',iSubject,iRoi),'file') == 2
            error('ROI file not found for subject %d',iSubject)
        end
    end
    
    slurmErrorFile = dir('sbatch_*_stderr_*.txt');

    fid = fopen(slurmErrorFile(1).name);
    if ~fseek(fid, 1, 'bof') == -1 || ~isequal(length(slurmErrorFile),1)
        error('slurm error may have occured for subject %d',iSubject);
    end
    
    clearvars results subjectData nnetRoi slurmErrorFile fid
    
end

% construct connectivity matrix, save to subject variable
for iSubject = 1:nSubjects
    resultsSubjectPath = fullfile(allSubResultsDir(iSubject).folder,allSubResultsDir(iSubject).name);
    load(resultsSubjectPath); % loads variable 'results' and 'subjectData'
    results(nnetIndex) = [];
    
    cd(fullfile(allSubResultsDir(1).folder,'temp_nnet',sprintf('Sub%0.3d',iSubject)));
    
    nnetRoi = dir('nnetcpnt_Sub*.mat');
    
    % recompile connectivityMatrix from individual rows
    for iRoi = 1:nRois
        load(sprintf('nnetcpnt_Sub%0.3d_Roi%0.3d.mat',iSubject,iRoi)); % loads variables 'connectivityMatrix' as 1xnRois vector
        connectivityMatrixCat(iRoi,:) = connectivityMatrix;
    end
    
    results{nnetIndex} = connectivityMatrixCat; % replace placholder matrix with recompiled matrix
    
    save(resultsSubjectPath,'results'); % overwrite results variable
    
    % concatenate subject variables
    connectivityMatrices{iSubject} = results;
    
    clearvars results subjectData nnetRoi connectivityMatrixCat connectivityMatrix resultsSubjectPath
    
end

cd(resultsPath);
filename = 'mvpcRoi_connmat_results.mat';
save(filename,'connectivityMatrices');
fprintf('Connectivity Matrices saved as %s in %s.\n',filename,which(filename));

end