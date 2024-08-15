% Find the start and stop of concentration profiles defined the first and
% last value where the average of the 21 points before and after that value
% (including the value are) than one percent of peak concentration.
%
%     [startU, endU, startD, endD] = onepercentpeakavg(data)
%
% startU: the data point the upstream trace starts at
%   endU: the data point the upstream trace ends at
% startD: the data point the downstream trace starts at
%   endD: the data point the downstream trace ends at
%
%   data: a Nx3 column matrix of [time upstream downstream] concentration
%         data to find the start and end of the upstream and downstream
%         traces

% Start and stop of traces is defined by the first and last value that is
% one percent of the peak value.

function [startU, endU, startD, endD] = onepercentpeakavg(data)

    dotLength = size(data, 1);

    startU = dotLength; % Start of upstream trace
    endU = 1;           % End of upstream trace
    startD = dotLength; % Start of downstream trace
    endD = 1;           % End of downstream trace
    
    span = 20;
    
    % Loop through all the data points
    for i=1:dotLength-span

        % Check upstream
        if sum(data(i:i+span,2))/(span+1) > max(data(:,2))/100 && i < startU
            startU = i;
        elseif sum(data(i:i+span,2))/(span+1) > max(data(:,2))/100 && i > endU
            endU = i;
        end

        % Check downstream
        if sum(data(i:i+span,3))/(span+1) > max(data(:,3))/100 && i < startD && i > startU
            startD = i;
        elseif sum(data(i:i+span,3))/(span+1) > max(data(:,3))/100 && i > endD
            endD = i;
        end

    end
