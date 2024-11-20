function createHeatMapWithClick()
    % 假设的x、y坐标和特征频率值
    x = [1, 2, 3, 4]; % x坐标
    y = [1, 2, 3, 4]; % y坐标
    frequency_values = magic(4); % 4x4的特征频率值矩阵，这里使用magic函数作为示例

    % 创建UI界面
    fig = uifigure('Name', '特征频率热度图');
    ax = axes(fig, 'Position', [0.1 0.1 0.8 0.8]); % 创建axes对象
    h = imagesc(ax, x, y, frequency_values); % 创建热度图
    colormap(ax, 'jet'); % 设置热度图的颜色映射
    colorbar(ax); % 显示颜色条

    % 设置点击事件处理
    h.ButtonDownFcn = @onHeatMapClick;

    % 这个函数处理点击事件，可以根据实际路径修改
    function onHeatMapClick(src, event)
        coords = round(event.IntersectionPoint(1:2)); % 获取点击位置的坐标
        disp(['你点击了: x=', num2str(coords(1)), ', y=', num2str(coords(2))]);
        % 根据点击的坐标，打开对应的结果图，这里需要根据实际情况修改路径
        imagePath = fullfile('你的路径', ['结果图_', num2str(coords(1)), '_', num2str(coords(2)), '.png']);
        if exist(imagePath, 'file')
            openfig(imagePath); % 打开图片
        else
            disp(['未找到图片: ', imagePath]);
        end
    end
end