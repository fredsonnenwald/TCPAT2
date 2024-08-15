% Check core functions are compatible with Octave

clear
addpath functions/

% Several packages are needed to work with GNU Octave, these are available
% from https://gnu-octave.github.io/packages/
% For Octave, uncomment the line below to load the needed packages
% pkg load statistics struct optim control signal
% To install the packages (run line by line)
% pkg install statistics
% pkg install struct
% pkg install optim
% pkg install control
% pkg install signal

%% Initialisation

% synthetic data
time = (0:150)';
us = normpdf(time, 20, 5);

% for deconvolution functions
samplePoints = 1:2:length(time);
sampleTimes = time(samplePoints);

% ade parameters
dist = 5;
U = 0.1;
tbar = dist / U;
Dx = 1e-2;

% adz parameters
alpha = 0.1;
T = 40;

%% Check ade()

ds = ade(time, us, tbar, Dx, 1, U);
clf
set(gcf, 'DefaultLineLineWidth', 1.2)
plot(time, [us ds])

%% Check adz()

ds_adz = adz(us, alpha, T, 1);
plot(time, [us ds_adz])
% clear ds2

%% Check TCPAT

% Not Octave compatible - GUI elements

%% Check nicedataloader

% Not Octave compatible - GUI elements

%% Check easydeconv()

[rtd, ds2] = easydeconv(time, us, ds, 20);
h = plot(time, [us ds ds2 rtd]);
set(h(3), 'LineStyle', '--')
clear rtd ds2

%% Check ifftfft()

rtd = ifftfft([time us ds], 1:length(time))';
ds2 = conv(us, rtd);
ds2 = ds2(1:length(us));
plot(time, [us ds ds2])
clear rtd ds2

%% Check interpolate()

rtd = ifftfft([time us ds], samplePoints);
[ds2, rtd2] = interpolate(@lin, rtd(2:end), time, us, sampleTimes);
plot(time, [us ds ds2 rtd2])
clear rtd rtd2 ds2

%% Check interpolatorWrapper()

rtd = ifftfft([time us ds], 1:length(time));
rtd = interpolatorWrapper(@lin, time, time(1:100), rtd(1:100), 100);
plot(time(1:100), rtd)
clear rtd rtd2 ds2

%% Check linearm()

% This is tough to check, so check using easydeconv() instead

%% Check lin()

rtd = ifftfft([time us ds], samplePoints)';
rtd = lin(time, sampleTimes, rtd);
plot(time, rtd)
clear rtd

%% Check linma()

rtd = ifftfft([time us ds], samplePoints)';
[~, t2] = max(rtd);
v = diff(samplePoints)';
if t2 ~= 1
    winmax = round(mean(v(t2-1:t2)));
else
    winmax = v(1);
end
rtd = linma(time, sampleTimes, rtd, 0.1, winmax);
plot(time, rtd)
clear rtd t2 v winmax

%% Check ma()

t = [0.2, 0.5, 1, 0.5, 0.2];
a = ma(t, 4);
plot(1:5, t, -3:9, a)
clear t a

%% Check maxent()

assert(maxent(rand(1,4)) > 0)

%% Check onepercentpeak()

[startU, endU, startD, endD] = onepercentpeak([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check onepercentpeakavg()

[startU, endU, startD, endD] = onepercentpeakavg([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check onepercentpeak2()

[startU, endU, startD, endD] = onepercentpeak2([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check optimiseade()

[params, pred] = optimiseade(time, us, ds, dist, [0.01 0.01]);
assert(abs(params(1) - Dx) < 1e-5)
assert(abs(params(2) - U) < 1e-5)
h = plot(time, [us ds pred]);
set(h(3), 'LineStyle', '--')
clear params pred

%% Check optimizedadz()

[params, pred] = optimizedadz(time, us, ds_adz, 1, [0.1 10]);
assert(abs(params(1) - alpha) < 1e-5)
assert(abs(params(2) - T) < 1e-3)
h = plot(time, [us ds_adz pred]);
set(h(3), 'LineStyle', '--')
clear params pred

%% Check optimize()

% This is tough to check, so check using easydeconv() instead

%% Check ronepercentpeak()

[startU, endU, startD, endD] = ronepercentpeak([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check rt2con()

ds2 = conv(us, us);
ds2 = ds2(1:size(us,1));
rt2con(us(samplePoints(2:end))', @lin, [time us ds2], time(samplePoints)')
clear ds2

%% Check rtenoneperpeak()

[startU, endU, startD, endD] = rtenoneperpeak([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check rtSquared()

rtSquared(us, us)
rtSquared(us, ds)
rtSquared(ds, ade(time, us, tbar, Dx, 1, U))

%% Check slopeBased3()

guess = ifftfft([time us ds], 1:length(time));
[~, sampleTimes] = slopeBased3([time us ds], 20);
plot(time, guess, '-', sampleTimes, ones(size(sampleTimes))*max(guess)/2, 'o')

clear guess sampleTimes

%% Check tenoneperpeak()

[startU, endU, startD, endD] = tenoneperpeak([time us ds]); %#ok<ASGLU>
clear startU endU startD endD

%% Check updateOutput()

% Not Octave compatible - GUI elements
