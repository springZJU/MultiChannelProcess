clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];

%这个文件夹下面所有的spkRes.mat
%把每个细胞在每种trial里的spike聚到一起
for SettingParamIdx = 1 : numel(SettingParams)
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    % load params
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);
    
        for ShankDirIdx = 1 : numel(MatDirsInfo)
            clear KiloSpkData;
            ShankPath = strcat(MatRootPath, MatDirsInfo(ShankDirIdx).name, "\");
            KiloSpkData = load(strcat(ShankPath, "spkRes.mat"));
            trials_temp = KiloSpkData.trialAll;
            spikes = rowFcn(@(x) [x(1).spikePlot; x(2).spikePlot], [KiloSpkData.chSpikeLfp.chSPK], "UniformOutput", false);
   
            for IDIdx = 1 : numel(spikes)
                clear cellSpikes trialNum;
                cellSpikes = spikes{IDIdx};
                trialNum = [trials_temp.trialNum]';
                for trialIdx = 1 : numel(trialNum)
                    celltrialSpikes = cellSpikes(cellSpikes(:, 2) == trialNum(trialIdx), 1);
                    trials_temp(trialIdx).spikes = celltrialSpikes;
                    celltrials = trials_temp;
                    calLatency(celltrials, );
                end
            end
        end
end
