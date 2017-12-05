function subjectInfo = generateFullDataPaths_example_roi
% Necessary fields: .ID, .functionalPaths, .roiPaths
% Optional fields: .outliersPaths, .motionRegressorsPaths, .compcorrMaskPaths, .globalSignalMasks

functionalFilter = 'swrf*.img'; 
tmp = load('subjectPathInfo.mat'); 
data = tmp.data; 

roiFilter = '*_top100voxels_mvpc_art+motion_*art+motion*xyz.img'; 

subjectCount = 0;
 
for iExp = 1:length(data)
 
    iData = data(iExp); 
    badSubjects = find(iData.modelData); 
    
    for iSubject = 1:length(iData.subjects)
	
 	fprintf('generating path info for %s ... ',iData.subjects{iSubject})	
	
	if ~sum(iSubject==badSubjects)

	    usable = 0;  
	    subjectCount = subjectCount + 1; 
	    subjectInfo(subjectCount).ID = iData.subjects{iSubject}; 
	    subjectPath = fullfile(iData.root,iData.cfg(iSubject).info.study, subjectInfo(subjectCount).ID); 

	    for iRun = 1:length(iData.bold{iSubject})
		
		if iData.goodRuns(iSubject,iRun)
		    
		    usable = usable + 1; 
		    dataFolderName{iSubject,usable} = sprintf('%03d',iData.bold{iSubject}(iRun)); 
		    functionalDirs{iSubject}{usable} = fullfile(subjectPath, 'bold', dataFolderName{iSubject,usable}); 
		    cd(functionalDirs{iSubject}{usable}); 
		    fileNames = dir(functionalFilter); 
		    nVolumes = numel(fileNames); 

		    for iVolume = 1:nVolumes 	
			subjectInfo(subjectCount).functionalPaths{usable}{iVolume,1} = fullfile(functionalDirs{iSubject}{usable}, fileNames(iVolume).name); 
		    end

	    	end	
  	    end 	    
        end

        % ROIS
        roiDir = fullfile(subjectPath,'autoROI');
        cd(roiDir);
        filenames = dir(roiFilter);
        nRois = length(filenames);
        
	for iRoi = 1:nRois
            subjectInfo(iSubject).roiPaths{iRoi} = fullfile(roiDir,filenames(iRoi).name);
        end  
	
	fprintf('found %d good runs ...  and %d ROIs\n', usable, nRois)

    end	
end 
cd('/mindhive/saxelab2/tyler/mvpd/MVPDroi')
save('pregenerated_subject_path_info', 'subjectInfo') 


%% Fill in necessary fields
%subjects = [1 3 4 5 8 12 13 14 15 16 17];
%nRuns= 5;
%functionalFilter = 'swaf*.img';
%roiFilter = '*.img';
%for iSubject = 1:length(subjects)
%    subjectInfo(iSubject).ID = sprintf('%02d',subjects(iSubject));
%    subjectPath = sprintf('/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d',subjects(iSubject));
%    for iRun = 1:nRuns
%        dataFolderName{iSubject,iRun} = sprintf('run%d',iRun);
%        functionalDirs{iSubject}{iRun} = fullfile(subjectPath,dataFolderName{iSubject,iRun});
%        cd(functionalDirs{iSubject}{iRun});
%        filenames = dir(functionalFilter);
%        nVolumes = numel(filenames);
%        for iVolume = 1:nVolumes
%            subjectInfo(iSubject).functionalPaths{iRun}{iVolume,1} = fullfile(functionalDirs{iSubject}{iRun},filenames(iVolume).name);
%        end
%        clear('filenames','nVolumes');
%        
%    end
%    % generate paths to the regions of interest
%    roiDir = fullfile(subjectPath,'ROIs');
%    cd(roiDir);
%    filenames = dir(roiFilter);
%    nRois = length(filenames);
%    for iRoi = 1:nRois
%        subjectInfo(iSubject).roiPaths{iRoi} = fullfile(roiDir,filenames(iRoi).name);
%    end    
%end

%% s Fill in optional fields
%motionRegressorsFilter = 'rp*.txt';
%outliersFilter = 'outl*.txt';
%compcorrFilter = 'mask_combWMCSF_*.nii';
%for iSubject = 1:length(subjects)
%    % Optional field specifying outliers to be scrubbed from the data
%    for iRun = 1:nRuns
%        cd(functionalDirs{iSubject}{iRun});
%        filenames = dir(outliersFilter);
%        subjectInfo(iSubject).outliersPaths{iRun} = fullfile(functionalDirs{iSubject}{iRun},filenames(1).name);
%        clear('filenames');
%    end
%    % Optional field specifying motion parameters to be used as regressors of no interest
%    for iRun = 1:nRuns
%        cd(functionalDirs{iSubject}{iRun});
%        filenames = dir(motionRegressorsFilter);
%        subjectInfo(iSubject).motionRegressorsPaths{iRun} = fullfile(functionalDirs{iSubject}{iRun},filenames(1).name);
%        clear('filenames');
%    end   
%    % Optional field specifying path to mask of no interest for CompCorr
%    anatDirPath = fullfile(subjectPath,'anatomy1');
%    cd(anatDirPath);
%    filenames = dir(compcorrFilter);
%    subjectInfo(iSubject).compcorrMaskPaths = fullfile(anatDirPath,filenames(1).name);
%    clear('filenames');
%    % Optional field specifying path to mask of no interest for removing global signal
%    anatDirPath = fullfile(subjectPath,'anatomy1');
%    cd(anatDirPath);
%    filenames = dir(compcorrFilter);
%    subjectInfo(iSubject).globalSignalMaskPaths = fullfile(anatDirPath,filenames(1).name);
%    clear('filenames');
%end
