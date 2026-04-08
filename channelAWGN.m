row = size(rcvMatrix, 1);
% 每个接收站点的信号功率（行向量）
signal_power = pow2db(mean(abs(rcvMatrix.').^2)); % dBW
for i = 1:row
    snr = -10;   % dB
    % rcvMatrix(i, :) = circshift(rcvMatrix(i, :), 0);
    rcvMatrix(i, :) = awgn(rcvMatrix(i, :), snr, signal_power(i));
end
qam_sig_awgn = ofdmdemod(rcvMatrix(1, :).', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
symbol_awgn = qamdemod(qam_sig_awgn, M,UnitAveragePower=true);
[err_awgn, ser_awgn] = symerr(symbol, symbol_awgn);