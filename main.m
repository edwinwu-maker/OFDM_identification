clear
clc
close all
%% parse parameter in env.json
environment = parseJson("env.json");
%% generate OFDM (baseband) 
generateOFDM;   % 调用generateOFDM.m
if environment.IS_PLOT
    figure; plot(abs(fftshift(fft(baseband_ofdm))))
    title("baseband OFDM Spectrum")
end
%% multi-reveicer matrix
rcvMatrix = repmat(baseband_ofdm, 3, 1);
%% AWGN
channelAWGN;    % 调用channelAWGN.m
if environment.IS_PLOT
    figure; plot(abs(fftshift(fft(rcvMatrix(3, :)))))
    title("(OFDM + Gaussian Noise) spectrum")
    ylim([0, 18]);
end
%% 协方差矩阵
N = size(rcvMatrix, 2); % 快拍数
R = (rcvMatrix * rcvMatrix')./N;
%% 特征值分解
[vector, langda] = eig(R); 
d = diag(langda);
[~, idx] = sort(d, 'descend');  % idx 是按特征值降序排列的索引
vectorSorted = vector(:, idx);      % 特征向量按特征值从大到小排列
langdaSorted = langda(idx, idx);    % 特征值对角矩阵也按相同顺序排列
recoverMatrixED = vectorSorted(:,1)*vectorSorted(:,1)'*rcvMatrix;
if environment.IS_PLOT
    figure; plot(abs(fftshift(fft(recoverMatrixED(3, :)))))
    title("(OFDM + Gaussian Noise) ED recover spectrum")
    ylim([0, 18]);
end
%% 奇异值分解
[U, S, V] = svd(R);
recoverMatrixSVD = U(:, 1)*U(:, 1)'*rcvMatrix;
if environment.IS_PLOT
    figure; plot(abs(fftshift(fft(recoverMatrixSVD(3, :)))))
    title("(OFDM + Gaussian Noise) SVD recover spectrum")
    ylim([0, 18]);
end
qam_sig_recover = ofdmdemod(recoverMatrixSVD(1, :).', nfft, cplen, 0,nullidx, OversamplingFactor=osf);
symbol_recover = qamdemod(qam_sig_recover, M,UnitAveragePower=true);
[err_recover, ser_recover] = symerr(symbol, symbol_recover);