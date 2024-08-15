% Wrapper function for deconvolution interpolator functions to account for
% RTD length differing from time length within the TCPAT2 application. Note
% the interpolator functions are the lin and linma functions. This does not
% call the interpolate function.
%
%     out = interpolatorWrapper(interpolator, time, sampleTimes, values,
%                               rtdLengthI)
%
% interpolator: deconvolution interpolation function handle
%         time: the points to interpolate at
%  sampleTimes: the times corresponding to values
%       values: the data to interpolate
%   rtdLengthI: the lenght of the RTD matrix

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
% Copyright (c) 2019-2024 Fred Sonnenwald

function out = interpolatorWrapper(interpolator, time, sampleTimes, values, rtdLengthI)

    time = time(1:rtdLengthI);
    out = interpolator(time, sampleTimes, values);
