
% Function to compute CIFTI-based resting-state functional connectivity map
% from a seed ROI input.
%
% Arguments:
% - seedPath (string): path to seed ROI CIFTI file

% author: Benjamin Deen
% modifier: Tony Shen

%InutSample
%inputPath = '/mnt/sml_share/HCP/derivatives/fpp/sub-hcp100206/roi/sub-hcp100206_space-fsLR_den-32k_desc-handDrawnLTPThrP6workingmemoryFacesVsAllOthersSm4Top5PctLORO01_mask.dscalar.nii';

function hcpRestConnMap(seedPath)

% check propertyies of initial seedpath
bidsDir = fpp.bids.checkBidsDir(seedPath); % basepath before sub's dictnory
spaceStr = '_space-fsLR_res-2_den-32k'; % space for seed & rest 
nRuns = 4;
inputDesc = 'fixdenoised'; %desc for the rest file
subjID = fpp.bids.checkNameValue(seedPath,'sub'); 
seedDesc = fpp.bids.checkNameValue(seedPath,'desc');
seedDen = fpp.bids.checkNameValue(seedPath,'den');
logtext = fopen('/mnt/sml_share/HCP/derivatives/cshen2/logs/Sm4RestConnlog.txt','a');
if ~strcmp(seedDen,'32k'), error('Seed must be defined in 32k fsLR space.'); end
outputDir = ['/mnt/sml_share/HCP/derivatives/cshen2/Sm4restconn/sub-' subjID '_Sm4_task-rest' spaceStr '_funcconn' ];
outputPath = [outputDir '/sub-' subjID '_task-rest_ROI-' spaceStr '_desc-' inputDesc...
    'Seed' seedDesc '_rstat.dscalar.nii'];
overwrite = 1;
if exist(outputPath,'file') && ~overwrite
    fprintf(logtext, [subjID, seedDesc, ' RestConnectMap Already Exist\n']);
    disp([subjID, seedDesc, ' RestConnectMap Already Exist\n']);
    return
end

% Define paths used inside function
% read subject directory based on the seed path
subjDir = [bidsDir '/sub-' subjID];

% read two function Dirs inside the subject Dir
funcDir = [subjDir '/func'];
analysisDir = [subjDir '/analysis'];


% Load seed
seedMat = fpp.util.readDataMatrix(seedPath);
missed_runs = 0;
% Loop across runs, compute correlations
for r=1:nRuns
    % Load data (this will be the full path tp the resting data.nii)
    restPath = [funcDir '/sub-' subjID '_task-rest_run-' fpp.util.numPad(r,2)...
        spaceStr '_desc-' inputDesc '_bold.dtseries.nii'];
    if ~exist(restPath,"file")
        missed_runs = missed_runs + 1;
        continue
    end
    if missed_runs >= nRuns;error([subjID ' did not find anu resting state runs']);end
    [restMat,hdr] = fpp.util.readDataMatrix(restPath);
    
    % If seed doesn't have subcortical CIFTI components, zero-pad
    if r==1 && size(restMat,1)>size(seedMat,1)
        seedMat = [seedMat; zeros(size(restMat,1)-size(seedMat,1),1)];
    end
    
    nTpts = size(restMat,2);
    
    % Load resting data, concatenate with prior runs
    restMat = zscore(restMat,0,2)/sqrt(nTpts-1); % Mean zero,for outlier data
    seedSeries = zscore(mean(restMat(seedMat==1,:)))/sqrt(nTpts-1);
    corrMat(:,r) = restMat*seedSeries';
end

corrMat = mean(corrMat,2);

% Write output
if ~exist(outputDir,'dir'), mkdir(outputDir); end
fpp.util.writeDataMatrix(corrMat,hdr,outputPath);
disp(['Finished running restconn for ' subjID ' ' seedDesc]);end

