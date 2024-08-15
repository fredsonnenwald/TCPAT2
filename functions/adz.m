% Make an concentration prediction using the Aggregated Dead Zone
% model (see Rutherford [1994] page 223-229)
%
%     out = adz(data, alpha, delay, dt)
%
%  data: upstream data
% alpha: decay coefficient % was cell residence time
% delay: time delay
%    dt: timestep
%
% References
%
% Rutherford, J. C. (1994). River mixing. Chichester, England: John Wiley &
% Son Ltd.

% MIT License
% Copyright (c) 2013-2024 Fred Sonnenwald

function out = adz(data, alpha, delay, dt)

    if delay < dt
        % the delay cannot be less than the size of the timestep
        delay = dt;
    end

    % we can work in arbitrary time since time-step is the important part
    time = (1:length(data))*dt;
    % allocate for result (downstream concentration)
    out = zeros(size(data));

    % handle non-integer delay so that optimisation works
    delay2 = delay - floor(delay/dt)*dt;
    if delay2 ~= 0
        time2 = time + delay2;
        % shuffle the data by the fraction so that we can keep integer offsets
        % extrapolation could go poorly here, but as concentrations tend
        % to zero in practice this doesn't seem to explode
        data2 = interp1(time + delay2, data, time2, 'linear', 'extrap');
        delay = delay - delay2;
    else
        time2 = time;
        data2 = data;
    end

    offset = round(delay / dt);
    for i=offset+2:length(data)
        out(i) = exp(-alpha * dt) * out(i-1) + (1-exp(-alpha * dt))*data2(i-offset-1);
    end

    if delay2 ~= 0
        % put the data back onto the regular time
        out = interp1(time2, out, time, 'linear', 'extrap');
    end
    if (isrow(data) && ~isrow(out)) || (iscolumn(data) && ~iscolumn(out))
        % make sure out is the same dimension as the input data
        out = out';
    end
