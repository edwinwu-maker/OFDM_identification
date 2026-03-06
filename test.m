clear
clc
close all
%% parse parameter in env.json
json_content = parse_json("env.json");
%% generate OFDM (baseband) 
% TODO: move parameter to json
M = 64;      % Modulation order
osf = 2;     % Oversampling factor
nfft = 256;  % FFT length
cplen = 16;  % Cyclic prefix length

nullidx  = [1:6 nfft/2+1 nfft-5:nfft]';
numDataCarrs = nfft-length(nullidx);

x = randi([0 M-1],numDataCarrs,1);
qamSig = qammod(x,M,UnitAveragePower=true);
y = ofdmmod(qamSig,nfft,cplen,nullidx,OversamplingFactor=osf);

if json_content.IS_PLOT 
    figure; plot(abs(fftshift(fft(y))))
end
%% TODO:frequency offset

%% TODO:AWGN

%% cross-correlation
y_cp = y(1:48);
[c, lags] = xcorr(y(48:end), y_cp);
if json_content.IS_PLOT
    figure; stem(lags, abs(c))
end