% Pick sample points to calculate the RTD at during deconvolution based on
% the initial guess of the RTD. Put the sample points where there's the
% most change in slope in the RTD. Use the 0.02% percentile of the guessed
% CRTD as the start of the RTD and the 99.8% percentile of the guessed CRTD
% as the end.
%
%     [samplePoints, sampleTimes] = slopeBased3(data, noPoints, [newlength])
%
% samplePoints: Time indexes the the RTD will be calculated at
%  sampleTimes: The times at which the RTD will be calculated at
%
%         data: Matrix of concentration data, where the first column
%               is time, second column is upstream, and third column
%               is downstream concentration data
%     noPoints: The number of sample points to use
% (optional) newlength: The maximum length of the RTD, defaults to the
%               length of data, i.e., size(data(:,1))

% References
%
% Sonnenwald, F., Stovin, V., & Guymer, I. (2014). Configuring maximum
%     entropy deconvolution for the identification of residence time
%     distributions in solute transport applications. Journal of Hydrologic
%     Engineering, 19(7), 1413-1421.
% Sonnenwald, F., Stovin, V., & Guymer, I. (2015). Deconvolving smooth
%     residence time distributions from raw solute transport data. Journal
%     of Hydrologic Engineering, 20(11), 04015022.

% MIT License
% Copyright (c) 2020-2024 Fred Sonnenwald

function [samplePoints, sampleTimes] = slopeBased3(data, noPoints, newlength)

    % We require the ifftfft guess to work...
    if exist('ifftfft', 'file') ~= 2
        ME = MException('Dependencies:NotSatisfied', ...
            'Depends on other functions not present.');
        throw(ME);
    end

    % mass-balance
    data(:,3) = data(:,3) ./ sum(data(:,3)) * sum(data(:,2));
    
    % use the ifftfft guess function.
    iguess = ifftfft(data, 1:length(data));
    guess = iguess;
    
    % the RTD cannot be negative, but noisy data can cause it
    guess(guess<0) = 0;
    
    % ensure the RTD goes to 1
    guess = guess ./ sum(guess);
    
    % find a rough estimate of the start of the concentration profiles
    cutoff = 0.002; % X percent of peak
    numpoints = 3; % consecutive # of points
    starts = zeros(1,2);
    for ii=2:3
        [m, k] = max(data(:,ii));
        k = data(1:k,ii) < m*cutoff;
        k = conv(k, ones(1,numpoints)); % find three contiguous points
        k = find(k == numpoints, 1, 'last');
        if ~isempty(k)
            starts(ii-1) = k;
        else
            starts(ii-1) = 1;
        end
    end

    % and turn those starts into a rough estimate of time delay, offsetting
    % by 30% earlier to be very conservative
    % this is where the RTD could/will start
    firstarrivalpoint = floor((starts(2) - starts(1)) * 0.7) - 1; % under-estimate
    if firstarrivalpoint <= 1
        firstarrivalpoint = 2;
    end
    
    % determine where the RTD ends as either the specified end, the end of
    % the data, or where the guessed RTD passes the 99.8%ile
    if exist('newlength', 'var')
        if newlength > length(data)
            endpoint = length(data);
        else
            endpoint = newlength;
        end
    else
        endpoint = find(cumsum(guess) > 0.998, 1);
        if isempty(endpoint)
            error('could not find 99% percentile')
        end
        if endpoint > length(data)
            endpoint = length(data);
        end
    end
    
    % set the parts of the guess that won't be counted to to zero
    guess(1:firstarrivalpoint-1) = 0;
    guess(endpoint+1:end) = 0;
    guess = guess ./ sum(guess);

    % calculate the gradient of the guess
    guess = abs(diff(guess));
    guess(firstarrivalpoint-1) = 0;
    guess(endpoint) = 0;

    % divide up the the area under the RTD into a number of sections,
    % then go through from start to end and when the area between point a
    % and point b is greater than the even division, add a new sample point
    % and continue with point b as a new point a
    
    % when the bucket exceeds this, add a new sample point
    goal = sum(guess) / (noPoints - 2);
    
    % keep track of where we are in samplePoints
    pos = 2;
    bucket = 0;
    [~, k] = max(iguess);
    samplePoints = k;
    
    % from the peak onwards to the end
    for i=k:length(guess)
        % add to the bucket
        bucket = bucket + guess(i);
        if bucket >= goal
            % add a sample point and empty the bucket
            samplePoints(pos) = i;
            pos = pos + 1;
            bucket = bucket - goal;
        end
    end
    
    % from the peak to the start in reverse
    bucket = 0;
    for i=k:-1:1
        % add to the bucket
        bucket = bucket + guess(i);
        if bucket >= goal
            % add a sample point and empty the bucket
            samplePoints(pos) = i;
            pos = pos + 1;
            bucket = bucket - goal;
        end
    end
    
    % have a sample point at time 0, the first arrival point, the
    % calculated sample points, and then the end, making sure there are no
    % duplicates, negative index values, and no values extending beyond
    % the size of data
    samplePoints = unique([1 firstarrivalpoint samplePoints endpoint]);
    samplePoints = samplePoints(samplePoints > 0);
    samplePoints = samplePoints(samplePoints <= length(data));
    
    sampleTimes = data(samplePoints,1);
