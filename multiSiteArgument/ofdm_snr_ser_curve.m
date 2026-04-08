%% 该算法用于验证多站点协同增强算法能够提升信号信噪比
 % 以ofdm信号的信噪比-误码率来体现
clc
clear
close all
snrArray = linspace(-15, 10, 10); %dB
ser_awgn_array = zeros(1, size(snrArray, 2));
ser_recover_array = zeros(1, size(snrArray, 2));
for idx = 1:size(snrArray, 2)
    %% 生成基带OFDM
    M = 64;      % Modulation order
    osf = 1;     % Oversampling factor
    nfft = 256;  % FFT length
    cplen = 16;  % Cyclic prefix length
    
    nullidx  = [1:6 nfft/2+1 nfft-5:nfft]';
    numDataCarrs = nfft-length(nullidx);
    
    symbol = randi([0 M-1], numDataCarrs, 32);
    qam_sig = qammod(symbol, M,UnitAveragePower=true);
    baseband_ofdm = ofdmmod(qam_sig, nfft, cplen, nullidx, OversamplingFactor=osf).';
    % rx_qam_sig = ofdmdemod(baseband_ofdm.', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
    % rx_symbol = qamdemod(rx_qam_sig, M,UnitAveragePower=true);
    %% 生成多站点矩阵
    siteNumber = 2;     % 设定的站点数
    rcvMatrix = repmat(baseband_ofdm, siteNumber, 1);
    rcvMatrix(2,:) = circshift(rcvMatrix(2,:), 1000);
    %% 添加噪声
    signalPower = pow2db(mean(abs(rcvMatrix.').^2)); % dBW
    for i = 1:size(signalPower)
        rcvMatrix(i, :) = awgn(rcvMatrix(i, :), snrArray(idx), signalPower(i));
    end
    rcvMatrix = cross_correlation(rcvMatrix);
    %% 计算高斯白噪声下的误码数、误码率
    qam_sig_awgn = ofdmdemod(rcvMatrix(1, :).', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
    symbol_awgn = qamdemod(qam_sig_awgn, M,UnitAveragePower=true);
    [err_awgn, ser_awgn] = symerr(symbol, symbol_awgn);
    ser_awgn_array(idx) = ser_awgn;
    %% 多站点协同增强（协方差矩阵+奇异值分解+信号空间映射）
    N = size(rcvMatrix, 2); % 快拍数
    R = (rcvMatrix * rcvMatrix')./N;
    [U, S, V] = svd(R);
    recoverMatrixSVD = U(:, 1)*U(:, 1)'*rcvMatrix;
    qam_sig_recover = ofdmdemod(recoverMatrixSVD(1, :).', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
    symbol_recover = qamdemod(qam_sig_recover, M,UnitAveragePower=true);
    [err_recover, ser_recover] = symerr(symbol, symbol_recover);
    ser_recover_array(idx) = ser_recover;
end
%% 绘图
figure;
semilogy(snrArray, ser_recover_array, 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(snrArray, ser_awgn_array, 'r-*', 'LineWidth', 1.5);
grid on;
xlabel('snr (dB)');
ylabel('Symbols Error Ratio');
title('OFDM多站点协同误码率性能分析');
legend('多站点协同增强', '；单站点AWGN', 'Location', 'southwest');

figure;
plot(snrArray, ser_recover_array, 'b-o', 'LineWidth', 1.5);
hold on;
plot(snrArray, ser_awgn_array, 'r-*', 'LineWidth', 1.5);
grid on;
xlabel('snr (dB)');
ylabel('Symbols Error Ratio');
title('OFDM多站点协同误码率性能分析');
legend('多站点协同增强', '；单站点AWGN', 'Location', 'southwest');