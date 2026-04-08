
%% generate OFDM (baseband) 
% TODO: move parameter to json
M = 64;      % Modulation order
osf = 1;     % Oversampling factor
nfft = 256;  % FFT length
cplen = 16;  % Cyclic prefix length

nullidx  = [1:6 nfft/2+1 nfft-5:nfft]';
numDataCarrs = nfft-length(nullidx);

symbol = randi([0 M-1],numDataCarrs,8);
qam_sig = qammod(symbol, M,UnitAveragePower=true);
baseband_ofdm = ofdmmod(qam_sig, nfft, cplen, nullidx, OversamplingFactor=osf).';
% rx_qam_sig = ofdmdemod(baseband_ofdm.', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
% rx_symbol = qamdemod(rx_qam_sig, M,UnitAveragePower=true);