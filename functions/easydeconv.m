% Perform maximum entropy deconvolution on and upstream and downstream
% concentration profile to obtain the Residence Time Distribution (RTD)
% describing the transformation between the two.
%
%     [rtd, ds2] = easydeconv(time, us, ds, [noPoints])
%
%  rtd: The deconvolved residence time distribution (RTD)
%  ds2: A downstream prediction made using the deconvolved RTD
%
% time: Column vector of times at which concentration measurements were
%       made
%   us: Column vector of upstream concentration measurements
%   ds: Column vector of downstream concentration measurements
% (Optional) noPoints: The number of points to calculate the RTD at
%
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
% Copyright (c) 2018-2024 Fred Sonnenwald

function [rtd, ds2] = easydeconv(time, us, ds, noPoints)

    % Some functions require one big matrix of data. Creating this also
    % enforces that the input data are the same length and column vectors.
    rtddata = [time us ds];

    if ~exist('noPoints', 'var')
        noPoints = 20; % Total number of points
    end
    [samplePoints, sampleTimes] = slopeBased3(rtddata, noPoints);

    % Get an initial guess of the RTD to use as the starting point for
    % deconvolution
    guess = ifftfft(rtddata, samplePoints, sampleTimes);

    % Settings for the LAMA smoothing
    [~, t2] = max(guess);
    v = diff(samplePoints)';
    if t2 ~= 1
        winmax = round(mean(v(t2-1:t2)));
    else
        winmax = v(1);
    end
    % Choose the LAMA or Linear interpolators
    interpolator = @(a,b,c)linma(a,b,c,0.1,winmax);
    % interpolator = @lin;

    % Do the deconvolution
    fprintf('RTD Going... ');
    tic
    [ds2, rtd] = optimize(rtddata, sampleTimes, [], [], [], interpolator, guess, [], 0, 0, []);
    fprintf('done. (%0.1f s elapsed)\n', toc);
