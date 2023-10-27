clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
Oscillation_RSWindow = [-5400, 0];
SoundDuration = 600;%ms

%%
for SettingParamIdx = 1 : numel(SettingParams)
    % load spkRes.mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    % load params
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);

    for MatDirIdx = 1 : numel(MatDirsInfo)
        clear chSpikeLfp RSData;
        MatPath = strcat(MatRootPath, MatDirsInfo(MatDirIdx).name, "\");
        load(strcat(MatPath, "spkRes.mat"), "chSpikeLfp");
        
        % Process
        for trialTypeIdx = 1 : numel(chSpikeLfp)
            trialTypeStr = chSpikeLfp(trialTypeIdx).stimStr;
            RSData(trialTypeIdx).trialType = trialTypeStr;
            KiloSpkData = chSpikeLfp(trialTypeIdx).chSPK;
            BGICI = BaseICI(trialTypeIdx, 1);
            StdICI = BaseICI(trialTypeIdx, 2);
            DevICI = BaseICI(trialTypeIdx, 3);

            for IDIdx = 1 : numel(KiloSpkData)
                SpkTimeTemp = KiloSpkData(IDIdx).spikePlot(:, 1);
                trialNum = numel(unique(KiloSpkData(IDIdx).spikePlot(:, 2)));
                % calculate RS window
                Std_RSWindow = [-600, -600 + StdICI * floor(300 / StdICI)];
                BG_RSWindow = [-300, -300 + BGICI * floor(300 / BGICI)];
                Dev_RSWindow = [0, DevICI * floor(300 / DevICI)];

                % calculate RS
                t_StdIdx = find(SpkTimeTemp > Std_RSWindow(1) & SpkTimeTemp < Std_RSWindow(2));
                t_BGIdx = find(SpkTimeTemp > BG_RSWindow(1) & SpkTimeTemp < BG_RSWindow(2));
                t_DevIdx = find(SpkTimeTemp > Dev_RSWindow(1) & SpkTimeTemp < Dev_RSWindow(2));
                t_OscillationIdx = find(SpkTimeTemp > Oscillation_RSWindow(1) & SpkTimeTemp < Oscillation_RSWindow(2));

                [RS_Std, ~] = RayleighStatistic(SpkTimeTemp(t_StdIdx), StdICI, trialNum);
                [RS_BG, ~] = RayleighStatistic(SpkTimeTemp(t_BGIdx), BGICI, trialNum);
                [RS_Dev, ~] = RayleighStatistic(SpkTimeTemp(t_DevIdx), DevICI, trialNum);
                [RS_Oscillation, ~] = RayleighStatistic(SpkTimeTemp(t_DevIdx), SoundDuration, trialNum);
                
                RSData(trialTypeIdx).RSValue(IDIdx, 1).info = KiloSpkData(IDIdx).info;
                RSData(trialTypeIdx).RSValue(IDIdx, 1).Std = [RS_Std, StdICI];
                RSData(trialTypeIdx).RSValue(IDIdx, 1).BG = [RS_BG, BGICI];
                RSData(trialTypeIdx).RSValue(IDIdx, 1).Dev = [RS_Dev, DevICI];
                RSData(trialTypeIdx).RSValue(IDIdx, 1).Oscillation = [RS_Oscillation, SoundDuration];
                
            end
            save(strcat(MatPath, "ProcessData_RS.mat"), "RSData");
        end
    end
end
