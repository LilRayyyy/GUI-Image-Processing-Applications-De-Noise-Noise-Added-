function image_processing_app
    % 创建主界面
    fig = figure('Name', '图像处理应用程序', 'NumberTitle', 'off', 'MenuBar', 'none', 'Position', [100, 100, 1200, 700]);

    % 文件菜单
    fileMenu = uimenu('Parent', fig, 'Label', '文件');
    uimenu('Parent', fileMenu, 'Label', '打开', 'Callback', @openImageCallback);
    uimenu('Parent', fileMenu, 'Label', '保存', 'Callback', @saveImageCallback);
    uimenu('Parent', fileMenu, 'Label', '另存为', 'Callback', @saveAsImageCallback);
    uimenu('Parent', fileMenu, 'Label', '退出', 'Callback', @(~, ~) close(fig));

    % 帮助菜单
    helpMenu = uimenu('Parent', fig, 'Label', '帮助');
    uimenu('Parent', helpMenu, 'Label', '关于系统', 'Callback', @aboutCallback);

    % 原始图像和处理后的图像显示区域
    hAxesOriginal = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.05, 0.55, 0.25, 0.35]);
    title(hAxesOriginal, '原始图像');
    hAxesNoisy = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.375, 0.55, 0.25, 0.35]);
    title(hAxesNoisy, '含噪图像');
    hAxesProcessed = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.7, 0.55, 0.25, 0.35]);
    title(hAxesProcessed, '去噪后的图像');

    % 噪声类型按钮组
    noisePanel = uibuttongroup('Parent', fig, 'Title', '噪声类型', 'Units', 'normalized', 'Position', [0.05, 0.3, 0.2, 0.2],'FontSize', 12);
    uicontrol('Parent', noisePanel, 'Style', 'radiobutton', 'String', '高斯白噪声', 'Position', [10, 60, 150, 20],'FontSize', 12);
    uicontrol('Parent', noisePanel, 'Style', 'radiobutton', 'String', '椒盐噪声', 'Position', [10, 40, 150, 20],'FontSize', 12);
    uicontrol('Parent', noisePanel, 'Style', 'radiobutton', 'String', '散斑噪声', 'Position', [10, 20, 150, 20],'FontSize', 12);

    % 噪声强度
    uicontrol('Parent', fig, 'Style', 'text', 'String', '噪声强度', 'Units', 'normalized', 'Position', [0.05, 0.25, 0.1, 0.05],'FontSize', 12);
    noiseIntensitySlider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', 0.1, 'Units', 'normalized', 'Position', [0.15, 0.25, 0.15, 0.05], 'SliderStep', [0.01 0.1]);

    % 添加刻度标签
    uicontrol('Parent', fig, 'Style', 'text', 'String', '0%', 'Units', 'normalized', 'Position', [0.14, 0.3, 0.03, 0.02]);
    uicontrol('Parent', fig, 'Style', 'text', 'String', '50%', 'Units', 'normalized', 'Position', [0.21, 0.3, 0.03, 0.02]);
    uicontrol('Parent', fig, 'Style', 'text', 'String', '100%', 'Units', 'normalized', 'Position', [0.28, 0.3, 0.04, 0.02]);

    % 去噪滤波按钮组
    denoisePanel = uibuttongroup('Parent', fig, 'Title', '去噪滤波算法', 'Units', 'normalized', 'Position', [0.35, 0.3, 0.25, 0.2],'FontSize', 12);
    uicontrol('Parent', denoisePanel, 'Style', 'radiobutton', 'String', '中值滤波', 'Position', [10, 80, 150, 20],'FontSize', 12);
    uicontrol('Parent', denoisePanel, 'Style', 'radiobutton', 'String', '均值滤波', 'Position', [10, 60, 150, 20],'FontSize', 12);
    uicontrol('Parent', denoisePanel, 'Style', 'radiobutton', 'String', '形态学滤波', 'Position', [10, 40, 150, 20],'FontSize', 12);
    uicontrol('Parent', denoisePanel, 'Style', 'radiobutton', 'String', '小波变换', 'Position', [10, 20, 150, 20],'FontSize', 12);
    uicontrol('Parent', denoisePanel, 'Style', 'radiobutton', 'String', '维纳滤波', 'Position', [10, 0, 150, 20],'FontSize', 12);

    % 性能参数选择面板
    metricPanel = uibuttongroup('Parent', fig, 'Title', '性能参数', 'Units', 'normalized', 'Position', [0.65, 0.3, 0.25, 0.2],'FontSize', 11);
    uicontrol('Parent', metricPanel, 'Style', 'checkbox', 'String', '均方误差 (MSE)', 'Position', [10, 60, 150, 20],'FontSize', 11);
    uicontrol('Parent', metricPanel, 'Style', 'checkbox', 'String', '峰值信噪比 (PSNR)', 'Position', [10, 40, 150, 20],'FontSize', 11);
    uicontrol('Parent', metricPanel, 'Style', 'checkbox', 'String', '相关系数', 'Position', [10, 20, 150, 20],'FontSize', 11);
    uicontrol('Parent', metricPanel, 'Style', 'checkbox', 'String', '等效视数 (ENL)', 'Position', [10, 0, 150, 20],'FontSize', 11);

    % 添加查看性能参数信息按钮
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '查看性能参数信息', 'Units', 'normalized', 'Position', [0.8, 0.38, 0.14, 0.05], 'FontSize', 12, 'Callback', @viewMetricsInfo);

    % 按钮
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '添加噪声', 'Units', 'normalized', 'Position', [0.05, 0.15, 0.1, 0.05], 'Callback', @addNoiseCallback);
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '去噪', 'Units', 'normalized', 'Position', [0.35, 0.15, 0.1, 0.05], 'Callback', @denoiseCallback);
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '计算性能参数', 'Units', 'normalized', 'Position', [0.65, 0.15, 0.15, 0.05], 'Callback', @calculateMetricsCallback);

    % 文件操作的相关变量
    originalImage = []; %该变量用于存储用户打开的原始图像
    noisyImage = []; %该变量用于存储添加噪声后的图像
    denoisedImage = []; %该变量用于存储去噪处理后的图像


    % 打开图像的回调函数
    function openImageCallback(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.webp', '图像文件'}, '选择图像文件');
        if file == 0 %检查用户是否取消了文件选择对话框。如果用户取消了操作，uigetfile 将返回 0
            return; % 用户取消了操作
        end
        [~, ~, ext] = fileparts(file);
        %%若为webp属性的图像，则有以下代码
        if strcmp(ext, '.webp')
            originalImage = imreadwebp(fullfile(path, file)); %如果是 .webp 文件，使用 imreadwebp 函数读取图像，并将其存储在 originalImage 变量中
        else
            originalImage = imread(fullfile(path, file));
        end
        imshow(originalImage, 'Parent', hAxesOriginal); %使用 imshow 函数在指定的坐标轴 hAxesOriginal 中显示读取的原始图像
    end

    % 保存图像的回调函数
    function saveImageCallback(~, ~)
        if isempty(denoisedImage)
            msgbox('请先进行去噪处理。', '警告', 'warn');
            return;
        end
        imwrite(denoisedImage, 'output.png'); % 调用 imwrite 函数将变量 denoisedImage 中的图像数据保存为文件 output.png
        msgbox('图像已保存为output.png', '提示', 'help');
    end

    % 另存为图像的回调函数
    function saveAsImageCallback(~, ~)
        if isempty(denoisedImage)
            msgbox('请先进行去噪处理。', '警告', 'warn');
            return;
        end
        [file, path] = uiputfile({'*.png', 'PNG图像'}, '另存为'); %调用 uiputfile 函数打开一个文件保存对话框，让用户选择保存图像的文件名和路径
        if file == 0
            return; % 用户取消了操作
        end
        imwrite(denoisedImage, fullfile(path, file)); % 调用 imwrite 函数将变量 denoisedImage 中的图像数据保存为用户指定的文件 使用 fullfile 函数构建完整的文件路径，该路径由用户选择的文件夹路径 path 和文件名 file 组成
        msgbox(['图像已保存为 ' fullfile(path, file)], '提示', 'help');
    end

    % 关于系统的回调函数
    function aboutCallback(~, ~)
        msgbox('这是一个MATLAB图像处理应用程序，允许用户对图像进行加噪和去噪处理。', '关于系统', 'help');
    end

    % 添加噪声的回调函数
    function addNoiseCallback(~, ~)
        if isempty(originalImage)
            msgbox('请先打开图像。', '警告', 'warn');
            return;
        end

        % 获取选择的噪声类型和强度
        selectedNoiseButton = get(noisePanel, 'SelectedObject'); %获取 noisePanel 中被选中的单选按钮对象，并将其存储在 selectedNoiseButton 变量中
        if isempty(selectedNoiseButton)
            msgbox('请先选择噪声类型。', '警告', 'warn');
            return;
        end
        selectedNoise = get(selectedNoiseButton, 'String'); %获取被选中的单选按钮的文本（噪声类型），并将其存储在 selectedNoise 变量中
        noiseIntensity = noiseIntensitySlider.Value; %获取滑块控件 noiseIntensitySlider 的当前值（噪声强度），并将其存储在 noiseIntensity 变量中

        switch selectedNoise
            case '高斯白噪声'
                noisyImage = imnoise(originalImage, 'gaussian', 0, noiseIntensity); %imnoise 函数在 originalImage 上添加高斯白噪声，噪声强度由 noiseIntensity 控制，结果存储在 noisyImage 变量中
            case '椒盐噪声'
                noisyImage = imnoise(originalImage, 'salt & pepper', noiseIntensity); %imnoise 函数在 originalImage 上添加椒盐噪声，噪声强度由 noiseIntensity 控制，结果存储在 noisyImage 变量中
            case '散斑噪声'
                noisyImage = imnoise(originalImage, 'speckle', noiseIntensity); %imnoise 函数在 originalImage 上添加散斑噪声，噪声强度由 noiseIntensity 控制，结果存储在 noisyImage 变量中
        end
        
        imshow(noisyImage, 'Parent', hAxesNoisy); % 显示含噪图像
    end

    % 去噪的回调函数
    function denoiseCallback(~, ~)
        if isempty(noisyImage)
            msgbox('请先添加噪声。', '警告', 'warn');
            return;
        end

        selectedDenoiseButton = get(denoisePanel, 'SelectedObject');
        if isempty(selectedDenoiseButton)
            msgbox('请先选择去噪滤波算法。', '警告', 'warn');
            return;
        end
        selectedDenoise = get(selectedDenoiseButton, 'String'); %获取被选中的单选按钮的文本（去噪滤波算法），并将其存储在 selectedDenoise 变量中

        switch selectedDenoise %根据 selectedDenoise 的值，选择对应的代码块执行
            case '中值滤波'
                denoisedImage = medfilt2(im2gray(noisyImage), [3 3]); %使用 medfilt2 函数对灰度图像 noisyImage 进行 3x3 窗口的中值滤波，结果存储在 denoisedImage 变量中
            case '均值滤波'
                h = fspecial('average', [3 3]);  %h = fspecial('average', [3 3])：创建一个 3x3 的均值滤波器'h'
                denoisedImage = imfilter(im2gray(noisyImage), h); %denoisedImage = imfilter(im2gray(noisyImage), h)：使用 imfilter 函数对灰度图像 noisyImage 进行均值滤波，结果存储在 denoisedImage 变量中
            case '形态学滤波' 
                se = strel('disk', 2); %创建一个半径为 2 的圆盘形结构元素 se
                denoisedImage = imclose(imopen(im2gray(noisyImage), se), se); %使用 imopen 和 imclose 函数对灰度图像 noisyImage 进行形态学开运算和闭运算，结果存储在 denoisedImage 变量中
            case '小波变换'
                grayNoisy = im2gray(noisyImage); %将含噪图像 noisyImage 转换为灰度图像 grayNoisy
                [c, s] = wavedec2(grayNoisy, 2, 'db1'); %使用 wavedec2 函数对灰度图像 grayNoisy 进行 2 层小波分解，使用 'db1' 小波基，结果存储在 c 和 s 变量中
                thr = 0.2; %设置阈值 thr 为 0.2
                denoisedC = wthresh(c, 's', thr); %使用 wthresh 函数对小波系数 c 进行软阈值处理，结果存储在 denoisedC 变量中
                denoisedImage = waverec2(denoisedC, s, 'db1'); %使用 waverec2 函数对处理后的小波系数 denoisedC 进行二维小波重构，结果存储在 denoisedImage 变量中
            case '维纳滤波'
                denoisedImage = wiener2(im2gray(noisyImage), [5 5]); %使用 wiener2 函数对灰度图像 noisyImage 进行 5x5 窗口的维纳滤波，结果存储在 denoisedImage 变量中
        end
        
        imshow(denoisedImage, 'Parent', hAxesProcessed); % 显示去噪后的图像
    end

    % 计算性能参数的回调函数
    function calculateMetricsCallback(~, ~)
        if isempty(originalImage) || isempty(noisyImage) || isempty(denoisedImage)
            msgbox('请先完成加噪和去噪处理。', '警告', 'warn');
            return;
        end
        
        % 将图像转换为灰度图像
        grayOriginal = im2gray(originalImage); %调用 im2gray 函数将 originalImage 转换为灰度图像，并将结果存储在变量 grayOriginal 中
        grayNoisy = im2gray(noisyImage); %调用 im2gray 函数将 noisyImage 转换为灰度图像，并将结果存储在变量 grayNoisy 中
        grayDenoised = im2gray(denoisedImage); %调用 im2gray 函数将 denoisedImage 转换为灰度图像，并将结果存储在变量 grayDenoised 中
        
        % 获取选择的性能参数
        selectedMetrics = findall(metricPanel, 'Style', 'checkbox', 'Value', 1); %调用 findall 函数查找所有符合条件的图形对象，并将结果存储在变量 selectedMetrics 中
        if isempty(selectedMetrics)
            msgbox('请先选择性能参数。', '警告', 'warn');
            return;
        end
        
        % 计算并显示性能参数
        msg = '';
        for i = 1:length(selectedMetrics) %开始一个 for 循环，循环次数为 selectedMetrics 的长度，即用户选择的性能参数的数量
            metric = selectedMetrics(i).String; %获取当前选中性能参数的字符串内容，并将其存储在变量 metric 中
            switch metric
                case '均方误差 (MSE)' %均方误差是衡量两幅图像（通常是原始图像和处理后的图像）之间差异的标准。值越小，表明两幅图像越相似。
                    mseNoisy = immse(grayOriginal, grayNoisy); %调用 immse 函数计算原始图像和噪声图像之间的（差异程度）均方误差 (MSE)，结果存储在 mseNoisy 变量中
                    mseDenoised = immse(grayOriginal, grayDenoised); %调用 immse 函数计算原始图像和去噪图像之间的均方误差 (MSE)，结果存储在 mseDenoised 变量中
                    msg = sprintf('%s\n噪声图像 MSE: %f\n去噪图像 MSE: %f', msg, mseNoisy, mseDenoised); %使用 sprintf 函数格式化字符串，将当前 msg 变量的内容与新的 MSE 结果拼接，并更新 msg 变量
                case '峰值信噪比 (PSNR)' %PSNR 是一种衡量重建图像质量的指标，根据图像像素灰度值的统计和平均计算来获得，通常用于比较原始图像和经过处理后的图像。值越大，表示重建图像质量越好，噪声越小。
                    psnrNoisy = psnr(grayNoisy, grayOriginal); %调用 psnr 函数计算噪声图像和原始图像之间的峰值信噪比 (PSNR)，结果存储在 psnrNoisy 变量中
                    psnrDenoised = psnr(grayDenoised, grayOriginal); %调用 psnr 函数计算去噪图像和原始图像之间的峰值信噪比 (PSNR)，结果存储在 psnrDenoised 变量中
                    msg = sprintf('%s\n噪声图像 PSNR: %f\n去噪图像 PSNR: %f', msg, psnrNoisy, psnrDenoised); %使用 sprintf 函数格式化字符串，将当前 msg 变量的内容与新的 PSNR 结果拼接，并更新 msg 变量
                case '相关系数' %相关系数衡量两幅图像之间的线性相关程度，即两幅图像之间的相关系数来衡量图像之间的相似程度。值的范围是 [-1, 1]，其中 1 表示完全正相关，0 表示无相关，-1 表示完全负相关。
                    corrNoisy = corr2(grayOriginal, grayNoisy); %调用 corr2 函数计算原始图像和噪声图像之间的相关系数，结果存储在 corrNoisy 变量中
                    corrDenoised = corr2(grayOriginal, grayDenoised); %调用 corr2 函数计算原始图像和去噪图像之间的相关系数，结果存储在 corrDenoised 变量中
                    msg = sprintf('%s\n噪声图像相关系数: %f\n去噪图像相关系数: %f', msg, corrNoisy, corrDenoised); %使用 sprintf 函数格式化字符串，将当前 msg 变量的内容与新的相关系数结果拼接，并更新 msg 变量
                case '等效视数 (ENL)' %ENL 是用于评估图像质量的指标，即均值的平方除以方差的平方，特别在雷达图像处理和合成孔径雷达 (SAR) 图像处理中常用。ENL 值越大，表明图像中的噪声越少，图像质量越好。
                    enlNoisy = calculateENL(grayNoisy); %调用 calculateENL 函数计算噪声图像的等效视数 (ENL)，结果存储在 enlNoisy 变量中
                    enlDenoised = calculateENL(grayDenoised); %调用 calculateENL 函数计算去噪图像的等效视数 (ENL)，结果存储在 enlDenoised 变量中
                    msg = sprintf('%s\n噪声图像 ENL: %f\n去噪图像 ENL: %f', msg, enlNoisy, enlDenoised); %使用 sprintf 函数格式化字符串，将当前 msg 变量的内容与新的 ENL 结果拼接，并更新 msg 变量
            end
        end
        msgbox(msg, '性能参数', 'help');
    end

    % 计算等效视数的辅助函数
    function enl = calculateENL(image) %定义一个名为 calculateENL 的函数。这个函数接受一个输入参数 image，并返回一个输出参数 enl
        region = double(image(50:100, 50:100)); %从输入图像 image 中选取第 50 行到第 100 行、第 50 列到第 100 列的区域，并将其转换为 double 类型
        meanValue = mean(region(:)); %计算选取区域的像素值的均值，并将结果存储在 meanValue 变量中
        stdValue = std(region(:)); %计算选取区域的像素值的标准差，并将结果存储在 stdValue 变量中
        enl = (meanValue / stdValue)^2; %根据均值和标准差计算等效视数 (ENL)，并将结果存储在 enl 变量中
    end


% 查看性能参数信息的回调函数
function viewMetricsInfo(~, ~)
    metricsInfo = sprintf(['性能参数说明:\n' ...
        '1. 均方误差 (MSE): 计算原始图像与去噪后图像之间的均方误差，用于衡量图像之间的差异，数值越小越好。\n' ...
        '2. 峰值信噪比 (PSNR): 衡量图像质量的参数，值越大表示图像质量越高。\n' ...
        '3. 相关系数: 反映两幅图像之间的相关程度，值在-1到1之间，数值接近 1 越好。\n' ...
        '4. 等效视数 (ENL): 主要用于评估雷达图像的去噪效果，数值越大越好。']);
     msgbox(metricsInfo, '性能参数信息');
end
end