function draw_plot(folder_path, base_file_name, set_file)
    eeglab;
    EEG = pop_loadset(set_file);

    % 定义通道和文件信息
    chs = [4, 5, 6, 8, 9, 10, 11, 12, 14, 24, 25, 26, 28, 27, 28, 29, 30, 32, 42, 45, 46, 47, 50, 59, 60, 61];
    chs_names = {EEG.chanlocs(chs).labels};
    % chs_human = containers.Map(...
    %     [4, 5, 6, 8, 9, 10, 11, 12, 14, 24, 25, 26, 28, 27, 28, 29, 30, 32, 42, 45, 46, 47, 50, 59, 60, 61], ...
    %     {'AF3', 'AF4', 'F7', 'F3', 'F1', 'FZ', 'F2', 'F4', 'F8', } ...
    % );
    chs_human = containers.Map(chs, chs_names);
    event_human = containers.Map( ...
        [1, 2, 3, 4], ...
        {'普通名词', '动作动词','典型事件名词','动名兼类事件名词'} ...
    );

    % 遍历每个通道
    for i = 1:length(chs)
        ch = chs(i);
        fig = figure('Position', [100, 100, 1000, 800], 'Visible', 'off'); % 设置图形大小
        
        % 遍历每个事件
        for event = 1:4
            % 构建文件名
            filename = fullfile(folder_path, sprintf('%s_csv_%d_ch%d_%s.csv', base_file_name, event, ch, EEG.chanlocs(ch).labels));
            
            % CSV文件打开
            fid = fopen(filename, 'r');
            if fid == -1
                error('无法打开文件: %s', filename);
            end
            
            % 读取整个文件内容
            fileContent = fgetl(fid);
            fclose(fid);
            
            % 分割字符串并转换为数值
            strValues = strsplit(fileContent, ',');
            Y = str2double(strValues);
            
            % 创建X轴数据
            X = linspace(-100, length(Y)-100, length(Y));
            
            % 绘图
            plot(X, Y, 'LineWidth', 1.5, 'DisplayName', sprintf('event %d: %s', event, event_human(event)));
            hold on;
        end
        
        % 增加：绘制更粗的X轴
        line(xlim, [0, 0], 'Color', 'k', 'LineWidth', 2, 'HandleVisibility', 'off');
        line([0, 0], ylim, 'Color', 'k', 'LineWidth', 2, 'HandleVisibility', 'off');

        % 添加图表元素
        title(sprintf('Plot of Average ERP at Channel %s', chs_human(ch)));
        xlabel('time (ms)');
        ylabel('Amplitude (μV)');
        legend('show');
        grid on;
        
        % 保存图像
        outputFilename = fullfile(folder_path, sprintf('%s_ch%d.png', base_file_name, ch));
        saveas(fig, outputFilename);
        % exportgraphics(fig, outputFilename, 'Resolution', 300); % R2020a以上可用，能以300DPI高清晰度保存
        close(fig); % 关闭图形
    end
    disp(['处理完成！图像已保存至 ', folder_path]);
end