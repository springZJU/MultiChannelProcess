<meta name="viewport" content="width=device-width, initial-scale=1" />

#<center><font color=red>MultiChanProcess</font>的使用</center> 
##1. 配置并运行kilosort，保存sort结果
<a id="1.1"></a>
###1.1 打开 <u>.\MultiChanProcess\sort\\<font class="Blue1">kilosortToProcess_SPR.m </font></u>

>- 找到下列三行，并根据注释修改：
>  ```matlab {.line-numbers}
>  TANKPATH = 'G:\ECoG\DDZ\ddz20221223'; %tank路径
>  MergeFolder = 'Merge1'; %在tank路径下生成Merge1文件夹，存放kilosort结果
>  BLOCKNUM = num2cell([1:20]); %选择要sort的block number
>  ```
>
>- 加载电极模板,模板及配置文件在 <u>*.\MultiChanProcess\sort\config*</u>文件夹内
>  ```matlab {.line-numbers}
>  %% kilosort
>  run('config\configFileRat.m');
>  % treated as linear probe if no chanMap file
>  ops.chanMap = 'config\chan16_1_kilosortChanMap.mat';
>  % total number of channels in your recording
>  ops.NchanTOT = 16;
>  ```
>
>- 找到设置kilosort阈值的地方,设置th1和th2，上例中th1为6，th2为7，运行结束后kilosort结果会保存在 <u>*.\TANKPATH\MergeFolder\th7_6*</u> 下。
>  ```matlab {.line-numbers}
>  for th2 = [6 ]
>      ops.Th = [7 th2]; % first should be larger than second
>      savePath = fullfile(MERGEPATH, ['th', num2str(ops.Th(1))  , '_', num2str(ops.Th(2))]);
>      if ~exist([savePath '\params.py'])
>          mKilosort(binPath, ops, savePath);
>      end
>  end
>  ```
>- 至此可以运行脚本

<div STYLE="page-break-after: always;"></div>

###1.2 进入 <u>*\TANKPATH\MergeFolder\th7_6*</u>
>- 通过cmd输入
>```{.line-numbers}
>phy template-gui params.py
>```
> <div align=center><img src="ks_result.Png"></div>
>- 在打开的界面中找到 ***ch*** 和 ***id***,用于后续sort结果的导出


<a id="1.3"></a>
###1.3 打开<u>.\MultiChanProcess\sort\\<font class="Blue1">selectKilosortResult.m </font></u>

>- 找到下列三行，并根据注释修改
> ```matlab{.line-numbers}
>NPYPATH = fullfile(MERGEPATH, 'th7_6'); % the path including ks_result
>ch =  [0, 1, 3, 4, 8, 12, 13, 14]; % channels index of kilosort, that means chKs = chTDT - 1;
>idx = [1, 0, 2, 3, 6, 14, 13, 15]; % the corresponding id
>```
>- 至此可以运行脚本
>- 结果会以 ***sortdata.mat*** 保存在 [<u>1.1</u>](#1.1) 中选择的Block中


<div STYLE="page-break-after: always;"></div>

##2 将sort结果和lfp、wave数据导出到特定文件夹中（以MLA为例）
###2.1 打开<u>.\MultiChanProcess\utils\\<font class="Blue1">MLA_New_DDZ_Recording.xlsx</font></u>
<a id="2.1"></a>

>- 参数介绍：
>> <font size=3> **BLOCKPATH:** 包含 ***sortdata.mat*** 的block路径
>> <font size=3> **paradigm:** 特定protocol的名称，导出的.mat文件夹名称
>> <font size=3> **sitePos:** 穿刺的位置，后续可用于画拓扑图
>> <font size=3> **depth:** 穿刺的深度
>> <font size=3> **sort:** 是否sort过，是-1|否-0, 只有为1的才会导出
>> <font size=3> **exported:** 是否已经导出过， 是-1|否-0， 只有为0的才会导出，导出后自动置1
>> <font size=3> processed: 暂时无用
>> <font size=3> **bandChannel:** 记录电极的坏道，用于画CSD
>> <font size=3> **soundPath(optional)**: 作为溯源的记录
>> <font size=3> **cf:** 穿刺的cf，可用于画CF的拓扑分布
>> <font size=3> **dz:** 使用电极纵向相邻位点的间距($\mu$m) 
>> <font size=3> **ks_Chsel/ks_ID:** 默认为空，在[<u>1.3 selectKilosortResult.m</u>
](#1.3)中选择的ch和id会在[<u>下一步</u>](#2.2导出)中被自动记录到excel中
>- 根据实际的记录情况创建并修改excel里的内容


<div STYLE="page-break-after: always;"></div>

###2.2 打开<u>.\MultiChanProcess\sort\\<font class="Blue1">exportData_MonkeyLinearArray_passive.m</font></u>

<a id="2.2导出"></a>

>- 以DDZ的结果导出为例
>```matlab {.line-numbers}
>%% DDZ
>recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\utils\MLA_New_DDZ_Recording.xlsx");
>recordInfo = table2struct(readtable(recordPath));
>sort = [recordInfo.sort]';
>exported = [recordInfo.exported]';
>isECoG = [recordInfo.isECoG]';
>iIndex = find(sort == 1 & exported == 0 & isECoG == 0);  % export sorted and unprocessed spike data
>
>% export sorted and unprocessed spike data 
>for i = iIndex'
>    disp(strcat("processing ", recordInfo(i).BLOCKPATH, "... (", num2str(i), "/", num2str(max(iIndex)), ")"));
>    recordInfo = table2struct(readtable(recordPath));
>    saveXlsxRecordingData_MonkeyLA(recordInfo, i, recordPath);
>end
>```
>- 首先要修改的是第 ***2*** 行中excel的名称
>- 此外，还有一处需要修改，即这里调用的函数<font class="Blue1">saveXlsxRecordingData_MonkeyLA.m</font>,打开后注意<u>开头</u>对excel中 ***BLOCKPATH*** 的解析：
>```matlab {.line-numbers}
>BLOCKPATH = recordInfo(idx).BLOCKPATH;
>sitePos = recordInfo(idx).sitePos;
>depth = recordInfo(idx).depth;
>paradigm = recordInfo(idx).paradigm;
>temp = strsplit(BLOCKPATH, "\");
>animalID = temp{end - 2};
>dateStr = temp{end - 1};
>```
>- 这里根据实际的BLOCKPATH需要自行更改 ***temp*** 的索引，以及<u>结尾</u>导出路径的设置：
>```matlab {.line-numbers}
>if contains(paradigm, ["PEOdd7-10_Active", "PEOdd7-10_Passive"])
>    SAVEPATH = strcat("E:\MonkeyLinearArray\MAT Data\", animalID, "\PEOdd_Behavior\", paradigm, "\", dateStr, "_", sitePos);
>else
>    SAVEPATH = strcat("E:\MonkeyLinearArray\MAT Data\", animalID, "\CTL_New\", paradigm, "\", dateStr, "_", sitePos);
>end
>```
>- 这里是根据[<u>Excel参数介绍</u>](#2.1)中 ***paradigm*** 的名字来区分存储的<u>子路径</u>的，例如示例中是根据是否为<u>PEOdd7-10</u>来判断放在 ***PEOdd_Behavior*** 下还是 ***CTL_New*** 下的
  