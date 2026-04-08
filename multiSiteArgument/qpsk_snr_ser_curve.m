%% 该算法用于验证多站点协同增强算法能够提升信号信噪比
 % 以qpsk信号的信噪比-误码率来体现
clc
clear
close all
snrArray = linspace(-15, 10, 10); %dB
ser_awgn_array = zeros(1, size(snrArray, 2));
ser_recover_array = zeros(1, size(snrArray, 2));
for idx = 1:size(snrArray, 2)
    %% 生成基带QPSK
    M = 4;      % Modulation order
    symbol = randi([0 M-1], 10000, 1);
    qam_sig = qammod(symbol, M).';
    % rx_symbol = qamdemod(qam_sig, M);
    %% 生成多站点矩阵
    siteNumber = 2;     % 设定的站点数
    rcvMatrix = repmat(qam_sig, siteNumber, 1);
    %% 添加噪声
    signalPower = pow2db(mean(abs(rcvMatrix.').^2)); % dBW
    for i = 1:size(signalPower)
        rcvMatrix(i, :) = awgn(rcvMatrix(i, :), snrArray(idx), signalPower(i));
    end
    %% 计算高斯白噪声下的误码数、误码率
    symbol_awgn = qamdemod(rcvMatrix(1, :).', M);
    [err_awgn, ser_awgn] = symerr(symbol, symbol_awgn);
    ser_awgn_array(idx) = ser_awgn;
    %% 多站点协同增强（协方差矩阵+奇异值分解+信号空间映射）
    N = size(rcvMatrix, 2); % 快拍数
    R = (rcvMatrix * rcvMatrix')./N;
    [U, S, V] = svd(R);
    recoverMatrixSVD = U(:, 1)*U(:, 1)'*rcvMatrix;
    symbol_recover = qamdemod(recoverMatrixSVD(1, :).', M);
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
title('QPSK多站点协同误码率性能分析');
legend('多站点协同增强', '；单站点AWGN', 'Location', 'southwest');

figure;
plot(snrArray, ser_recover_array, 'b-o', 'LineWidth', 1.5);
hold on;
plot(snrArray, ser_awgn_array, 'r-*', 'LineWidth', 1.5);
grid on;
xlabel('snr (dB)');
ylabel('Symbols Error Ratio');
title('QPSK多站点协同误码率性能分析');
legend('多站点协同增强', '；单站点AWGN', 'Location', 'southwest');