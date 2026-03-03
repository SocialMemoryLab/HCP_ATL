
% Compute framewise displaement

function averageFD = avgMovement(confoundPath)

% check propertyies of initial seedpath
nRuns = 1;
subjID = fpp.bids.checkNameValue(confoundPath,'sub');
seedDesc = fpp.bids.checkNameValue(confoundPath,'desc');
seedDen = fpp.bids.checkNameValue(confoundPath,'den');


% Loop across runs, compute correlations
for r=1:nRuns
    
    %load data and calculate new framewosedata
    confoundtable = readtable(confoundPath,"FileType","text");
    transdata = zeros(size(confoundtable{:,1:3}));
    transdata(2:end,:) = diff(confoundtable{:,1:3});
    rotdata = zeros(size(confoundtable,1),3);
    rotdata(2:end,:)= diff(confoundtable{:,4:6});%
    rotdata = (rotdata * pi / 180); %convert to radian

    %calculate framewise translation, rotation
    confoundtable.framewise_translation = sqrt(sum(transdata(:, 1:3).^2, 2));
    confoundtable.framewise_rotation = acos((cos(rotdata(:,1)).*cos(rotdata(:,2)) + cos(rotdata(:,1)).*cos(rotdata(:,3)) + ...
        cos(rotdata(:,2)).*cos(rotdata(:,3)) + sin(rotdata(:,1)).*sin(rotdata(:,2)).*sin(rotdata(:,3)) - 1)/2);
    %calculate frame_wise displacment
    rotMM =50*rotdata(:,:);
    confoundtable.framewise_displacement = sum(abs(rotMM),2) + sum(abs(transdata),2);
    averageFD = sum(confoundtable.framewise_displacement)/numel(confoundtable.framewise_displacement);
end
end