% Maximum entropy minimizer function for deconvolution, returns the entropy
% of the RTD sampled at points x

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

function [obj] = maxent(x)
    
    % The first point of an RTD is always 0
    x = [0 x];

    % Smooth to attempt to remove peaks/troughs from the signal - make it
    % more natural.
    m = zeros(1,length(x));
    m(1) = 0.5*(x(1)+x(2));
    for i=2:length(x)-1
        m(i) = 0.5*(x(i-1) + x(i+1));
    end
    m(end) =  0.5*(x(end-1)+x(end));

    smoothed_x = x./m;
    smoothed_x(smoothed_x == 0) = eps; % numerical shenanigans
    logx = log(smoothed_x);
    % Remember entropy = -sum(x log(x)) but we're after maximum, so *-1
    obj = sum(x.*logx);
