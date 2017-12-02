function subjectInfo_mvpc = mvpc_generateFullDataPaths_EMF(data)

subjectCount = 0;
for iExp = 1:length(data)
    badSubjects = find(data(iExp).modelData);
    for iSubject = 1:length(data(iExp).subjects)
        usable = 0; 
        if ~sum(iSubject==badSubjects)
            subjectCount = subjectCount + 1; 
            subjectInfo_mvpc(subjectCount).ID = data(iExp).subjects{iSubject}; %% tyler changed the (iSubject) to {iSubject} to get rid of an error about formatting on the next line 
            subjectInfo_mvpc(subjectCount).subjectDir = fullfile(data(iExp).root,data(iExp).cfg(iSubject).info.study,subjectInfo_mvpc(subjectCount).ID);
            for iBoldDir = 1:length(data(iExp).bold{iSubject})
                if data(iExp).goodRuns(iSubject,iBoldDir) 
                    usable = usable + 1; 
                    % tyler changed (iBoldDir) to {iBoldDir}
                    subjectInfo_mvpc(subjectCount).functionalDirs{usable} = fullfile(subjectInfo_mvpc(subjectCount).subjectDir,'bold',sprintf('%03d',data(iExp).bold{iSubject}(iBoldDir)));
                end
            end 
        end
    end
end

end

% generate table with good runs across both studies -- ty
% tmpRuns = [data(1).goodRuns' data(2).goodRuns']';
% remove = find(data(1).modelData);  % there aren't any unusable subjects in data(2)
% tmpRuns(remove,:) = NaN;
% Cfg_mvpcRoi.dataInfo.goodRuns = reshape(tmpRuns(isfinite(tmpRuns)), 89,4); 




% before tyler started working on it
% function subjectInfo_mvpc = mvpc_generateFullDataPaths_EMF(data)
% 
% counter = 1;
% for iExp = 1:length(data)
%     badSubjects = find(data(iExp).modelData);
%     for iSubject = 1:length(data(iExp).subjects)
%         if ~sum(iSubject==badSubjects)
%             subjectInfo_mvpc(counter).ID = data(iExp).subjects{iSubject}; %% tyler changed the (iSubject) to {iSubject} to get rid of an error about formatting on the next line 
%             subjectInfo_mvpc(counter).subjectDir = fullfile(data(iExp).root,data(iExp).cfg(iSubject).info.study,subjectInfo_mvpc(counter).ID);
%             for iBoldDir = 1:length(data(iExp).bold{iSubject})
%                 % tyler changed (iBoldDir) to {iBoldDir}
%                 subjectInfo_mvpc(counter).functionalDirs{iBoldDir} = fullfile(subjectInfo_mvpc(counter).subjectDir,'bold',sprintf('%03d',data(iExp).bold{iSubject}(iBoldDir)));
%             end
%             counter = counter+1;
%         end
%     end
% end
% 
% end


