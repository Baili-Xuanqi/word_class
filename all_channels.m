% Note: This file contains countless problems. Solving is pended. USE AT YOUR OWN RISK.

% 清空环境
close all;
clear;

eeglab;

% 设置路径和参数
dataFolder = 'D:\python\mne\250331-1'; % 数据文件夹路径
outputFolder = 'D:\python\mne\250331-1\250331-1-plots';    % 输出文件夹路径

% 确保输出文件夹存在
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 定义匹配模式
filePattern = fullfile(dataFolder, '*_processed.set'); % 匹配 .set 文件
dataFiles = dir(filePattern); % 获取所有符合条件的 .set 文件

% 遍历每个 .set 文件
for i = 1:length(dataFiles)
    % 获取文件名（去掉扩展名）
    [~, name, ~] = fileparts(dataFiles(i).name);
    
    % 提取原始数据名和事件类型
    parts = split(name, '_');
    baseName = parts{1}; % 原始数据名
    eventType = parts{2}; % 事件类型
    disp([baseName, ' ', eventType])
    
    % 加载 .set 文件
    setFilePath = fullfile(dataFiles(i).folder, dataFiles(i).name);
    EEG = pop_loadset(setFilePath); % 加载 EEG 数据
    
    % 获取通道数量
    % numChannels = length(EEG.chanlocs);

    channels_to_plot = [4, 5, 6, 8, 9, 10, 11, 12, 14, 24, 25, 26, 28, 27, 28, 29, 30, 32, 42, 45, 46, 47, 50, 59, 60, 61];
    chs_names = {EEG.chanlocs(channels_to_plot).labels};

    % 遍历每个通道
    for j = 1:length(channels_to_plot)
        channel_index = channels_to_plot(j);
        disp(channel_index)

        % 创建不可见图形窗口
        fig = figure('Visible', 'off');
        
        % 绘制 erpimage
        erpimage( mean(EEG.data([channel_index], :),1), ones(1, EEG.trials)*EEG.xmax*1000, linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), chs_names{j}, 10, 1 ,'yerplabel','\muV','erp','on','cbar','on','topo', { [channel_index] EEG.chanlocs EEG.chaninfo } );
        pause(2);
        
        % 保存 erpimage 图片
        imgFileName = sprintf('%s_img_%s_ch%d_%s.png', baseName, eventType, channel_index, chs_names{j});
        imgFilePath = fullfile(outputFolder, imgFileName);
        print(fig, '-dpng', imgFilePath);
        
        figFilePath = fullfile(outputFolder, sprintf('%s_fig_%s_ch%d_%s.fig', baseName, eventType, channel_index, chs_names{j}));
        savefig(fig, figFilePath);
        
        % 关闭图形窗口
        close(fig);
        
        % 导出原始数据为 CSV 文件
        data_for_channel = EEG.data(channel_index, :, :); % 结果是 [1000 × 60] 的矩阵
        average_ERP = mean(data_for_channel, 3); % 结果是 [1000 × 1] 的向量

        % 保存 CSV 文件
        csvFilePath = fullfile(outputFolder, sprintf('%s_csv_%s_ch%d_%s.csv', baseName, eventType, channel_index, EEG.chanlocs(channel_index).labels));
        writematrix(average_ERP, csvFilePath);
    end
    
    % 清理内存
    clear EEG;
end

disp('处理完成！');
