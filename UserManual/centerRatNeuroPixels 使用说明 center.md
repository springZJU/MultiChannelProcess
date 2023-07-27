# <center><font color=red>RatNeuroPixels 使用说明 </font></center>

## 1.从Github上下载代码

~~~
 git clone git@github.com:springZJU/RatNeuroPixels.git
~~~

下载下来的项目中应包含如下文件夹：

| 名称        | 解释                                                         |
| ----------- | ------------------------------------------------------------ |
| User Manual | 用户手册                                                     |
| Sort        | 从OpenEphys/TDT导出数据、kilosort及转存成.mat的工具包        |
| config      | 必要的刺激/画图参数的填写（excel文件）和读取（MLA_ParseCTLParams.m) |
| Preprocess  | 计算CSD和MUA需要用到的预处理函数                             |
| CTLProcess  | 除RNP_CTLProcess为框架（筛选mat文件并调用protocol对应处理函数），其他函数每个对应一种protocol，其命名与mat文件夹相同 |
| plot        | 每种具体protocol下要用到的画图函数                           |
| utils       | 一些零碎处理项，如实验记录（recordingExcel）、补丁（patch）、统计工具（statistics）等 |

## 2.填写实验记录

新建/找到实验记录Excel，命名规则为“Name_Project_Protocol_Recording.xlsx"，如”SPR_RNP_TB_Offset_Recording.xlsx"，路径为：

<u>*RatNeuroPixles/utils/recordingExcel/SPR_RNP_TBOffset_Recording.xlsx*</u>

其中，Excel的标签和内容为：

| ID   |                BLOCKPATH                | paradigm  | datPath                                                      | hardware                | SR_AP  | SR_LFP | sitePos | depth  | sort   | exported |
| ---- | :-------------------------------------: | --------- | :----------------------------------------------------------- | ----------------------- | ------ | ------ | ------- | ------ | ------ | -------- |
| 0    |                 string                  | string    | string                                                       | string                  | double | double | string  | double | double | double   |
| 1    | F:\RNP\Rat1_SPR\Rat1SPR20230505\Block-1 | RNP_Noise | F:\RNP\RNPDATA\20230505\Rat1\Record Node  121\experiment3\recording1\continuous | Neuropix-PXI-122.ProbeA | 30000  | 2500   | AC1     | 2400   | 1      | 1        |

其中，第一行的ID为0，其定义了每一列内容读取时的数据类型（如**BLOCKPATH**读取时的数据类型为string，**SR_AP**的数据类型为30000；ID为1的条目是可读取的条目。

进一步的，不同的标签意义为：

| 标签          | 解释                                                         |
| ------------- | ------------------------------------------------------------ |
| **BLOCKPATH** | TDT的blockpath                                               |
| **Paradigm**  | 范式名称                                                     |
| **datPath**   | neuropixel的路径，注意文件夹层级至continuous                 |
| **hardware**  | neuropixel的记录Node名称，一般为“Neuropix-PXI-122.ProbeA”    |
| **SR_AP**     | 默认值：30000                                                |
| **SR_LFP**    | 默认值：2500                                                 |
| **sitePos**   | 电极位置，若可以明确距离前囟的坐标位点，则写位点（A/P,V/D)，A:anterior;P:posterior;V:ventral;D:dorsal；否则填“position+No.”，如“AC1” |
| **depth**     | 电极进入的深度                                               |
| **sort**      | 是否sort，若没有，则填0。注意，若sort=0，则该记录的数据不会导出为mat文件 |
| **exported**  | 该记录的数据是否导出，若没有，则填0；当exported=1时，不会再进行导出处理 |

## 3.使用kilosort进行神经元分类

#### 第一步：数据合并

打开数据合并的脚本*<u>RatNeuroPixles/Sort/datMerge.m</u>*

在“TODO”小节下，修改excel文件名、tank名和block序号：

~~~matlab
%% TODO:
xlsxPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
    "SPR_RNP_TBOffset_Recording.xlsx");
tankSel = "Rat2SPR20230708"; %% TDT tank name
blockGroup = {[1:4, 6:11]};
%%
~~~

随后运行脚本，在tank路径下会产生“Merge1”文件夹，若tankSel为n*1的cell，会产生n个Merge(n)文件夹。

### 第二步：运行kilosort

打开sort的脚本*<u>RatNeuroPixles/Sort/kilosortToProcess_NeuroPixels.m</u>*

在“TODO”小节下，修改Merge路径：

~~~matlab
MERGEPATH = strcat("I:\neuroPixels\TDTTank\Rat2_SPR\Rat2SPR20230708\Merge", num2str(mIndex));
~~~

加载电极模板,模板及配置文件在*<u>RatNeuroPixels/Sort/config</u>*文件夹内

~~~matlab
run('config\configFileMulti.m');
% treated as linear probe if no chanMap file
ops.chanMap = 'config\neuropix385_kilosortChanMap.mat';
% total number of channels in your recording
ops.NchanTOT = 385; %384 CHs + 1 sync
% sample rate, Hz 
ops.fs = 30000; 
~~~

若是使用TDT记录，采样率为12207.03125，使用16×1/16×2/32×1的电极，则需修改相应参数为

~~~matlab
run('config\configFileMulti.m');
% treated as linear probe if no chanMap file
ops.chanMap = 'config\chan16_1_kilosortChanMap.mat';  %16*1 linear array
% ops.chanMap = 'config\chan16_2_kilosortChanMap.mat'; %16*2 linear array
% ops.chanMap = 'config\chan32_1_kilosortChanMap.mat'; %32*1 linear array

% total number of channels in your recording
ops.NchanTOT = 16; %16*1 linear array
% ops.NchanTOT = 32; %16*2 / 32*1 linear array
% sample rate, Hz 
ops.fs = 12207.03125; 
~~~

找到设置kilosort阈值的地方,设置th1和th2，示例中th1为9，th2为7。

~~~matlab
for th2 = [7 ]
    ops.Th = [9 th2];
    savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);
    if ~exist(strcat(savePath, "\params.py"), "file")
        mKilosort(binFile, ops, savePath);
    end
end
~~~

运行之后，在*<u>Merge1</u>*文件夹中会创建*<u>th9_7</u>*文件夹，其中为kilosort之后产生的结果文件。

### 第三步：运行GUI并保存

进入*<u>TANKPATH/Merge1/th9_7</u>*文件夹

在路径栏输入

~~~
cmd
~~~

进入命令提示符窗口后，输入

~~~
phy template-gui params.py
~~~

打开GUI界面后按**ctrl+s**或**保存键**保存，关闭后确认文件夹中是否新增了*<u>cluster_info.tsv</u>*文件。

一般为了看所有可能存在的细胞结果，先不进行挑选，而是直接将所有的cluster（无论是否是有效的sort）批量导出，因此可以根据*<u>cluster_info.tsv</u>*文件读取id和ch信息并导出。

### 第四步：导出sort数据至相应block中

首先找到**TODO**小节，做出相应修改

~~~matlab
%% TODO
MERGEPATH = strcat("I:\neuroPixels\TDTTank\Rat2_SPR\Rat2SPR20230708\Merge", num2str(mIndex)); % merge的路径
load(fullfile(MERGEPATH,'mergePara.mat'));
chAll = 384; % 有效的通道
fs = 30000; % 采样率
NPYPATH = char(fullfile(MERGEPATH, "th9_7")); % the path including ks_result
~~~

若是使用*<u>cluster_info.tsv</u>*看所有的cluster结果，则选择下列代码

~~~matlab
%% cluster_info.tsv, for preview and selection
IDs = tabulate(clusterIdx);
idToDel = IDs(IDs(:, 2) < 1000, 1);
run("alignIdCh.m");
idx = idCh(:, 1);
ch = idCh(:, 2);
~~~

若是后续根据所有cluster的结果挑选特定的细胞，则选择下列代码

~~~matlab
ch =  [0 1 4 7 8 1008 9 10 12 13 14 16 17 20 21 23 24 25 26 27 28 29 30]; % channels index of kilosort, that means chKs = chTDT - 1;
idx = [25 24 23 22 19 20 18 21 16 17 15 13 14 12 11 9 8 7 10 6  3 2 0]; % the corresponding id

~~~

此外，若是要导出细胞的波形，则在最后部分选择导出波形的代码，建议选择好细胞后再做这一步，不然过于耗时。

~~~matlab
%% export waveform
onsetIdx = ceil(t(1) * fs);
wfWin = [-30, 30];
IDandCHANNEL = [idx, zeros(length(idx), 1), ch];
disp(strcat("Processing blocks (", num2str(blks), "/", num2str(length(BLOCKPATH)), ") ..."));
spkWave = getWaveForm_singleID_v2(fs, BLOCKPATH{blks}, NPYPATH, idx, IDandCHANNEL, wfWin, onsetIdx);
~~~

随后开始运行，运行之后会在选择的block中生成**sortdata.mat**。

### 第五步：将刺激参数和神经元数据导出成mat文件

首先找到**TODO**小节，将excel名称修改。

~~~matlab
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
            "SPR_RNP_TBOffset_Recording.xlsx");
~~~

随后开始运行，运行之后会在RatNeuropixles文件夹所在根目录下产生一个同级的文件夹MAT Data，根据*<u>MATData\Name\Project\Protocol\Date\data.mat</u>*的格式存储数据，如*<u>I:\neuroPixels\MATData\Rat2_SPR\CTL_New\RNP_Click_Tuning\Rat2SPR20230708_IC1\data.mat</u>*

### 第六步：填写Protocol对应的参数

新建/找到protocol刺激\画图参数对应的Excel，命名规则为“Method_ParseProjectParams.xlsx"，如”RNP_ParseCTLParams.xlsx"，路径为：<u>*RatNeuroPixles/config/RNP_ParseCTLParams.xlsx*</u>

其中，Excel中不同的标签意义为：

| 标签                 | 解释                                                         |
| -------------------- | ------------------------------------------------------------ |
| **Paradigm**         | 范式名称                                                     |
| **soundPath**        | 电路中使用的声音文件的路径，非必需，便于回溯用               |
| **trialTypes**       | 与电路中ordr对应的刺激类型，用于后续做图lengend和存储数据用  |
| **S1Duration**       | 对于temporal binding的protocol，该值为ICI变化的时刻；若是offset的protocol，该值为声音时长 |
| **Offset**           | 刺激的总时长                                                 |
| **Window**           | 每个trial截取的数据长度。注意这里的0时刻对应TDT记录的trial onset时刻加上S1Duration的时刻。 |
| **selWin**           | 主要用于CSD，**selWin**的范围小于**Window**。0时刻对应TDT记录的trial onset时刻加上S1Duration的时刻。 |
| **FFTWin**           | 对LFP数据进行FFT时的选择窗口，**FFTWin**的范围要小于Window。0时刻对应TDT记录的trial onset时刻加上S1Duration的时刻。 |
| **ICAWin**           | 对LFP数据进行ICA时的选择窗口，**ICAWin**的范围要小于**Window**。0时刻对应TDT记录的trial onset时刻加上**S1Duration**的时刻。 |
| **BaseICI**          | 对于TB，为ICI1的大小；对于Offset，为ICI大小                  |
| **ICI2**             | 对于TB，为ICI2的大小；                                       |
| **colors**           | 画PSTH和LFP图时用到的颜色，与后续的**Compare_Index**参数对应 |
| **toPlotFFT**        | 在单个神经元的batch结果图中，是否要画FFT的结果。若不画，则设为0；否则，设为1 |
| **plotRows**         | 用于结果图的版面规划，在不添加额外新的内容时，默认值为6。    |
| **plotWin**          | 每种刺激对应raster图、PSTH图和LFP图的时间范围。**plotWin**的范围要小于**Window**。0时刻对应TDT记录的trial onset时刻加上**S1Duration**的时刻。 |
| **legendFontSize**   | 对于多种情况比较的图，会有legend，需要设定lengend字体大小，默认为8或12 |
| **compareCol**       | 对于TB，为ICI2的大小；                                       |
| **colors**           | 画PSTH和LFP图时用到的颜色，与后续的**Compare_Index**参数对应 |
| **toPlotFFT**        | 在单个神经元的batch结果图中，是否要画FFT的结果。若不画，则设为0；否则，设为1 |
| **plotRows**         | 用于结果图的版面规划，在不添加额外新的内容时，默认值为6。    |
| **plotWin**          | 每种刺激对应raster图、PSTH图和LFP图的时间范围。**plotWin**的范围要小于**Window**。0时刻对应TDT记录的trial onset时刻加上**S1Duration**的时刻。 |
| **Compare_Index**    | 不同情况的PSTH和LFP进行比较，当刺激类型太多时，通过分号进行分割。如1,2,3,4;4,5,6,7的意思是将TDT中记录到的ordr为1-4的4种刺激放在一起比较，将4-7的4种刺激放在一起比较。每组内部的颜色根据前述**colors**的内容按组内先后顺序对应设定，如4-7种的4对应colors中的第一个颜色值。 |
| **compareWin**       | 不同情况的PSTH和LFP比较时用到的时间范围。0时刻对应TDT记录的trial onset时刻加上**S1Duration**的时刻。 |
| **legendFontSize**   | 对于多种情况比较的图，会有legend，需要设定lengend字体大小，默认为8或12 |
| **PSTH_CompareSize** | 填写规则为[col, row]，即填写2,2时，PSTH不同情况比较的图所占空间为两行两列。subplot的列数为col*2，行数为前述的**plotRows**。 |
| **LFP_CompareSize**  | 填写规则与**PSTH_CompareSize**相同                           |
| **chPlotFcn**        | 针对不同protocol调用不同的函数。注意需要按照匿名函数的填写方式，函数名前要加@。具体写法可参考*<u>MLA_PlotRasterLfp_v2.m</u>* |
