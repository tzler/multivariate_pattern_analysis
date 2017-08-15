% Generates 3D nifti of anatomical and bold data

addpath('C:\stefano\spm12');

subjectID = [10 16 17 18 21 22 23 25 26 27 38 39 40 41 42 28 29 31 32 33 34 36 57 63 64 66 67 68 69 70];
nSubjects = numel(subjectID);

load('/mindhive/gablab/u/daeda/analyses/EIB_data/EIB_subject_taskruns.mat');
load('/mindhive/gablab/u/daeda/analyses/EIB_data/EIBanat.mat');

for iSubject = 1:nSubjects
	fprintf('\nSubject: %d, ID: %s\n',iSubject, s(subjectID(iSubject)).ID);

	subjectFolderPath = fullfile('/mindhive/gablab/u/daeda/analyses/EIB_data',s(subjectID(iSubject)).ID);
	cd(subjectFolderPath);

	boldFolderPath = fullfile(subjectFolderPath,'bold');
	mkdir(boldFolderPath);

	foldername = dir('dicoms');
	dicomFolderPath = fullfile(subjectFolderPath,foldername.name,'dicom');
	cd(dicomFolderPath); 

	% anatomy
	fprintf('Anatomy: %d\n',EIBanat(find([EIBanat.ID]==subjectID(iSubject))).run);
	filenamesAnat = dir(sprintf('*-%d-*.dcm',EIBanat(find([EIBanat.ID]==subjectID(iSubject))).run));
	for iFile = 1:length(filenamesAnat)
		hdrAnat(iFile) = spm_dicom_headers(filenamesAnat(iFile).name, []);
	end

	spm_dicom_convert(hdrAnat,'all','flat','nii');
	newFolderPathAnat = fullfile(subjectFolderPath,'anat');
	mkdir(newFolderPathAnat);
	imgFilesAnat = dir('s*');
	for iFile = 1:length(imgFilesAnat)
		movefile(fullfile(dicomFolderPath,imgFilesAnat(iFile).name),fullfile(newFolderPathAnat,imgFilesAnat(iFile).name));
	end

	fprintf('EIBmain\n');
	runs = s(subjectID(iSubject)).EIB_main;
	for iRun = 1:numel(runs)
		filenames = dir(sprintf('*-%d-*.dcm',runs(iRun) ));
		for iFile = 1:length(filenames)
			hdr(iFile) = spm_dicom_headers(filenames(iFile).name, []);
		end


		spm_dicom_convert(hdr,'all','flat','nii');
		newFolderPath = fullfile(boldFolderPath,sprintf('%03d',runs(iRun)));
		mkdir(newFolderPath);
		imgFiles = dir('f*');
		for iFile = 1:length(imgFiles)
			movefile(fullfile(dicomFolderPath,imgFiles(iFile).name),fullfile(newFolderPath,imgFiles(iFile).name));
		end

	end
	clear('runs', 'filenames', 'hdr', 'newFolderPath', 'imgFiles');

	fprintf('tomLoc\n');
	runs = s(subjectID(iSubject)).tomloc;
	if numel(runs) == 2
		for iRun = 1:numel(runs)
			filenames = dir(sprintf('*-%d-*.dcm',runs(iRun) ));
			for iFile = 1:length(filenames)
				hdr(iFile) = spm_dicom_headers(filenames(iFile).name, []);
			end


			spm_dicom_convert(hdr,'all','flat','nii');
			newFolderPath = fullfile(boldFolderPath,sprintf('%03d',runs(iRun)));
			mkdir(newFolderPath);
			imgFiles = dir('f*');
			for iFile = 1:length(imgFiles)
				movefile(fullfile(dicomFolderPath,imgFiles(iFile).name),fullfile(newFolderPath,imgFiles(iFile).name));
			end

		end
	end
	clear('runs', 'filenames', 'hdr', 'newFolderPath', 'imgFiles');

	fprintf('EmoBioLoc\n');
	runs = s(subjectID(iSubject)).EmoBioLoc;
	if numel(runs) == 2
		for iRun = 1:numel(runs)
			filenames = dir(sprintf('*-%d-*.dcm',runs(iRun) ));
			for iFile = 1:length(filenames)
				hdr(iFile) = spm_dicom_headers(filenames(iFile).name, []);
			end


			spm_dicom_convert(hdr,'all','flat','nii');
			newFolderPath = fullfile(boldFolderPath,sprintf('%03d',runs(iRun)));
			mkdir(newFolderPath);
			imgFiles = dir('f*');
			for iFile = 1:length(imgFiles)
				movefile(fullfile(dicomFolderPath,imgFiles(iFile).name),fullfile(newFolderPath,imgFiles(iFile).name));
			end

		end
	end
	clear('runs', 'filenames', 'hdr', 'newFolderPath', 'imgFiles');

	fprintf('\nComplete: subject: %d, ID: %s\n',iSubject, s(subjectID(iSubject)).ID);

end

