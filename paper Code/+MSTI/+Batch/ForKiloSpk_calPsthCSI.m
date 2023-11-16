clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
Area = ["AC", "MGB"];


%%
for SettingParamIdx = 1 : numel(SettingParams)
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    % load params
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);
    n = 0;
    PsthCSIData = [];

    for AreaIdx = 1 : numel(Area)
        TargetArea = Area(AreaIdx);
        TargetDirIdx = find(contains(string({MatDirsInfo.name}'), TargetArea));
        for MatDirIdx = 1 : numel(TargetDirIdx)
            clear KiloSpkData;
            SonDirName = MatDirsInfo(TargetDirIdx(MatDirIdx)).name;
            NameTemp = strsplit(SonDirName, "_");
            Date = NameTemp{1};
            Position = NameTemp{2};
            AreaInfo = NameTemp{3};
            MatPath = strcat(MatRootPath, SonDirName, "\");
            KiloSpkData = load(strcat(MatPath, "spkRes.mat"), "chSpikeLfp");
            
            for IDIdx = 1 : numel(KiloSpkData.chSpikeLfp(1).chSPK)
                n = n + 1;
                PsthCSIData(n).Date = Date;
                PsthCSIData(n).Position = Position;
                PsthCSIData(n).Area = AreaInfo;
                PsthCSIData(n).ID = KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).info;

                % calculate CSI
                %Window
                Type1Windowlength = MSTIsoundinfo(1).Std_Dev_Onset(end) - MSTIsoundinfo(1).Std_Dev_Onset(end - 1);
                Type2Windowlength = MSTIsoundinfo(2).Std_Dev_Onset(end) - MSTIsoundinfo(2).Std_Dev_Onset(end - 1);
                Type1DevWin = [0, Type1Windowlength]; Type1StdWin = [-Type1Windowlength, 0];
                Type2DevWin = [0, Type2Windowlength]; Type2StdWin = [-Type2Windowlength, 0];                
                %sikeTime
                Type1IDSpikeTime = KiloSpkData.chSpikeLfp(1).chSPK(IDIdx).spikePlot(:, 1);
                Type2IDSpikeTime = KiloSpkData.chSpikeLfp(2).chSPK(IDIdx).spikePlot(:, 1);
                %CSI
                Type1DevFR = length(find(Type1IDSpikeTime > Type1DevWin(1) & Type1IDSpikeTime < Type1DevWin(2))) / (Type1Windowlength / 1000);
                Type1StdFR = length(find(Type1IDSpikeTime > Type1StdWin(1) & Type1IDSpikeTime < Type1StdWin(2))) / (Type1Windowlength / 1000);
                Type2DevFR = length(find(Type2IDSpikeTime > Type2DevWin(1) & Type2IDSpikeTime < Type2DevWin(2))) / (Type2Windowlength / 1000);
                Type2StdFR = length(find(Type2IDSpikeTime > Type2StdWin(1) & Type2IDSpikeTime < Type2StdWin(2))) / (Type2Windowlength / 1000);

                PsthCSIData(n).CSI = (Type1DevFR + Type2DevFR - Type1StdFR - Type2StdFR) / (Type1DevFR + Type2DevFR + Type1StdFR + Type2StdFR);              

            end
            
        end
    end
    save(strcat(MatRootPath, "PopData_PsthCSI.mat"), "PsthCSIData", "-mat");
end



