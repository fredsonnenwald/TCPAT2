% Find the least squares optimised aggregated dead zone alpha and time
% delay between upstream and downstream concentration distributions.
% Note, alpha = 1 / T, where T is the difference between travel time and
% time delay.
%
%     [params3, out, rt2] = optimizedadz(time, us, ds, dt, x0, [useold])
%
% params3: vector of [alpha time_delay]
%     out: predicted downstream concentration distribution
%     rt2: the RT2 goodness-of-fit between the downstream and prediction
%
%    time: matrix of times
%      us: upstream data
%      ds: downstream data
%      dt: the time step
%      x0: the optimisation initial guess as a vector [alpha time_delay]
% (optional) useold: when set to anything other than 0, use brute force
%          optimisation and try all possible time delays (no interpolation)

% MIT License
% Copyright (c) 2018-2024 Fred Sonnenwald

function [params3, out, rt2] = optimizedadz(time, us, ds, dt, x0, useold)
    
    % objective function for optimisation
    fun2 = @(x,xdata)adz(xdata, x(1), x(2), dt);
    
    % assume a reasonable initial guess if one isn't given
    if ~exist('x0', 'var') || isempty(x0)
        x0 = [0.05 10];
    end

    % by default use the faster lsqcurvefit optimisation
    if ~exist('useold', 'var')
        useold = 0;
    end


    if useold == 0
        
        % use lsqcurvefit with the updated adz function that interpolates
        % for non integer time delays
        % to account for the smallest time step (very small T) alpha may
        % need to be > 1, so account for that in the upper bound
        params3 = lsqcurvefit(fun2,x0,us,ds, [0 dt], [max([1/dt 1]) inf], optimset('Display', 'off'));
        out = fun2(params3, us);
        rt2 = rtSquared(ds, out);
        
    else
        
        % fall back to checking every possible integer time step to find
        % the optimal time delay and only optimise for alpha
        if length(x0) == 2
            x0 = x0(1);
        end
        
        % store the parameters for each time delay and its goodness-of-fit
        params2 = nan([1 length(time)])';
        gof = nan(size(params2))';

        if license('checkout','Distrib_Computing_Toolbox') == 1
            % check all time delays in parallel

            parfor delay=1:length(time)
                fun2b = @(x,xdata)fun2([x delay*dt], xdata);
                params2(delay) = lsqcurvefit(fun2b, x0, us, ds, [], [], optimset('Display', 'off'));

                out2 = fun2b(params2(delay), us);
                gof(delay) = rtSquared(ds, out2);
            end

        else % no parallel computing toolbox

            for delay=1:length(time)
                fun2b = @(x,xdata)fun2([x delay*dt], xdata);
                params2(delay) = lsqcurvefit(fun2b, x0, us, ds, [], [], optimset('Display', 'off'));

                out2 = fun2b(params2(delay), us);
                gof(delay) = rtSquared(ds, out2);
            end

        end % license

        % the best goodness-of-fit wins
        [~, k] = max(gof);
        params3 = [params2(k) k*dt];
        out = fun2(params3, us);
        rt2 = rtSquared(ds, out);
        
    end % useold
