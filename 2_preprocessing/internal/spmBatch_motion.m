function spmBatch_motion(Cfg_motion)

% get files
cd(Cfg_motion.maskPath);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_motion.maskFilter)))=[];
wholeBrainMask = which(filenames(1).name);

nRuns = size(Cfg_motion.filesFolders,1);
cd(Cfg_motion.subjectPath);

% for making file
[~, subjectName, ~] = fileparts(pwd);
mkdir('motion');
cd('motion')
motionpath = pwd;


% calculate the global signal mean

for iRun = 1:nRuns
	% get functionals files
	functionalFiles = dir(fullfile(Cfg_motion.filesFolders{iRun},Cfg_motion.filesFilter));
	%functionalFileNames = {functionalFiles.name};

	numberVol(iRun) = length(functionalFiles);
	[~, nameVol{iRun}, ~] = fileparts(functionalFiles(1,1).name);
	filePaths{numberVol(iRun),1} = []; % preallocate cell
	for iVol = 1:numberVol(iRun)
		filePaths{iVol,1} = fullfile(Cfg_motion.filesFolders{iRun},functionalFiles(iVol,1).name);
	end
	%functionalFilePaths = cellfun(@(c)[Cfg_artMakeCfg.filesFolders{iRun} c],{functionalFiles.name},'uni',false);

	% set mask
	Y = spm_read_vols(spm_vol(wholeBrainMask),1);
	indx = find(Y>0);
	[x,y,z] = ind2sub(size(Y),indx);
	XYZ = [x y z]';

	globalSignalMean{iRun} = mean(spm_get_data(filePaths,XYZ),2);

	clear('filePaths','functionalFiles');
end
cur_sess_start=1;
% ------------------------------------------------------------------------
% Compute Movement parameters and derived signals for outlier identification
% ------------------------------------------------------------------------
motionName{1} = '8-13  : scan-to-scan differences in raw movement parameters';
motionName{2} = '51    : composite measure: max scan-to-scan movement across the 6 control points';
for iRun = 1:nRuns
	% get motion file
	motionFile = dir(fullfile(Cfg_motion.filesFolders{iRun},'rp_*'));
	motionFileName = fullfile(Cfg_motion.filesFolders{iRun},motionFile(1).name);
	motionParameters{iRun} = load(motionFileName);
	respos=diag([70,70,75]);resneg=diag([-70,-110,-45]);
	res = [respos,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1); % 6 control points: [+x,+y,+z,-x,-y,-z];
	zeros(3,4),respos,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
	zeros(3,4),zeros(3,4),respos,zeros(3,1),eye(3),zeros(3,1);
	resneg,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1);
	zeros(3,4),resneg,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
	zeros(3,4),zeros(3,4),resneg,zeros(3,1),eye(3),zeros(3,1);];

	for iTrial = 1:size(motionParameters{iRun},1)
		transformationMatrix = spm_matrix(motionParameters{iRun}(iTrial,:));
		transformationMatrix = transformationMatrix(:)';
		motionXYZ(iTrial,:) = transformationMatrix*res';
	end

	diffMotionXYZ = diff(motionXYZ);
	motion{iRun} = squeeze(sqrt(sum(reshape(diffMotionXYZ,[size(diffMotionXYZ,1),3,6]).^2,2)));
    maxMotion{iRun} = max(motion{iRun},[],2);

	out_mvmt_idx{iRun} = cur_sess_start+(find(maxMotion{iRun} > Cfg_motion.euclidianThreshold | [maxMotion{iRun}(2:end);0] > Cfg_motion.euclidianThreshold ))';%[maxMotion{iRun}(2:end);[0]] > Cfg_motion.euclidianThreshold ))';

	clear('motionXYZ');

end


g = globalSignalMean;
cur_sess_start = 1;
idxind = 4;
out_idx = cell(1,nRuns);
for sess = 1:nRuns
% --------------------------------------------------
% Compute derived signals for outlier identification
% --------------------------------------------------
% g{sess} columns:';
derivedSigalName{1} = '1: global signal';
derivedSigalName{2} = '2: standardized global signal';
derivedSigalName{3} = '3: scan-to-scan differences in global signal';
derivedSigalName{4} = '4: standardized scan-to-scan differences in global signal';

	gsigma{sess} = .7413*diff(prctile(g{sess}(:,1),[25,75]));gsigma{sess}(gsigma{sess}==0)=1; % robus standard-deviation
	gmean{sess} = median(g{sess}(:,1)); % robust mean
	g{sess}(:,2)=(g{sess}(:,1)-gmean{sess})/max(eps,gsigma{sess}); % z-score
	g{sess}(2:end,3)=diff(g{sess}(:,1),1,1);
	dgsigma{sess} = .7413*diff(prctile(g{sess}(:,3),[25,75]));dgsigma{sess}(dgsigma{sess}==0)=1;
	dgmean{sess} = median(g{sess}(:,3));
	g{sess}(2:end,4)=(g{sess}(2:end,3)-dgmean{sess})/max(eps,dgsigma{sess});
	z_thresh = 0.1*round(Cfg_motion.zThreshold*10);

	%out_idx{sess} = cur_sess_start+(find(abs(g{sess}(:,idxind)) > z_thresh|abs([g{sess}(2:end,idxind);0]) > z_thresh))'-1;
	out_idx{sess} = (find(abs(g{sess}(:,idxind)) > z_thresh|abs([g{sess}(2:end,idxind);0]) > z_thresh))';

end


for iRun = 1:nRuns
    motionScrubbed{iRun} = vertcat(zeros(1,6),motion{iRun});
	tempMat = [out_idx{iRun} out_mvmt_idx{iRun}];
	outliers{iRun} = unique(tempMat);

	globalsignal{iRun} = zeros(numberVol(iRun),numel(outliers{iRun}));
	for iVol = 1:numel(outliers{iRun})
		globalsignal{iRun}(outliers{iRun}(iVol),iVol) = 1;
	end
	globalsignal_movement{iRun} = [globalsignal{iRun} motionParameters{iRun}];  

	% remove Euclidean movement of control points for scrubbed volumes
	motionScrubbed{iRun}(outliers{iRun},:) = [];
	meanMotionScrubbed{iRun} = mean(motionScrubbed{iRun},2); % average absolute value of control point movement per retained volume
	meanMotion{iRun} = mean(motion{iRun},2); % average absolute value of control point movement per each volume
	runMotionScrubbed(iRun,1) = mean(meanMotionScrubbed{iRun},1); % average motion per run
	runMotion(iRun,1) = mean(meanMotion{iRun},1); % average motion per run

	cd(Cfg_motion.filesFolders{iRun});
	R = globalsignal{iRun};
	save(strcat('motion_outliers_only_',nameVol{iRun}),'R');
	R = globalsignal_movement{iRun};
	save(strcat('motion_outliers_and_movement_',nameVol{iRun}),'R');
end

for iRun = 1:nRuns
%	Regressors.R{iRun}.run = Cfg_motion.filesFolders{iRun}; %%%%%DAE
	Regressors.R{iRun}.location = Cfg_motion.filesFolders{iRun};
	Regressors.R{iRun}.globalsignal = globalsignal{iRun};
	Regressors.R{iRun}.motionParameters = motionParameters{iRun};
	Regressors.R{iRun}.motionOutliers = out_mvmt_idx{iRun};
	Regressors.R{iRun}.globalOutliers = out_idx{iRun};
	Regressors.R{iRun}.controlPointMotion = motion{iRun};
    Regressors.R{iRun}.meanControlPointMotionScrubbed = runMotionScrubbed(iRun);
    Regressors.R{iRun}.meanControlPointMotion = runMotion(iRun);
	Regressors.meanControlPointMotionScubbed = runMotionScrubbed;
	Regressors.meanControlPointMotion = runMotion;
	Regressors.parameters.globalsignal = derivedSigalName{idxind};
	Regressors.parameters.motion = motionName{2};
end

cd(motionpath);
save(strcat('motion_total_',subjectName),'Regressors');

end