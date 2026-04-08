function [matrix_deplay_fix] = cross_correlation(matrix)
% matrix IQ矩阵，一行为一个站点的IQ信号
% matrix_deplay_fix 为时间补偿后的IQ矩阵
% 目前输入只能是2×n维的矩阵
    [r, lags] = xcorr(matrix.');
    r = r(:, 2:size(matrix, 1));
    [~, idx] = max(r);
    delay = lags(idx);
    matrix(2, :) = circshift(matrix(2, :), delay);
    matrix_deplay_fix = matrix;
end