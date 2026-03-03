
% Wrapper for identRestROICorrelation script.

searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6'};
Du15net = {'DNA','DNB','LANG','FPNA','FPNB','SALPMN','CGOP','dATNA',...
    'dATNB','PMPPr','SMOTA','SMOTB','AUD','VISC','VISP'};
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6',...
    'handDrawnRPRCThrP6'};
tasks = {'workingmemory'};
Contrasts = {'FacesVsAllOthers','ToolsVsAllOthers'};
suffix = 'Sm4Top5Pct';
outputDesc = [suffix  'AllContrastDU15NET'];
roiDescs = {};
index = 1;
for c=1:length(Contrasts)
    for t=1:length(tasks)
        for s=1:length(searchNames)
            roiDescs{index} = [searchNames{s} tasks{t} Contrasts{c} suffix];
            index = index +1;
        end
    end
end
if exist('index','var'); delete  index; end

if ~ isempty(Du15net) && length(roiDescs) < (length(Du15net) +length(searchNames)*length(Contrasts))
    roilength = length(roiDescs);
for s = 1 : length(Du15net)
    index = roilength + s;
    roiDescs{index} = ['DU15NET' Du15net{s}];
end
end

hcpRestROICorrelation(roiDescs,outputDesc,'Replication');
