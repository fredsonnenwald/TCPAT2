% Main function to pass options to and then run the deconvolution
%
%     [newOutput, RTD, exitflag, x, exception] = 
%     optimize(data, sampleTimes, ~, ~, ~, interpolator, guess, ~, output,
%     parallel, handles)
%
%    newOutput: The downstream prediction made using the deconvolved RTD
%          RTD: The deconvolved RTD
%     exitflag: Any error message in case of deconvolution failure
%            x: The RTD at the sampleTimes
%    exception: Any MATLAB exception that was raised during deconvolution
%
%         data: Matrix of concentration data, where the first column
%               is time, second column is upstream, and third column
%               is downstream concentration data
%  sampleTimes: The times at which the RTD will be calculated at (should
%               correspond to specific data points)
% interpolator: Deconvolution interpolation function handle
%        guess: An initial guess of the RTD
%       output: Set to 1 to regularly call the update function, set to 2 to
%               display output in the command window
%     parallel: Set 1 to use multiple CPU cores where able
%      handles: Anything to be passed to a call to the updateOutput
%               function

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

function [newOutput, RTD, exitflag, x, exception] = optimize(data, sampleTimes, ~, ~, ~, interpolator, guess, ~, output, parallel, handles)

    % RTD shouldn't go to zero, go to close
    ZEROISH = eps;

    % default 350 iterations for the optimisation
    iterations = 350;
    
    % make sure guess and sampleTimes are the correct shape
    if ~isrow(guess)
        guess = guess';
    end
    if ~isrow(sampleTimes)
        sampleTimes = sampleTimes';
    end
    try
        % verify the sampleTimes are valid
        arrayfun(@(x)find(x == data(:,1)), sampleTimes);
    catch ME
        causeException = MException('MATLAB:deconvolution:sampleTimes', ...
                          'sampleTimes not found in the time vector');
        rethrow(addCause(ME, causeException))
    end

    % Define the boundaries to the optimization problem.
    lb_amp = ones(1, length(guess))*ZEROISH;
    ub_amp = ones(1, length(guess))*1;
    % The first point of an RTD is always 0 so we only optimise the
    % following points
    lb = lb_amp(2:end);
    ub = ub_amp(2:end);
    
    exitflag = '';
    try
        % pass off to the linearm function for actual optimisation
        [x, exitflag] = linearm(@maxent, guess(2:end), lb, ub, @consWrapper, iterations, output, parallel, @updateWrapper);
        exception = '';
    catch exception
        % handle any errors nicely
        if strcmp(exitflag, '') == 1
	        exitflag = strcat(exception.message, ' - see console window.');
            x = guess(2:end); % strip off leading 0
        elseif strcmp(exitflag, 'Unknown exit condition.') == 1
            exitflag = strcat(exception.message, ' - see console window.');
        end
    end

    % Calculate the predicted downstream and final deconvolved RTD
    [newOutput, RTD] = interpolate(interpolator, x, data(:,1), data(:,2), sampleTimes);
    % Make the RTD matrix as long as the data matrix by padding with zeros
    l = find(data(:,1) == sampleTimes(end), 1);
    RTD(l+1:size(data,1)) = 0;

    % We need to wrap the call to the constraint function to prevent
    % problems with global variables when we do mass parallel processing.
    function [cin, ceq] = consWrapper(x)
        [cin, ceq] = rt2con(x, interpolator, data, sampleTimes);
    end

    % For GUI output updates during optimisation
    function updateWrapper(x, iterat)
        updateOutput(x, iterat, iterations, handles, interpolator, sampleTimes, data(:,1), data(:,2));
    end

end
