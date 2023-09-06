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
| CTLProcess  | 在线处理（TDT_\*.m）和离线处理（RNP/MLA \*.m)的脚本及对应protocol需要调用的函数 |
| plot        | 每种具体protocol下要用到的画图函数                           |
| utils       | 一些零碎处理项，如实验记录（recordingExcel）、补丁（patch）、统计工具（statistics）等 |
| Paper Code  | 若有些重名函数，根据不同文章处理要求不一样，可以放在此文件夹，用“+name”的形式建立 |

## 2.填写实验记录

新建/找到实验记录Excel，命名规则为“Name_Project_Protocol_Recording.xlsx"，如”SPR_RNP_TB_Offset_Recording.xlsx"，路径为：

<u>*MultiChannelProcess/utils/recordingExcel/SPR_RNP_TBOffset_Recording.xlsx*</u>

其中，Excel的标签和内容为：

| ID   |                BLOCKPATH                | paradigm  | datPath                                                      | hardware                | SR_AP  | SR_LFP | sitePos | depth  | sort   | lfpExported | spkExported | recTech    | chNum  | badChannel |
| ---- | :-------------------------------------: | --------- | :----------------------------------------------------------- | ----------------------- | ------ | ------ | ------- | ------ | ------ | ----------- | ----------- | ---------- | ------ | ---------- |
| 0    |                 string                  | string    | string                                                       | string                  | double | double | string  | double | double | double      | double      | string     | double |            |
| 1    | F:\RNP\Rat1_SPR\Rat1SPR20230505\Block-1 | RNP_Noise | F:\RNP\RNPDATA\20230505\Rat1\Record Node  121\experiment3\recording1\continuous\Neuropix-PXI-122.ProbeA | Neuropix-PXI-122.ProbeA | 30000  | 2500   | AC1     | 2400   | 1      | 1           | 1           | NeuroPixel | 385    |            |

其中，第一行的ID为0，其定义了每一列内容读取时的数据类型（如**BLOCKPATH**读取时的数据类型为string，**SR_AP**的数据类型为30000；ID为1的条目是可读取的条目。

进一步的，不同的标签意义为（标*的标签为neuroPixel数据独有的）：

| 标签            | 解释                                                         |
| --------------- | ------------------------------------------------------------ |
| **ID**          | 用于分割连续记录，sort前的data merging步骤只会合并具有相同ID的条目。 |
| **BLOCKPATH**   | TDT的blockpath                                               |
| **Paradigm**    | 范式名称                                                     |
| **datPath***    | neuropixel数据的存储路径                                     |
| **SR_AP***      | 默认值：30000                                                |
| **SR_LFP***     | 默认值：2500                                                 |
| **sitePos**     | 电极位置，若可以明确距离前囟的坐标位点，则写位点（A/P,V/D)，A:anterior;P:posterior;V:ventral;D:dorsal；否则填“position+No.”，如“AC1” |
| **depth**       | 电极进入的深度                                               |
| **sort**        | 是否sort，若没有，则填0。注意，若sort=0，则该记录的数据不会导出为mat文件 |
| **lfpExported** | 该记录的LFP数据是否导出，若没有，则填0；当lfpExported=1时，不会再进行导出处理 |
| **spkExported** | 该记录的spike数据是否导出，若没有，则填0；当spkExported=1时，不会再进行导出处理 |
| **recTech**     | 记录手段，用于后续的处理分流                                 |
| **chNum**       | 使用电极的通道数，用于选择channel map                        |

## 3.使用kilosort进行神经元分类并导出mat文件

#### <font color=red>现已将下列所有步骤合并到*<u>MultiChannelProcess/Sort/datMerge_Kilosort.m</u>*中</font>

#### 第一步：配置参数

在“TODO”小节下，修改excel文件名、tank名和block序号：

~~~matlab
%% TODO:
customInfo.recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\recordingExcel\", ...
      "ZYY_RNP_TBOffset_Recording.xlsx");    
%         "SPR_MLA_Recording.xlsx");
%         "XHX_MLA_Recording.xlsx");

customInfo.dateSel = "0903"; % date
customInfo.MATPATH = "I:\neuroPixels\MAT Data\"; % export root path
customInfo.thr = [9, 4]; % threshold for kilosort
customInfo.exportSpkWave = false; % 是否导出spike波形
customInfo.ReSaveMAT = false; % redo
customInfo.reExportSpk = false; % redo
~~~

随后运行脚本，在tank路径下会产生“Merge1”文件夹，若tankSel为n*1的cell，会产生n个Merge(n)文件夹。



#### 第二步：合并数据

“datMerge”小节将根据excel的数据寻找原始数据所在路径，并合并到一个二进制文件中，该文件默认放在tank文件夹中，命名为“Merge+ID”：

![image-20230906130722102](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906130722102.png)

**注意：若有新的记录手段，需新写一个merge函数，并加入到下面的if语句中：**

~~~matlab
        if strcmpi(recTech, "TDT")
            TDT2binMerge(BLOCKPATH,MERGEFILE);
        elseif strcmpi(recTech, "NeuroPixel")
            NP_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
%         elseif strcmpi(recTech, "newTech") % 新的记录手段
%             newTech_TDT_Merge(BLOCKPATH, DATAPATH, MERGEFILE, fs)
        end
~~~

**其中，recTech在记录的Excel文件中定义。**



#### 第三步：运行kilosort

这一步是运行kilosort，会在第二步生成的Merge文件夹中生成Th(x)_(y)的文件夹，其中(x)和(y)分别为第一步中设置的阈值。

![image-20230906130818191](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906130818191.png)

**注意：若记录的电极位点及排布有变化，需新建一个电极位点分布模板，加入到<u>*MultiChannelProcess\Sort\process\config*</u>文件夹中，并在*<u>MultiChannelProcess\Sort\process\process_Kilosort.m</u>*的下列代码中加入新的情况：**

~~~matlab
        switch chNum
        case 16
            % treated as linear probe if no chanMap file
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan16_1_kilosortChanMap.mat'];  %16*1 linear array
            % total number of channels in your recording
            ops.NchanTOT = 16; %16*1 linear array
            % sample rate, Hz
            ops.fs = 12207.03125;

        case 32
            % ops.chanMap = 'config\chan16_2_kilosortChanMap.mat'; %16*2 linear array
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\chan32_1_kilosortChanMap.mat']; %32*1 linear array
            ops.NchanTOT = 32; %16*2 / 32*1 linear array
            ops.fs = 12207.03125;
        case 385
            ops.chanMap = [fileparts(mfilename("fullpath")), '\config\neuropix385_kilosortChanMap.mat'];
            ops.NchanTOT = 385; %384 CHs + 1 sync
            ops.fs = 30000;
%         case newCH % 新的电极位点数目及分布
%             ops.chanMap = [];
%             ops.NchanTOT = []; %384 CHs + 1 sync
%             ops.fs = [];
    end
~~~



#### 第四步：运行GUI并保存

运行完第三步后，会自动打开kilosort的结果GUI，在GUI界面内按**ctrl+s**或**保存键**保存，关闭后确认文件夹中是否新增了*<u>cluster_info.tsv</u>*文件。

![image-20230906130851469](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906130851469.png)

一般为了看所有可能存在的细胞结果，先不进行挑选，而是直接将所有的cluster（无论是否是有效的sort）批量导出，因此可以根据*<u>cluster_info.tsv</u>*文件读取id和ch信息并导出。

![image-20230906130930567](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906130930567.png)

**注意：只有完成第四步后MATLAB才会进入到第五步的流程中**



#### 第五步：导出sort数据至相应block中

这一步会在excel中填写的每个block中都生成一个“sortdata.mat”，加载后，变量sortdata的第一列为spike的时刻，与TDT记录的该block的时刻对齐，第二列为spike所在的通道数，若有通道大于1000，则其为kilosort在同一通道中sort出的多个神经元，其真实通道数为该数除以1000后取余，如1005实际通道为5。

![image-20230906131530915](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906131530915.png)

**注意：第一步中若定义：**

~~~matlab
customInfo.exportSpkWave = true; % 是否导出spike波形
~~~

**则sortdata.mat中还有一个变量为spkWave，其包含每个spike的波形。**



#### 第六步：将刺激参数和神经元数据导出成mat文件

这一步将lfp、spike数据按照<u>*MATPATH\animalName\Project\Protocol\Date\\(spkData|lfpData).mat*</u>的格式导出，其中，MATPATH在第一步中定义。

~~~matlab
customInfo.MATPATH = "I:\neuroPixels\MAT Data\"; % export root path
~~~

**注意：若有新的记录手段，需新写一个export函数，并加入到*<u>MultiChannelProcess\Sort\process\process_SaveMAT.m</u>*的下列if语句中：**

~~~matlab
    if matches(animal, ["MLA", "RLA"])
        saveXlsxRecordingData_MonkeyLA(MATPATH, recordInfo, i, recordPath);
    elseif matches(animal, "RNP")
        saveXlsxRecordingData_RatNP(MATPATH, recordInfo, i, recordPath);
%     elseif matches(recTech, "custom")
%         % custom
    end
~~~

**其中，recTech在记录的Excel文件中定义。**

最终导出结果如图：

![image-20230906133313461](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906133313461.png)

![image-20230906144652968](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20230906144652968.png)



## 4. BATCH处理（因人而异，仅供参考）

#### 第一步：填写Protocol对应的参数（主要针对temporal binding/Offset的protocol，若是新的，可以跳过本步骤）

新建/找到protocol刺激\画图参数对应的Excel，命名规则为“Method_ParseProjectParams.xlsx"，如”RNP_ParseCTLParams.xlsx"，路径为：<u>*RatNeuroPixles/config/RNP_CTLConfig.xlsx*</u>

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
| **chPlotFcn**        | 针对不同protocol调用不同的函数。注意需要按照匿名函数的填写方式，函数名前要加@。具体写法可参考*<u>RatNeuroPixels\plot\protocols\MLA_PlotRasterLfp_v2.m</u>*，针对新的protocol编写的新的画图函数保存在*<u>protocols</u>*文件夹中 |

注意，若加入了新的标签，需要在同级的*<u>RatNeuroPixles/config/RNP_ParseCTLParams.m</u>*中加入新的读取代码。

#### 第二步：设置batch参数

首先打开脚本*<u>RatNeuroPixels\CTLProcess\RNP_CTLProcess.m</u>*，填写**TODO**节

~~~matlab
%% TODO: configuration
ratName = "Rat2_SPR"; % required
ROOTPATH = "I:\neuroPixels"; % required
project = "CTL_New"; % project, required
dateSel = ""; % blank for all
protSel = "RNP_ToneCF"; % blank for all
~~~

dateSel可以选择处理特定日期的数据；protSel可以选择处理特定protocol的数据，两个变量为空时默认处理该动物下所有日期/protocol的数据。

#### 第三步：创建处理程序

batch时，根据protocol name调用函数的逻辑如下：

~~~matlab
        try % the function name equals the protocol name
            mFcn = eval(['@', char(protocolStr), ';']);
            mFcn(MATPATH{mIndex}, FIGPATH{mIndex});
        catch % temporal binding protocols
            if RNP_IsCTLProt(protocolStr)
                RNP_ClickTrainProcess(MATPATH{mIndex}, FIGPATH{mIndex});
            end
        end
~~~

目前版本中已有处理CF（RNP_ToneCF.m）、Noise（RNP_Noise.m)和TB/Offset（RNP_ClickTrainProcess.m)的程序。若要加入新的protocol（不属于TB/Offset），则需创建新的处理函数，可参考RNP_ClickTrainProcess.m。若新的protocol是独立的，即并非一系列处理方式比较general的protocol，建议新函数的命名与recording excel中paradigm的命名相同，如paradigm为RNP_ToneCF，则处理函数为RNP_ToneCF.m，batch时采用上述代码的第一段；若与TB/Offset类似，是一系列protocol且处理和画图逻辑类似，则可参考第二段，先判断是否属于一个大类（RNP_IsCTLProt.m)，若是，则进入大类处理中（RNP_ClickTrainProcess.m)。

新的函数的输入应包含：MATPATH（mat文件或TDT的block所在路径）和FIGPATH（处理的结果图和中间变量存储路径）。

#### 第四步：batch处理

batch处理的主要目的分为两个部分：做出单个神经元的结果图和保存中间变量（用于population的处理，Noise和ToneCF除外）。

##### part.1 检测输出文件夹中是否已经有结果图，若有，则跳过该次记录

~~~matlab
temp = dir(FIGPATH);
Exist_Single = any(contains(string({temp.name}), "CH"));
% Exist_CSD_MUA = any(contains(string({temp.name}), "LFP_Compare_CSD_MUA"));
Exist_CSD_MUA = 1;
% Exist_LFP_By_Ch = any(contains(string({temp.name}), "LFP_ch"));
Exist_LFP_By_Ch = 1;
% Exist_LFP_Acorss_Ch = any(contains(string({temp.name}), "LFP_Compare_Chs"));
Exist_LFP_Acorss_Ch = 1;
if all([Exist_LFP_Acorss_Ch, Exist_LFP_By_Ch, Exist_CSD_MUA, Exist_Single])
    return
end
~~~

注意当不想处理CSD/MUA、LFP时，将对应的Exist_***标志位设为1即可。

##### part.2 读取trial、spike和lfp数据，以及protocol参数

~~~matlab
[trialAll, spikeDataset, lfpDataset] = spikeLfpProcess(DATAPATH, params);

CTLParams = RNP_ParseCTLParams(protStr);
parseStruct(CTLParams);
fd = fs;

if isequal(lfpDataset.lfp.fs, fd)
    lfpDataset = ECOGResample(lfpDataset.lfp, fd);
else
    lfpDataset = lfpDataset.lfp;
end
~~~

##### part.3 校准change point

~~~matlab
%% set trialAll
trialAll([trialAll.devOrdr] == 0) = [];
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");
trialAll(1) = [];
~~~

这里时间校准用到了前面*<u>RNP_CTLConfig.xlsx</u>*中的**S1Duration**。

##### part.4 分割数据

~~~matlab
%% split data
[trialsLFPRaw, ~, ~] = selectEcog(lfpDataset, trialAll, "dev onset", Window); % "dev onset"; "trial onset"
trialsLFPFiltered = ECOGFilter(trialsLFPRaw, 0.1, 200, fd);
[trialsLFPFiltered, ~, idx] = excludeTrialsChs(trialsLFPFiltered, 0.1);
trialsLFPRaw = trialsLFPRaw(idx);
trialAllRaw = trialAll;
trialAll = trialAll(idx);
if ~Exist_CSD_MUA
    [~, WAVEDataset] = MUA_Preprocess(MATPATH);
    trialsWAVE = selectEcog(WAVEDataset, trialAll, "dev onset", Window);
end

% spike
chSelect = [spikeDataset.realCh]';
find(chSelect == 0)
trialsSpike = selectSpike(spikeDataset, trialAllRaw, CTLParams, "dev onset");
~~~

这里使用**excludeTrialsChs**函数将偏离平均值很大的trial删除。**trialsLFPRaw**用于后续FFT，**trialsFiltered**用于LFP波形的描绘。trialsSpike为每个trial对应的spike结果。

##### part.5 根据order进行分类

~~~matlab
% diff stims
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    tIndexRaw = [trialAllRaw.devOrdr] == devType(dIndex);
    trialsToFFT = trialsLFPRaw(tIndex);
    trialsLFP = trialsLFPFiltered(tIndex);
    if ~Exist_CSD_MUA
        trialsWave = trialsWAVE(tIndex);
    end
    trialsSPK = trialsSpike(tIndexRaw);
    
~~~

这里根据**devType**（order的类型）进行for循环，**tIndex**指在当前order下的trial索引，根据**tIndex**得到了**trialsLFP**、**trialsSPK**，分别为当前刺激下的LFP和spike集合。

##### part.6 处理LFP

~~~matlab
LFP = [];
for ch = 1 : size(trialsLFPFiltered{1}, 1)
  LFP(ch).info = strcat("CH", num2str(ch));
end


if ~Exist_CSD_MUA
% CSD
[badCh, dz] = MLA_CSD_Config(MATPATH);
CSD = CSD_Process(trialsLFP, Window, "kCSD", badCh, dz);

% MUA
MUA = MUA_Process(trialsWave, Window, selWin, WAVEDataset.fs, fdMUA);
else
    CSD = [];
    MUA = [];
end

% FFT
tIdx = find(tFFT > FFTWin(dIndex, 1) & tFFT < FFTWin(dIndex, 2));
[ff, PMean{dIndex, 1}, trialsFFT]  = trialsECOGFFT(trialsToFFT, fd, tIdx, [], 2);

% LFP
chMean{dIndex, 1} = cell2mat(cellfun(@mean , changeCellRowNum(trialsLFP), 'UniformOutput', false));
for ch = 1 : size(chMean{dIndex, 1}, 1)
    LFP(ch).Wave(:, 1) = t';
    LFP(ch).Wave(:, 2) = chMean{dIndex, 1}(ch, :)';
    LFP(ch).FFT(:, 1) = ff';
    LFP(ch).FFT(:, 2) = PMean{dIndex, 1}(ch, :)';
end
rawLFP.t = t';
rawLFP.rawWave = trialsToFFT;
rawLFP.f = ff';
rawLFP.FFT = trialsFFT;
~~~

这里先处理了CSD/MUA，注意当**Exist_CSD_MUA**设置为1时，会跳过处理步骤，将**CSD**和**MUA**设置为空。随后处理FFT和LFP的平均波形。最终将这些结果存于变量**LFP**中，并将原始的LFP数据及FFT结果存在**rawLFP**中（用于后续处理）。

##### part.7 spike处理





#### Update Log

请将每次大更新内容**置顶**写在这里，标注日期、修改者和兼容性（Incompatible/Compatible），对每条修改请标注修改类型（Add/Modify/Delete/Debug）。若为Incompatible，请给出修改方案。

- 2023/07/18 by XHX - Compatible

  | Type | Target            | Content                                                      |
  | ---- | ----------------- | ------------------------------------------------------------ |
  | Add  | `validateInput.m` | 增加了一个UI输入框，可以通过`validateInput(..., "UI", "on")`开启，替代命令行的输入方式 |
  | Add  | `pathManager.m`   | 返回`ROOTPATH\subject\protocol\datetime\*.mat`数据存放方式的完整mat路径，可以指定subject和protocol，如`matPaths = pathManager(ROOTPATH, "subjects", ["DDZ", "DD"], "protocols", "Noise");` |
  | Add  | `README.md`       | 添加说明文档                                                 |

