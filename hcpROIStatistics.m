
% Script to compute statistics for pairwise condition comparisons from ROI
% responses.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1: Getting Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roiDataFolder = '/mnt/sml_share/HCP/derivatives/fpp/ReplicationResults/TPContrasts';
inputpath = [roiDataFolder '/space-fsLR_res-2_den-32k_desc-handDrawnRTPThrP6workingmemoryFacesVsAllOthersTop5PctN415Sm4Replication_roiData.mat'];
load(inputpath);
outputDesc = fpp.bids.checkNameValue(inputpath,'desc');
%PscbySub size = replication group, PSC size = replication group*number of runs
newpscbySub = pscBySub(:,7:end); 
averagepscbySub = (newpscbySub(:,1:4) + newpscbySub(:,5:end))/2; % Average 0-back and 2-back conditions
psc{4} = (psc{4}(:,1:4) + psc{4}(:,5:end))/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2: Run statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear mixed effects model info
% lmeInfo: T x 3 matrix. Each row specifies task, condition A, and condition B, to test if A > B.
lmeInfo = [4 1 2; 4 1 3; 4 1 4;... 
           4 2 3; 4 2 4; 4 3 4;];
lmeNames = {'FacesVsBodies','FacesVsTools','FaceVsPlaces',...
    'BodiesVsTools','BodiesVsPlaces','ToolsVsPlaces'};
fprintf('\n');
disp(['Statistics for ROI ' outputDesc '...']);
for i=1:length(lmeNames)
    % Fit random-intercept linear mixed-effects model
    lmeContrasts{i} = zeros(1,4);
    lmeContrasts{i}(lmeInfo(i,2:3)) = [1 -1];
    y{i} = psc{t}*lmeContrasts{i}';
    lmeTable{i} = table(y{i},categorical(subNums{t}),'VariableNames',{'y','subj'});
    lmeResults{i} = fitlme(lmeTable{i},'y~1+(1|subj)');
    lmeOneTailedP{i} = min(1,2*(1-tcdf(lmeResults{i}.Coefficients.tStat,lmeResults{i}.Coefficients.DF)));
      disp([lmeNames{i} ': t(' num2str(lmeResults{i}.Coefficients.DF) ') = '...
        num2str(lmeResults{i}.Coefficients.tStat) ', P = ' num2str(lmeOneTailedP{i})]);
end

save(inputpath,'-append','lmeInfo','lmeNames','lmeContrasts','lmeTable','lmeResults','lmeOneTailedP');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3: Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colorArray =  {[0.4118 0.7373 0.4196],[0.3765 0.6431 0.8157],[0.8510 0.1569 0.1333],[1 0.5882 0]};
gapInd = [];
xtick = [1,3,5,7];
xticklabels = {'Faces','Bodies','Tools','Places'};
if contains(outputDesc,'Faces')
    if contains(outputDesc,'LPRC')
         imageTitle = 'LPRC\_Faces';
    
    elseif contains(outputDesc,'RPRC')
        imageTitle = 'RPRC\_Faces';
    
    elseif contains(outputDesc,'RTP') 
        imageTitle = 'RTP\_Faces';
    
    elseif contains(outputDesc,'LTP')
        imageTitle = 'LTP\_Faces';
    end
end
if contains(outputDesc,'Tools')
    if contains(outputDesc,'LPRC')
         imageTitle = 'LPRC\_Tools';
    
    elseif contains(outputDesc,'RPRC')
        imageTitle = 'RPRC Tools';
    end

end
outputFigurePath = [roiDataFolder '/' fpp.bids.checkNameValue(inputpath,'desc') '.png'];
newcondNames = condNames(7:end);
upper = max(mean(averagepscbySub));
upper = round(upper,2);
lower = min(min(mean(averagepscbySub)),0);
lower = round(lower,2);
% ytickVals = linspace(lower, upper, 5);
% ytickVals = round(ytickVals,2);
% ytickVals = unique(ytickVals);
newSD = std(averagepscbySub )/sqrt(size(averagepscbySub ,1));
figure('Position',[200 500 600 400]);
[b,~,e,barInd] = fpp.util.barColor(averagepscbySub,colorArray,newSD,[],0);
gca = gcf().CurrentAxes;
gca.XColor = [0,0,0];
%gca.XTick = xtick;
%gca.XTickLabel = xticklabels;
gca.FontSize = 24;
% gca.YTick = ytickVals;
%ylabel('PSC')
%title(imageTitle)
% % Plot significance stars
statsToPlot = 1:6;
starGroups = {}; starP = [];
for i=statsToPlot
    starGroups{end+1} = barInd(lmeInfo(i,2:3));
    starP(end+1) = lmeOneTailedP{i};
end
indKeep = find(starP<(0.05/4));
starGroups = starGroups(indKeep);
starP = starP(indKeep);
ss = identSigStarSmallPlot(starGroups,starP);
saveas(gcf,outputFigurePath);



