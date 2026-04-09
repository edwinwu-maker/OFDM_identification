% 该脚本用于绘制不同信噪比下互相关的有效性曲线图
clc
clear
close all
snrArray = linspace(-15, 20, 10); %dB
correct_array = zeros(1, size(snrArray,2));
for idx = 1:size(snrArray,2)
    correct = 0;
    for i = 1:5000
        % 随机生成[0,7]的4096个点
        data = randi([0, 7], 1, 4096);
        % 随机移动点[0, 2048]
        shift_point = randi([0, 2048], 1, 1);
        % 对data进行移动(正整数为循环右移)
        shift_data = circshift(data, shift_point);
        % 加噪
        power_db = pow2db(mean(abs(shift_data).^2)); % dBW
        shift_data_noise = awgn(shift_data, snrArray(idx), power_db);
        data_noise = awgn(data, snrArray(idx), power_db);
        % 互相关
        [r, lags] = xcorr(data_noise, shift_data_noise);
        [~, max_idx] = max(r);
        predict_shift_point = lags(max_idx);
        % 如果(predict_shift_point+shift_point == 0)那就正确
        if(predict_shift_point+shift_point == 0)
            correct = correct+1;
        end
    end
    correct_array(idx) = correct/5000;
end
figure;
semilogy(snrArray, correct_array, 'b-o', 'LineWidth', 1.5);

figure;
plot(snrArray, correct_array, 'b-o', 'LineWidth', 1.5);