% 测试信号：非高斯信号 + 高斯噪声
N = 1024;
x = rand(1,N);    % 均匀分布非高斯
x = x + 0.2*randn(1,N);

maxlag = 20;      % 延迟范围
[c3, lags2] = cumulant(x, 3, -maxlag:maxlag);  % 3阶累积量

% 绘图：3阶累积量 二维曲面/等高线
figure;
subplot(2,1,1);
plot(lags2, real(c3)); grid on;
title('3阶累积量 C3(m) 曲线');
xlabel('延迟 m'); ylabel('Cumulant_3');

subplot(2,1,2);
C3_mat = reshape(c3, 2*maxlag+1, 2*maxlag+1);
contourf(lags2, lags2, real(C3_mat), 30); colorbar;
title('3阶累积量 等高线图');
xlabel('m1'); ylabel('m2');