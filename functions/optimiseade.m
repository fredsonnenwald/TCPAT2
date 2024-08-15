% Find the least squares optimised dispersion coefficient and velocity
% between upstream and downstream concentration distributions.
%
%     [params, out, rt2] = optimiseade(time, us, ds, mydist, x0)
%
% params: vector of [dispersion velocity]
%    out: predicted downstream concentration distribution
%    rt2: the RT2 goodness-of-fit between the downstream and prediction
%
%   time: matrix of times
%     us: upstream data
%     ds: downstream data
% mydist: the distance between upstream and downstream monitoring locations
%     x0: the optimisation initial guess as a vector [dispersion velocity]

% MIT License
% Copyright (c) 2019-2024 Fred Sonnenwald

function [params, out, rt2] = optimiseade(time, us, ds, mydist, x0)

    OPTIONS_INNER = optimset('Display', 'off');
    dt = mean(diff(time));

    % objective function returning downstream prediction
    fun = @(x,xdata)ade(time, xdata, mydist/x(2), x(1), dt, x(2), 0);

    % minimise the errors between the measured downstream concentration and
    % the downstream prediction
    params = lsqcurvefit(fun, x0, us, ds, [0 0], [], OPTIONS_INNER);
    
    % return a final downstream prediction and its goodness-of-fit
    out = fun(params,us);
    rt2 = rtSquared(ds,out);
    
