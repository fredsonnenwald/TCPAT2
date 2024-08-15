% Find the start and stop of concentration profiles defined by the first 10
% points that exceed 0.5% of the peak concentration, looking from the peak
% to the start and end of the trace.
%
%     [startU, endU, startD, endD] = rtenoneperpeak(data)
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
% Copyright (c) 2011-2024 Fred Sonnenwald

function [startU, endU, startD, endD] = rtenoneperpeak(data)

    dotLength = size(data, 1);
    goal = 10;
    percent = 0.5;

    % Find the fraction of peak we need to be lower than upstream
    [v, i] = max(data(:,2));
    v = v / (1 /(percent / 100));
    startU = i;      % Start of upstream trace
    endU = i;        % End of upstream trace
    
    % Find the fraction of peak we need to be lower than downstream
    [w, k] = max(data(:,3));
    w = w / (1 /(percent / 100));
    startD = k;      % Start of downstream trace
    endD = k;        % End of downstream trace
    
    % Check start of upstream, from peak to start
    for startU=startU:-1:10
        if sum(data(startU-9:startU,2) < v) == goal
            break
        end
    end
    
    % Now start of downstream - has to start after the upstream trace
    for startD=startD:-1:startU+10
        if sum(data(startD-9:startD,3) < w) == goal
            break
        end
    end
    
    % The end of the downstream trace
    for endD=endD:dotLength-10
        if sum(data(endD:endD+9,3) < w) == goal
            break
        end
    end
    
    % The end of the upstream trace must occur before the end of the
    % downstream trace
    for endU=endU:endD-10
        if sum(data(endU:endU+9,2) < v) == goal
            break
        end
    end
