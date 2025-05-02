% 画图脚本，通过读取process_EEG_data_types.m产生的csv文件，作四种曲线叠加的曲线图

% 清空环境
close all;
clear;

DATA_DIR = 'liqing-fm-250105';

% 设置路径和参数
dataFolder = ['D:\SHU\Senior\Courses\Bishe\processed\' DATA_DIR '\plots'];    % 数据文件夹路径
outputFolder = ['D:\SHU\Senior\Courses\Bishe\processed\' DATA_DIR '\plots'];

% 获取所有csv文件信息
file_info = dir(fullfile(dataFolder, './*.csv'));

% 初始化部分参数
colors = get(gca, 'ColorOrder');
word_class = {'普通名词', '动作动词', '典型事件名词', '动名兼类事件名词'};
time = -100:999; 

% 循环处理数据文件
for i = 1:25
    
    % 创建图像
    fig = figure('Position', [100, 100, 1000, 800], 'Visible', 'off');

    for j = 1:4             
        
        % 构建文件名
        file_num = 25*(j-1)+i;
        file = fullfile(dataFolder, file_info(file_num).name);
        data = csvread(file);
        
        % 绘制曲线
        plot(time, data, ...
            'LineWidth', 1.9, ...
            'Color', colors(j,:), ...
            'DisplayName', [num2str(j), word_class{j}]);
        hold on;
        
    end
    
    % 增加：绘制更粗的X轴
    xlim([-100 1000]);
    line(xlim, [0, 0], 'Color', 'k', 'LineWidth', 2, 'HandleVisibility', 'off');
    line([0, 0], ylim, 'Color', 'k', 'LineWidth', 2, 'HandleVisibility', 'off');
    
    % 提取位置名
    temp = split(file, '_');
    chan = split(temp(length(temp)), '.');

    % 添加图表元素
    title(sprintf('Plot of Average ERP at Channel %s', chan{1}));
    xlabel('time (ms)');
    ylabel('Amplitude (μV)');
    legend('show');
    grid on;
    
    % 保存图像
    outputFilename = fullfile(outputFolder, sprintf('%s_ch%s.png', DATA_DIR, chan{1}));
    saveas(fig, fullfile(outputFolder, sprintf('%s_ch%s.fig', DATA_DIR, chan{1})))
    saveas(fig, outputFilename);
    % exportgraphics(fig, outputFilename, 'Resolution', 300); % R2020a以上可用，能以300DPI高清晰度保存
    close(fig); % 关闭图形

end
