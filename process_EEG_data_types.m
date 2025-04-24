function process_EEG_data_types(input_path, output_path)
    % 初始化 EEGLAB
    eeglab;
    
    % 4种type，依次输出
    for type=1:4
        % 1. 从指定路径加载 dataset
        EEG = loadcurry(input_path, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');
    
        % 2. 去除未用到的通道
        channel_to_remove = [33,43,65:69]; % 需要移除的通道编号，33 - M1，43 - M2
        EEG = pop_select(EEG, 'channel', setdiff(1:size(EEG.data, 1), channel_to_remove));
    
        % 3. 使用 FIR 滤波器，1~30 Hz
        EEG = pop_eegfiltnew(EEG, 'locutoff', 5, 'hicutoff', 30);
    
        % 4. 设置 time-locking event, epoch limits = [0, 1]，提取事件
        epoch_limits = [-0.1 1]; % 时间范围 0 到 1 秒
        all_types = {'1','2','3','4'};
    
        event_type={};
        event_type{end+1} = all_types{type};
        disp(event_type);
        EEG = pop_epoch(EEG, event_type, epoch_limits);
    
        % 5. 对整个 epoch 做基线矫正
        baseline_range = [-100 0]; % 基线时间范围，[]=全部
        EEG = pop_rmbase(EEG, baseline_range);
    
        % 6. 用 extended-runica 算法完成 ICA
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'rndreset', 'yes');
    
        % 7. 用默认的 average reference 完成重参考
        EEG = pop_reref(EEG, []);
    
        % 8. 【弹窗】绘制全部通道的 Component maps
        pop_topoplot(EEG, 0);

        % 9. 绘制各成分波形的矩形阵列
        componentList = 1:size(EEG.icaweights,1);
        pop_plotdata(EEG, 0, componentList, [], 'Component ERPs', 0, 1, [0 0]);
    
        % 10. 【弹窗】Remove components from data
        EEG = pop_subcomp(EEG);
    
        % 11. 导出处理好的原始数据 set 格式
        % 先保存为 EEGLAB 的 .set 格式
        [~, input_file_name, ~] = fileparts(input_path);
        processed_filename = fullfile(output_path, sprintf('%s_%s_processed.set',input_file_name,event_type{1}));
        pop_saveset(EEG, 'filename', processed_filename);
    
        % 12. 按所需通道导出 ERP Image 和 Average ERP 原始数据
        channels_to_plot = []; % 需要绘制的通道索引列表
        % 
        for i = 1:length(channels_to_plot)
            channel_index = channels_to_plot(i);
            
            figure;
            erpimage( mean(EEG.data([channel_index], :),1), ones(1, EEG.trials)*EEG.xmax*1000, linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), EEG.chanlocs(channel_index).labels, 10, 1 ,'yerplabel','\muV','erp','on','cbar','on','topo', { [channel_index] EEG.chanlocs EEG.chaninfo } );
            
            data_for_channel = EEG.data(channel_index, :, :); % 结果是 [1000 × 60] 的矩阵
            average_ERP = mean(data_for_channel, 3); % 结果是 [1000 × 1] 的向量
            % time_vector包含从0到1000ms的所有秒数数据，默认不写入文件，需要放开注释
            % time_vector = (0:size(average_ERP, 2)-1) / EEG.srate; % 时间向量（秒）
            
            full_csv_path = fullfile(output_path, sprintf('%s_image_%s_ch%d.csv', input_file_name, event_type{1}, channel_index));
            writematrix(average_ERP, full_csv_path);
            disp(['通道 ', num2str(channel_index), ' 的 CSV 数据已保存至 ', full_csv_path]);
    
            % 保存图像为 PNG 文件
            full_image_path = fullfile(output_path, sprintf('%s_image_%s_ch%d.png', input_file_name, event_type{1}, channel_index));
            print('-dpng', full_image_path); % 保存为 PNG 格式
            disp(['通道 ', num2str(channel_index), ' 的 ERP 图像已保存至 ', full_image_path]);
        end

    end
    
    disp(['处理完成！数据已保存至 ', output_path]);
end