function tf_matrix = plotTimeFrequency(iq_data, rows, cols, plot_flag)
% PLOT_TIME_FREQUENCY 生成并绘制IQ数据的时频图
%   输入:
%       iq_data   - 复基带IQ数据，向量形式
%       rows      - 时频图的行数（频率点数），默认1024
%       cols      - 时频图的列数（时间帧数），默认2048
%       plot_flag - 是否绘制图像，true/false
%   输出:
%       tf_matrix - 大小为 rows × cols 的幅度谱矩阵

    % 设置默认参数
    if nargin < 2 || isempty(rows)
        rows = 1024;
    end
    if nargin < 3 || isempty(cols)
        cols = 2048;
    end
    if nargin < 4
        plot_flag = false;  % 默认不绘图
    end

    % 确保输入为列向量
    iq_data = iq_data(:);
    L = length(iq_data);
    nfft = rows;          % FFT点数等于行数
    num_frames = cols;    % 时间帧数

    % 如果信号长度小于一帧，则补零至一帧长度
    if L < nfft
        iq_data = [iq_data; zeros(nfft - L, 1)];
        L = nfft;
    end

    % 计算每帧的起始位置，使帧数恰好等于 num_frames
    % 起始位置在 [1, L-nfft+1] 范围内线性分布
    starts = round(linspace(1, L - nfft + 1, num_frames));

    % 初始化时频矩阵
    tf_matrix = zeros(nfft, num_frames);

    % 设计窗函数（汉宁窗，减少频谱泄露）
    window = hann(nfft);

    % 逐帧计算FFT
    for i = 1:num_frames
        idx = starts(i) : starts(i) + nfft - 1;
        frame = iq_data(idx) .* window;       % 加窗
        spectrum = fftshift(fft(frame, nfft));           % 做FFT
        tf_matrix(:, i) = abs(spectrum);       % 取幅度谱
    end

    % 如果需要绘图
    if ~plot_flag
        figure;
        % 使用imagesc显示时频图，通常将低频放在底部
        imagesc(1:num_frames, 0:nfft-1, 20*log10(tf_matrix.' + eps));
        axis xy;  % 使频率轴从低到高（0在底部）
        xlabel('时间帧');
        ylabel('频率索引');
        title('时频图 (幅度谱 dB)');
        colorbar;
        colormap jet;
    end
end