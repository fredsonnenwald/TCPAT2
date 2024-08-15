% Find the start and stop of concentration profiles defined the first and
% last value that is one percent of the peak value.
%
%     [startU, endU, startD, endD] = onepercentpeak(data)
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

function [startU, endU, startD, endD] = onepercentpeak(data)

    dotLength = size(data, 1);

    startU = dotLength; % Start of upstream trace
    endU = 1;           % End of upstream trace
    startD = dotLength; % Start of downstream trace
    endD = 1;           % End of downstream trace

    % Loop through all the data points
    for i=1:dotLength

        % Check upstream
        if data(i,2) > max(data(:,2))/100 && i < startU
            startU = i;
        elseif data(i,2) > max(data(:,2))/100 && i > endU% && i < endD
            endU = i;
        end

        % Check downstream
        if data(i,3) > max(data(:,3))/100 && i < startD && i > startU
            startD = i;
        elseif data(i,3) > max(data(:,3))/100 && i > endD
            endD = i;
        end

    end
