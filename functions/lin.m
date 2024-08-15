% Linear interpolation wrapper for deconvolution.
%
%     out = lin(time, sampleTimes, values)
%
%        time: the points to interpolate at
% sampleTimes: the times corresponding to values
%      values: the data to interpolate

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

function out = lin(time, sampleTimes, values)

    % Use the built-in linear interpolation function
    out = interp1(sampleTimes, values, time, 'linear');
