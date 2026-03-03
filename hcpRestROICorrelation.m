
% Function to compute resting-state correlations between a set of ROIs in
% IDENT data.
%
% Arguments:
% - roiDescs (cell array): BIDS descriptions of ROIs to correlation
% - outputDesc (string): BIDS description for output file
%  Optional
% - isMSHBM (bool): whether use MSHBM ROIs(networks)

function hcpRestROICorrelation(roiDescs,outputDesc,group)

studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir '/derivatives/cshen2/Balanced' group 'IDs.xlsx']);
subjects = table2array(allSubj(:,1));
% subjects = subjects(1:3);
nRuns = 2;
%nVols = 300;
spaceStr = 'fsLR_den-32k';
nROIs = length(roiDescs);
inputDesc = 'fixdenoised_bold';
outputPath = [fppDir '/' group 'Results/space-' spaceStr '_desc-' outputDesc 'N' int2str(length(subjects)) '_ROICorrelationData' group '.mat'];
corrMat = zeros(nROIs,nROIs,length(subjects));
%loading all roi file pathes
roiPaths = cell(nROIs, length(subjects));
load('/mnt/sml_share/HCP/derivatives/cshen2/32492_to_59412.mat')%convertion matrix to remove medial wall
parfor s = 1:length(subjects)
    subject = subjects{s};
    %if subject == 'sub-hcp205826', continue;end
    subjDir = [fppDir '/' subject];
    roiDir = [subjDir '/roi'];
    MSHBMDir = [subjDir '/anat/MSHBMmasks'];
    du15Dir = [subjDir '/anat/DU15NETmasks']
    for r = 1:nROIs
        roiPath = [roiDir '/' subject '_space-' spaceStr '_desc-' roiDescs{r} '_mask.dscalar.nii'];
        if ~exist(roiPath,'file')
            roiPath2 = [du15Dir '/' subject '_space-individual_den-32k_desc-' roiDescs{r} '_mask.dscalar.nii'];  
            if ~exist(roiPath2,'file'), error([subject roiDescs{r} '  roi misssing  PATH: \n' roiPath2]);end
            roiPath = roiPath2
        end
        roiPaths{r, s} = roiPath
    end
end

for s=1:length(subjects)
    spaceStr = 'fsLR_den-32k';
    % Define paths
    subject = subjects{s};
    
    subjDir = [fppDir '/' subject];
    roiDir = [subjDir '/roi'];
    funcDir = [subjDir '/func'];
    
    % Load ROIs
    roiMat = [];
    roiAvgMat = [];
    for r=1:nROIs
        roiMat(:,r) = fpp.util.readDataMatrix(roiPaths{r, s});
        roiAvgMat(:,r) = roiMat(:,r)/sum(roiMat(:,r)); % Dot product with this vector = mean across ROI
    end
    
    for r=1:nRuns
        %read rest data
        spaceStr = 'fsLR_res-2_den-32k';
        restPath = [funcDir '/' subject '_task-rest_run-' fpp.util.numPad(r,2)...
            '_space-' spaceStr '_desc-' inputDesc '.dtseries.nii'];
        if ~exist(restPath,'file') %% for subjects without resting run2
            if r == 2
            logtxt = fopen([studyDir '/derivatives/cshen2/logs/ROICorrlog.txt'],'a')
            fprintf(logtxt,[subject fpp.util.numPad(r,2) 'second rest file not exist Error occured at:   ' datestr(now) '\n']);
            corrMat(:,:,s) = corrMat(:,:,s) + corrMat(:,:,s);
            continue
            end
            if r == 1
                error([subject 'had no rest file'])
            end
        end
        [restMat,hdr] = fpp.util.readDataMatrix(restPath);
        spaceStr = 'fsLR_den-32k';
        % Define outlier volumes
        restMat = restMat(1:59412,:);
        %confoundPath = fpp.bids.changeName(restPath,'desc','','confounds','.tsv');
        %utlierPath = fpp.bids.changeName(restPath,{'space','res','den','desc'},{'','','',''},'outliers','.tsv');
        %outlierInd = fpp.util.readOutlierTSV(outlierPath);
        %goodInd = setdiff(1:nVols,outlierInd);
        
        % Load resting data
        %restMat = fpp.util.readDataMatrix(restPath);
        %restMat = restMat(:,goodInd);
        
        % Compute ROI-averaged time series
        roiAvgSeries = restMat'*roiAvgMat;  % Time point by ROI matrix of time series
        
        % Compute correlations
        corrMat(:,:,s) = corrMat(:,:,s) + corr(roiAvgSeries)/nRuns;
        
        disp(['Computed correlation matrix for ' subject ', run ' int2str(r)]);
    end
end

save(outputPath,'corrMat','roiDescs');
%% Correaltion heatmap Plot
Labels = {'LTP','RTP','LPRC','RPRC','DN-A','DN-B','VIS-C','VIS-P','CG-OP','SMOT-A','SMOT-B','AUD','PM-PPr','dATN-A','dATN-B',...
    'LANG','FPN-A','FPN-B','SALPMN'};;
figure;
imagesc(squeeze(mean(corrMat,3)),[-1 1]);
colorbar;
set(gcf,'Color',[1 1 1]);
a = gca;
a.XTick = [1:nROIs];
a.XTickLabel = Labels;
a.YTick = [1:nROIs];
a.YTickLabel = Labels;
a.FontSize = 8;


%% ROI Correaltion profile plot 
outputDir = fullfile(fppDir,[group 'Results']);
hcpRestROICorrealtionBarPlot(corrMat,group,outputDir,spaceStr,roiDescs(1:8));


end