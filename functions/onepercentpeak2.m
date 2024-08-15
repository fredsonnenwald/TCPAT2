% Find the start and stop of concentration profiles defined by the first
% and last value that is one percent of the peak value, with a reason
% check.
%
%     [startU, endU, startD, endD] = onepercentpeak2(data)
%
% startU: the data point the upstream trace starts at
%   endU: the data point the upstream trace ends at
% startD: the data point the downstream trace starts at
%   endD: the data point the downstream trace ends at
%
%   data: a Nx3 column matrix of [time upstream downstream] concentration
%         data to find the start and end of the upstream and downstream
%         traces

% MIT License
% Copyright (c) 2010-2024 Fred Sonnenwald

function [startU, endU, startD, endD] = onepercentpeak2(data)

    dotLength = size(data, 1);

    startU = dotLength; % Start of upstream trace
    endU = 1;           % End of upstream trace
    startD = dotLength; % Start of downstream trace
    endD = 1;           % End of downstream trace
    
    checkspan = 15;
    
    upCutoff = max(data(:,2))/100;
    downCutoff = max(data(:,3))/100;
    
    % Loop through all the data points
    for i=1:dotLength

        % Check upstream
        if data(i,2) > upCutoff && i < startU && upstreamCheck(i)
            startU = i;
        elseif i > checkspan && data(i,2) > upCutoff && i > startU + checkspan && upstreamCheck(i - checkspan)
            endU = i;
        end

        % Check downstream
        if data(i,3) > downCutoff && i < startD && i > startU && downstreamCheck(i)
            startD = i;
        elseif i > checkspan && data(i,3) > downCutoff && i > startD + checkspan && downstreamCheck(i - checkspan)
            endD = i;
        end

    end
    
    % The goal here is to verify that the start/end values picked out are
    % actually indicative of what's happening.
    function out = upstreamCheck(key)
        out = 0;
        checkspant = checkspan;
        if (key + checkspant) > length(data)
            checkspant = length(data) - key;
        end
        % Make sure the points after the start are on average bigger than
        % one percent of the peak value
        if sum(data(key:key+checkspant,2))/(checkspant + 1) > upCutoff * 2
            out = 1;
        end
    end
    
    function out = downstreamCheck(key)
        out = 0;
        checkspant = checkspan;
        if (key + checkspant) > length(data)
            checkspant = length(data) - key;
        end
        % Make sure the points before the end are on average bigger than
        % one percent of the peak value
        if sum(data(key:key+checkspant,3))/(checkspant + 1) > downCutoff * 2
            out = 1;
        end
    end

end
        
