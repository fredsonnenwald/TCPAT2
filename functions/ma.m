% Calculate a moving average. If the input is a 2D matrix, calculate the
% moving average long ways. Note the returned averaged result is larger
% than the input data to include the window spilling over the edges of the
% data.
%
%     averaged = ma(runoff, [span])
%
% averaged: the padded moving average result
%
%   runoff: the data to calculate the moving average of
%     span: half the size of the moving average, i.e., this is the number of
%           points to either side of the current value (defaults to 15)

% MIT License
% Copyright (c) 2012-2024 Fred Sonnenwald

function averaged = ma(runoff, span)

    if exist('span', 'var') == 0
        span = 15;
    elseif isempty(span)
        error('span cannot be empty!')
    elseif ~isscalar(span)
        error('span must be scalar')
    end
        
    [a, b] = size(runoff);
    if ~(a == 1 || b == 1)

        % Recurse and calculate the moving average column by column or row
        % by row, the opposite of whichever dimension is largest
        if a > b
            averaged = zeros(a + span * 2, b);
            for ii=1:b
                averaged(:, ii) = ma(runoff(:,ii), span);
            end
        else
            averaged = zeros(a, b + span * 2);
            for ii=1:a
                averaged(ii, :) = ma(runoff(ii,:), span);
            end
        end

    else

        % Use the built-in moving average function instead of our own code
        if exist('movmean', 'builtin')

            % To match the behaviour of the original fall back routine the
            % data needs to be padded out
            if isrow(runoff)
                paddeddata = [zeros(1,span) runoff zeros(1,span)];
            else
                paddeddata = [zeros(span,1); runoff; zeros(span,1)];
            end
            averaged = movmean(paddeddata, span*2-1);

        else

            % Use our own internal moving average function if Matlab's
            % built-in one is not available
            averaged = meat(runoff, span);

        end
        
    end

    % Built-in fallback moving function for MATLAB versions earlier than
    % R2016a (this code was originally written for R2011a)
    function a = meat(r, s)

        if length(r) == size(r, 1)
            r = [zeros(s, 1); r; zeros(s, 1)];
        else
            r = [zeros(1, s) r zeros(1, s)];
        end
        a = zeros(size(r));
        
        for jj=1:s-1
            a(jj) = mean(r(1:jj+s-1));
        end

        for jj=s:length(r)-s
            a(jj) = mean(r(jj-s+1:jj+s-1));
        end

        for jj=length(r)-s+1:length(r)
            a(jj) = mean(r(jj-s+1:end));
        end

    end

end

