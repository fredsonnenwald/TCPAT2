% Configure and run fmincon to solve the maximum entropy deconvolution for
% concentration data problem.
%
%    [x, exitflag] = linearm(minimizer, guess, lb, ub, constraint,
%                            iterations, output, parallel, updateWrapper)
%
%             x: the deconvolved RTD at specific sample points
%      exitflag: information about the return state of fmincon
%
%     minimizer: the objective optimisation function
%         guess: the initial guess of the RTD at specific sample points
%            lb: lower bound limits on the RTD
%            ub: upper bound limits on the RTD
%    constraint: non-linear constraint function for the optimisation
%    iterations: the number of iterations to attempt to optimise for
%        output: set to 1 to regularly call the update function, set to 2
%                to display output in the command window
%      parallel: set 1 to use multiple CPU cores where able
% updateWrapper: update function handle

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

function [x, exitflag] = linearm(minimizer, guess, lb, ub, constraint, iterations, output, parallel, updateWrapper)

    % Set the optimisation options
    OPTIONS_INNER = optimset('Display', 'off');
    OPTIONS_INNER = optimset(OPTIONS_INNER, 'Algorithm', 'active-set');
    if parallel == 1
        OPTIONS_INNER = optimset(OPTIONS_INNER, 'UseParallel', 'always');
    else
        OPTIONS_INNER = optimset(OPTIONS_INNER, 'UseParallel', 'never');
    end
    OPTIONS_INNER = optimset(OPTIONS_INNER, 'MaxIter', iterations);
    OPTIONS_INNER = optimset(OPTIONS_INNER, 'MaxFunEvals', iterations*10000);
    if output == 1
        OPTIONS_INNER = optimset(OPTIONS_INNER, 'OutputFcn', @update);
    elseif output == 2 % Console output
        OPTIONS_INNER = optimset(OPTIONS_INNER, 'Display', 'iter');
    end

    % Enforce initial guess within constraints
    guess(guess > ub) = ub(guess > ub);
    guess(guess < lb) = ub(guess < lb);

    % Do the optimisation
    [x,~,exitflag] = fmincon(minimizer, guess, [], [], [], [], lb, ub, constraint, OPTIONS_INNER);
    
    % Convert the numeric exitflag to text so that we can inform the user
    % of what goes on...
    switch exitflag
        case 1
            exitflag = 'First-order optimality measure was less than options.TolFun, and maximum constraint violation was less than options.TolCon.';
        case 0
            exitflag = 'Number of iterations exceeded options.MaxIter or number of function evaluations exceeded options.FunEvals.';
        case -1
            exitflag = 'The output function terminated the algorithm.';
        case -2
            exitflag = 'No feasible point was found.';
        case 2
            exitflag = 'Change in x was less than options.TolX and maximum constraint violation was less than options.TolCon.';
        case 3
            exitflag = 'Change in the objective function value was less than options.TolFun and maximum constraint violation was less than options.TolCon.';
        case 4
            exitflag = 'Magnitude of the search direction was less than 2*options.TolX and maximum constraint violation was less than options.TolCon.';
        case 5
            exitflag = 'Magnitude of directional derivative in search direction was less than 2*options.TolFun and maximum constraint violation was less than options.TolCon.';
        case -3
            exitflag = 'Current point x went below options.ObjectiveLimit and maximum constraint violation was less than options.TolCon.';
        otherwise
            exitflag = 'Unknown exit condition.';
            warning(exitflag)
    end
    
    % Wrapper function for the wrapper function to output status
    function stop = update(x, optimvalues, state)
        
        global doStop; %#ok<GVMIS>
        stop = doStop;
        
        if isempty(stop)
            stop = 0;
        end
        
        if strcmp(state, 'iter') == 1
            updateWrapper(x, optimvalues.iteration)
        end

    end
end
