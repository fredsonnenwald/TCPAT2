% The Rt2 based constraint for deconvolution. Returns an inequality for
% fmincon where closer to 0 is better.
%
%     [cin, ceq] = rt2con(x, interpolator, data, sampleTimes)
%
%          cin: Closer to zero is better
%          ceq: Returns empty matrix []
%
%            x: the deconvolved RTD at sampleTimse
% interpolator: Deconvolution interpolation function handle
%         data: Matrix of concentration data, where the first column
%               is time, second column is upstream, and third column
%               is downstream concentration data
%  sampleTimes: The times at which the RTD will be calculated at (should
%               correspond to specific data points)

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

function [cin, ceq] = rt2con(x, interpolator, data, sampleTimes)

    if ~isreal(x) || ~isempty(find(x<0, 1))
        % in case something goes wrong, return a large value indicating
        % poor fit
        cin = 1E100;
    else
        % use the RTD to make a prediction
        newOutputT = interpolate(interpolator, x, data(:,1), data(:,2), sampleTimes);
        % check the prediction against the measured downstream
        % multiply by 1000 to work better with MATLAB optimisation defaults
        cin = (1 - rtSquared(data(:,3), newOutputT)) * 1000;
    end
    ceq = [];