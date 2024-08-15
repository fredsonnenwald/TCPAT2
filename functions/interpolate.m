% Interpolate the sampled RTD and calculate the downstream prediction for
% deconvolution.
%
%     [newOutputT, x2] = interpolate(interpolator, x, time, upstream,
%                                    sampleTimes)
%
%   newOutputT: the downstream prediction
%           x2: the interpolated RTD
%
% interpolator: deconvolution interpolation function handle
%            x: the RTD at sampleTimes
%         time: the time at which the RTD and downstream prediction will be
%               returned at
%     upstream: the upstream data at time, to be used in calculating the
%               downstream prediction
%  sampleTimes: the time values of the RTD (may be non uniform)

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
% Copyright (c) 2010-2024 Fred Sonnenwald

function [newOutputT, x2] = interpolate(interpolator, x, time, upstream, sampleTimes)

    % The first point of an RTD is always 0
    x = [0 x];
    
    % Expand the sub-sampled RTD
    l1 = find(time >= sampleTimes(1)-1e-6, 1);
    l2 = find(time <= sampleTimes(end)+1e-6, 1, 'last');
    x2 = interpolator(time(l1:l2), sampleTimes, x);
    if l1 ~= 1
        x2 = [zeros(l1-1,1); x2];
    end
    
    % Convolute upstream(time) by x(sampleTimes)
    newOutputT = conv(upstream, x2);
    newOutputT = newOutputT(1:length(upstream));