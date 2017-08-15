function [ artFilePath ] = spmBatch_artMakeCfg(Cfg_artMakeCfg)

% get files
cd(Cfg_artMakeCfg.maskPath);
filenames = dir;
filenames(cellfun(@isempty,regexp({filenames.name}, Cfg_artMakeCfg.maskFilter)))=[];
wholebrainmask = which(filenames(1).name);

	nRuns = size(Cfg_artMakeCfg.filesFolders,1);
	cd(Cfg_artMakeCfg.subjectPath);
	[~, subjectName, ~] = fileparts(pwd);
	mkdir('motion');
	cd('motion')
	motionpath = pwd;
	

	artFilename = sprintf('ARTcfg_%s.cfg',subjectName);
    
	fid = fopen( artFilename, 'wt' );

	fwrite(fid,sprintf('sessions: %d\n',nRuns));
	fwrite(fid,sprintf('global_mean: 2                      # global mean type (1: Standard 2: User-defined mask)\n'));
	fwrite(fid,sprintf('global_threshold: 4.9               # threhsolds for outlier detection\n'));
	fwrite(fid,sprintf('motion_threshold: 1.15\n'));
	fwrite(fid,sprintf('motion_file_type: 0                 # motion file type (0: SPM .txt file 1: FSL .par file 2:Siemens .txt file)\n'));
	fwrite(fid,sprintf('motion_fname_from_image_fname: 0    # 1/0: derive motion filename from data filename\n'));
	fwrite(fid,sprintf('#spm_file: ./2back/2bmodel/SPM.mat   # location of SPM.mat file (comment this line if you do not wish to estimate number of outliers per condition\n'));
	fwrite(fid,sprintf('#image_dir: ./1back/                 # functional and movement data folders (comment these lines if functional/movement filenames below contain full path information\n'));
	fwrite(fid,sprintf('#motion_dir: %s                \n',motionpath));
	fwrite(fid,sprintf('mask_file: %s                \n\n',wholebrainmask));
	fwrite(fid,sprintf('end\n\n\n'));

for iRun = 1:nRuns
	% get functionals files
	functionalFiles = dir(fullfile(Cfg_artMakeCfg.filesFolders{iRun},Cfg_artMakeCfg.filesFilter));

	fwrite(fid,sprintf('session %d image', iRun));
	for iFile = 1:size(functionalFiles,1)
        tempfile = fullfile(Cfg_artMakeCfg.filesFolders{iRun},functionalFiles(iFile).name);
		fwrite(fid,sprintf(' %s', tempfile));
	end
fprintf(fid,'\n');
end

fprintf(fid,'\n\n');

for iRun = 1:nRuns
	% get motion file
	motionFile = dir(fullfile(Cfg_artMakeCfg.filesFolders{iRun},'rp_*'));
    tempfile = fullfile(Cfg_artMakeCfg.filesFolders{iRun},motionFile(1).name);
	fwrite(fid,sprintf('session %d motion %s\n', iRun, tempfile));
end

fprintf(fid,'\n\n\nend\n\n');


fclose(fid);
artFilePath = which(artFilename);
end