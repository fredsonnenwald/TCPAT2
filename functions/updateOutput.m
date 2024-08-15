% Wrapper fucntion to link deconvolution progress to the axes on the TCPAT2
% application.
%
%     updateOutput(x, iterat, ~, app, interpolator, sampleTimes, time, upstream)
%
%            x: the current RTD at this point during optimisation
%       iterat: the current iterations during optimisation
%          app: TCPAT2 instance
% interpolator: Deconvolution interpolation function handle
%  sampleTimes: The times at which the RTD will be calculated at (should
%               correspond to specific data points)
%         time: Vector of times corresponding to the upstream data
%     upstream: Upstream concentration profile

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
% Copyright (c) 2020-2024 Fred Sonnenwald

function updateOutput(x, iterat, ~, app, interpolator, sampleTimes, time, upstream)
    
    % only update every 10 iterations
    if mod(iterat, 10) == 0
    
        [newOutputT, RTD] = interpolate(interpolator, x, time, upstream, sampleTimes);

        % update the graphics to show in progress output
        % this relies on the order of Children being consistent to the order lines are added
        yyaxis(app.DEDeconvAxes, 'left');
        app.DEDeconvAxes.Children(1).YData = RTD;
        yyaxis(app.DEDeconvAxes, 'right');
        app.DEDeconvAxes.Children(2).YData = cumsum(RTD);

        if length(app.dataaxes.Children) == 2
            h = line(app.dataaxes, app.dataaxes.Children(1).XData, newOutputT);
            set(h, 'Color', 'k');
            set(h, 'LineStyle', '--');
            legend(app.dataaxes, {'Upstream', 'Downstream', 'Deconvolution'})
        else
            app.dataaxes.Children(1).YData = newOutputT;
        end
    
        drawnow nocallbacks
    
    end
