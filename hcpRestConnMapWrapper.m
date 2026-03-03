
% This is a wrapper for hcpRestConnMap, which calculates whole-brain
% resting-state correlation maps in individual participants.

studyDir = '/mnt/sml_share/HCP';
testDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir  '/derivatives/cshen2/FilteredParticipants.xlsx']);
subjects = table2array(allSubj(:,1));
%subjects = subjects(1:3);
task = 'workingmemory';
contrast = 'ToolsVsAllOthers';
searchNames = {'handDrawnLPRCThrP6','handDrawnRPRCThrP6','handDrawnLTPThrP6','handDrawnRTPThrP6'};
index = 0;  
missi_num = 0;
allfiles = [];

for i = 1:length(subjects)
   for j = 1:length(searchNames)            
       file =[testDir '/'  subjects{i} '/roi/' subjects{i} '_space-fsLR_den-32k_desc-' searchNames{j} task contrast 'Sm4Top5Pct_mask.dscalar.nii'];
            index = index + 1;
            allfiles{index} = file;
   end
end

parfor i = 1: length(allfiles)
    if ~ exist(allfiles{i},'file')
       logtext = fopen([studyDir '/derivatives/cshen2/logs/Sm4RestConnlog.txt' ],'a');
       fprintf(logtext, '%s Not exist\n', allfiles{i});
       file = (allfiles{i});
    else
        hcpRestConnMap(allfiles{i});
    end
end
