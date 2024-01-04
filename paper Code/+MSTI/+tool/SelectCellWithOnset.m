clear; clc;

% DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
DataRootPath = "H:\MLA_A1补充\Figure\CTL_New_补充\";

if strcmp(DataRootPath, "H:\MLA_A1补充\Figure\CTL_New\")
    SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                    "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
elseif strcmp(DataRootPath, "H:\MLA_A1补充\Figure\CTL_New_补充\")
    SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
end

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
            clear KiloSpkData trials_temp spikes latancy;
            ShankPath = strcat(MatRootPath, MatDirsInfo(ShankDirIdx).name, "\");
            KiloSpkData = load(strcat(ShankPath, "spkRes.mat"));
            trials_temp = KiloSpkData.trialAll;
            spikes = rowFcn(@(x) [x(1).spikePlot; x(2).spikePlot], [KiloSpkData.chSpikeLfp.chSPK], "UniformOutput", false);
            spikesID = rowFcn(@(x) [x(1).info], [KiloSpkData.chSpikeLfp.chSPK], "UniformOutput", false);
            for IDIdx = 1 : numel(spikesID)
                clear cellSpikes trialNum celltrials;
                cellSpikes = spikes{IDIdx};
                trialNum = [trials_temp.trialNum]';
                for trialIdx = 1 : numel(trialNum)
                    celltrialSpikes = cellSpikes(cellSpikes(:, 2) == trialNum(trialIdx), 1);
                    trials_temp(trialIdx).spike = celltrialSpikes;
                end
                celltrials = trials_temp;
                latancy(IDIdx, 1).ID = spikesID{IDIdx};    
                [latancy(IDIdx, 1).value, ~, ~] = calLatency({celltrials.spike}', [-7500, -7300], [1000, 1300]);

            end
            ShankCellLatency(ShankDirIdx).Date = MatDirsInfo(ShankDirIdx).name;
            ShankCellLatency(ShankDirIdx).latency = latancy;

        end
        CalLatency(SettingParamIdx).protocol = Protocol;
        CalLatency(SettingParamIdx).Latency = ShankCellLatency;

end
