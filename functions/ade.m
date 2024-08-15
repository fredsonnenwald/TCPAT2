% Make an concentration prediction using the routing solution to the
% Advection-Dispersion Equation (see Rutherford [1994] page 213-214)
%
%     out = ade(time, data, tbar, D, dt, v, [cutoff])
%
% time: matrix of times
% data: upstream data
% tbar: travel time
%    D: dispersion coeffecient
%   dt: timestep
%    v: velocity
% (optional) cutoff: ignore concentrations lower than this (default 1e-10)
%
% References
%
% Rutherford, J. C. (1994). River mixing. Chichester, England: John Wiley &
% Son Ltd.

% MIT License
% Copyright (c) 2013-2024 Fred Sonnenwald

function out = ade(time, data, tbar, D, dt, v, varargin)

    if nargin == 6
        cutoff = 1e-10;
    elseif nargin == 7
        cutoff = varargin{1};
    end

    % allocate for result (downstream concentration)
    out = zeros(size(data));

    % precompute constants
    fDb = 4 * D * tbar;
    vspf = v / sqrt(pi * fDb);
    v2 = v ^ 2;
    
    % for each upstream concentration measurements, calculate its
    % contribution to the downstream concentration and sum with all other
    % contributions
    for t=1:length(data)
        if data(t) > cutoff
            out = out + data(t) .* vspf .* exp(-(v2 * (tbar + time(t) - time) .^ 2) / fDb) * dt;
        end
    end
