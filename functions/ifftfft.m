% An initial guess at an RTD made using spectral analysis with
% Fourier transformations and windowing. This isn't the 'proper'
% way to do this, but it is a way that consistently gives a smooth
% sensible result as a starting point.
%
%     guess = ifftfft(data, samplePoints)
%
%         data: matrix of concentration data, where the first column
%               is time, second column is upstream, and third column
%               is downstream concentration data
% samplePoints: time indexes the guess will be returned at, set to
%               1:size(data,2) to get the guess at all times

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
% Copyright (c) 2012-2024 Fred Sonnenwald

function guess = ifftfft(data, samplePoints, ~)

    % The length of the data to process
    len = size(data, 1);
    
    % If it's too long it seems like it causes bad things to happen
    % with memory usage...
    scaleUp = 0;
    if len > 4000
        scaleUp = 1;
        
        scaleStep = 99;
        newlen = round(len/scaleStep);
        while newlen < 4000
            newlen = round(len/scaleStep);
            scaleStep = scaleStep - 1;
        end
        scaleStep = scaleStep + 2;
        
        upstream = data(1:scaleStep:len,2);
        downstream = data(1:scaleStep:len,3);
        len = size(upstream, 1);
    else
        upstream = data(:,2);
        downstream = data(:,3);
    end
    
    % Window the data to prevent leakage
    tenper = round(len/10);

    % cos((26:50)*pi/25) + 1 -> start of window
    % * 2 -> middle of window
    % cos((0:24)*pi/25) + 1 -> end of window
    
    usWindowed(1:tenper) = upstream(1:tenper) .* (cos((tenper+1:2*tenper)*pi/tenper) + 1)' ./ 2;
    usWindowed(tenper+1:len-tenper) = upstream(tenper+1:len-tenper);
    usWindowed(len-tenper+1:len) = upstream(len-tenper+1:len) .* (cos((0:tenper-1)*pi/tenper) + 1)' ./ 2;
    
    dsWindowed(1:tenper) = downstream(1:tenper) .* (cos((tenper+1:2*tenper)*pi/tenper) + 1)' ./ 2;
    dsWindowed(tenper+1:len-tenper) = downstream(tenper+1:len-tenper);
    dsWindowed(len-tenper+1:len) = downstream(len-tenper+1:len) .* (cos((0:tenper-1)*pi/tenper) + 1)' ./ 2;
    
    % Perform the FFT operations
    guess = ifft(fft(xcorr(usWindowed', dsWindowed'))/fft(xcorr(usWindowed', usWindowed')));
    % Normally this would be ifft((fft(ds).*fft(us))./(fft(us).*fft(us))),
    % but that can lead to excessive oscillations, so instead we use a less
    % accurate but more robust cross-correlation approach

    % We now have a huge matrix, one column of has what we want. (The one
    % with a big positive value). Find it.
    [~,i] = max(sum(real(guess)));
    
    % We can ignore the imaginary components, they're some aspect of gain/
    % phase/etc.
    guess = real(guess(:,i));
    guess = flipud(guess(1:len));
    
    % The data was too long - interpolate back up in size...
    if scaleUp == 1
        len = size(data, 1);
        guess = interp1(1:scaleStep:len, guess, 1:len)';
        % The lengths won't really match up, but the odds this isn't zero
        % any way are tiny. Plus as only a handful of points it shouldn't
        % make a huge difference anyway.
        guess(isnan(guess)) = 0;
    end
    
    % Perform the sampling on the guess.
    guess = rot90(guess(samplePoints));
    
    % Something's gone wrong with the fft and we've got a negative sum...
    if sum(guess) < 0
        guess = guess * -1;
    end

    % It's an RTD so enforce a sum to 1
    guess = guess ./ trapz(samplePoints, guess);