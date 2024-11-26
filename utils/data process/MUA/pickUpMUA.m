function [mua_signal, fs_mua] = pickUpMUA(raw_signal, fs, band_cutoff, low_cutoff, smthWin, fd)
narginchk(2, 6);
if nargin < 3
    band_cutoff = [300, 6000]; 
end
if nargin < 4
    low_cutoff = 1000;
end
if nargin < 5
    smthWin = 1; % ms
end
if nargin < 6
    fd = 1000; 
end


% 设计带通滤波器（Butterworth滤波器，4阶）
% [b, a] = butter(4, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
% % 对原始信号进行带通滤波
% filtered_signal = filtfilt(b, a, raw_signal);
% % 对滤波后的信号进行全波整流（取绝对值）
% rectified_signal = abs(filtered_signal);

bpFilt = designfilt('bandpassfir','FilterOrder',100, ...
    'CutoffFrequency1',band_cutoff(1),'CutoffFrequency2',band_cutoff(2), ...
    'SampleRate', fs);

lpFilt = designfilt('lowpassfir','FilterOrder',50, ...
    'CutoffFrequency',low_cutoff, 'SampleRate',fs);
rectified_signal = filtfilt(lpFilt, abs(filtfilt(bpFilt, raw_signal)));

% 平滑处理（使用滑动平均滤波器）
% 定义平滑窗口大小（样本点数）
smooth_window = round(smthWin / 1000 * fs); % 例如，1毫秒窗口
% 创建滑动平均滤波器
smooth_filter = ones(1, smooth_window) / smooth_window;
% 对整流信号进行平滑
smoothed_signal = filtfilt(smooth_filter, 1, rectified_signal);

% 下采样处理（可选）
% 定义下采样因子
downsample_factor = round(fs/fd); % 例如，将采样率从30kHz降至1kHz
% 对平滑后的信号进行下采样
mua_signal = downsample(smoothed_signal, downsample_factor);
% 更新采样率
fs_mua = fs / downsample_factor;
clear raw_signal 
return
end