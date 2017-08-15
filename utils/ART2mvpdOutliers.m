function ART2mvpdOutliers(paths,fileFilter)

% subjects = [1:8,10];
% templatePath 
% for iSubject = 1:length(subjects)
%     paths{iSubject} = sprintf(templatePath,subjects(iSubject));
% end

for i=1:length(paths)
	cd(paths{i});
	filenames = dir(fileFilter);
        temp = load(filenames(1).name); % load variable R
        outliers = find(sum(temp.R,2));
        fid = fopen('outliers.txt','w');
        for j=1:length(outliers)-1
		fprintf('%d\n',outliers(j));
        end
	fprintf('%d',outliers(j+1));
	fclose(fid);
end
