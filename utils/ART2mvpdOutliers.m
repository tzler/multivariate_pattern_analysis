function ART2mvpdOutliers(paths,fileFilter)

subjects = [1,3:5,8,12:17];
templatePath = '/mindhive/saxelab3/anzellotti/facesVoices_art2/4_preprocessedData_PSF/sub%02d/run%d';
counter = 1;
for iSubject = 1:length(subjects)
    for iRun = 1:5
        paths{counter} = sprintf(templatePath,subjects(iSubject),iRun);
        counter = counter+1;
    end
end
fileFilter = 'motion_outliers_only_*.mat';

for i=1:length(paths)
	cd(paths{i});
	filenames = dir(fileFilter);
    temp = load(filenames(1).name); % load variable R
    outliers = find(sum(temp.R,2));
    fid = fopen('outliers.txt','w');
    for j=1:length(outliers)-1
        fprintf(fid,'%d\n',outliers(j));
    end
	fprintf(fid,'%d',outliers(j+1));
	fclose(fid);
end
