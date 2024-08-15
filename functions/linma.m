% Linear interpolation with an added moving average (LAMA) function for
% deconvolution.
%
%     [out2, span] = linma(time, sampleTimes, values, window, window_max)
%
%        out2: the interpolated result
%        span: the final moving average window size
%
%        time: the points to interpolate at
% sampleTimes: the times corresponding to values
%      values: the data to interpolate
%      window: (beta) the fraction of the CRTD at the peak of the RTD, used
%              in determining the movinga verage window size
%  window_max: the largest possible moving average window size in number of
%              time steps, usually the biggest gap between sample points
%              near the peak of the RTD

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
% Copyright (c) 2013-2024 Fred Sonnenwald

function [out2, span] = linma(time, sampleTimes, values, window, window_max)

    % We require the deconvolution linear interpolation wrapper to work...
    if exist('lin', 'file') ~= 2
        ME = MException('Dependencies:NotSatisfied', ...
            'Depends on other functions not present.');
        throw(ME);
    end

    % Start with a linear interpolation
    out = lin(time, sampleTimes, values);

    % Estimate a window going backwards
    [~, b] = max(out); % peak
    c = cumsum(out(1:b));
    b2 = find(c > window*c(end), 1); % find area covered
    span = round((b - b2)/2);
    
    % The ma function could freak out in these cases, make good defaults
    if isempty(span) || span < 1
        span = 1;
    elseif span < 2
        span = 2;
    end
    
    % This assumes that window is a max window size
    if span > window_max
    	span = window_max;
    end
    
    % Do the moving average
    out2 = ma(out, span);
    out2 = out2(span+1:length(out2)-span);
