% Find the start and stop of concentration profiles defined the first and
% last value that is one percent of the peak value, working from peak
% outwards instead of start to end (as in onepercentpeak.m)
%
%     [startU, endU, startD, endD] = ronepercentpeak(data)
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

function [startU, endU, startD, endD] = ronepercentpeak(data)

    dotLength = size(data, 1);

    [v, i] = max(data(:,2));
    v = v / 100;     % One percent
    startU = i;      % Start of upstream trace
    endU = i;        % End of upstream trace
    
    [w, k] = max(data(:,3));
    w = w / 100;
    startD = k;      % Start of downstream trace
    endD = k;        % End of downstream trace
    
    % Check start of upstream, from peak to start
    for j=i:-1:1
        startU = j;  % Say the start is the one we're at
        if data(j,2) < v
            break    % If it is, break out
        end
    end
    
    % Now start of downstream - has to start after the upstream trace
    for j=k:-1:startU+1
        startD = j;
        if data(j,3) < w
            break
        end
    end
    
    % The end of the downstream trace
    for j=k:dotLength
        endD = j;
        if data(j,3) < w
            break
        end
    end
    
    % The end of the upstream trace must occur before the end of the
    % downstream trace
    for j=i:endD-1
        endU = j;
        if data(j,2) < v
            break
        end
    end
