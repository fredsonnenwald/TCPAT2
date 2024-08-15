% Find the start and stop of concentration profiles defined by the the
% first and last 10 points that exceed 1% of the peak concentration.
%
%     [startU, endU, startD, endD] = tenoneperpeak(data)
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

function [startU, endU, startD, endD] = tenoneperpeak(data)

    dotLength = size(data, 1);

    startU = dotLength; % Start of upstream trace
    endU = 1;           % End of upstream trace
    startD = dotLength; % Start of downstream trace
    endD = 1;           % End of downstream trace
    
    oneperU = max(data(:,2))/100;
    oneperD = max(data(:,3))/100;

    % Loop through all the data points
    for i=1:dotLength-9

        % Check upstream
        if sum(data(i:i+9,2) > oneperU) == 10 && i < startU
            startU = i;
        elseif sum(data(i:i+9,2) > oneperU) == 10 && i > endU% && i < endD
            endU = i;
        end

        % Check downstream
        if sum(data(i:i+9,3) > oneperD) == 10 && i < startD && i > startU
            startD = i;
        elseif sum(data(i:i+9,3) > oneperD) == 10 && i > endD
            endD = i;
        end

    end
    
    % Add a little bit extra margin
    extra = round(dotLength * 0.002);
    startU = startU - extra;
    endD = endD + extra * 2;
