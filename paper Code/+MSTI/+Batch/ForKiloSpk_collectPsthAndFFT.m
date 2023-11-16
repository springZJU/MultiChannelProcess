clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
%%
for SettingIdx = 1 : numel(SettingParams)
    % load spkRes.mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    % load Params Setting
    protStr = SettingParams(SettingIdx);
    MSTIParams = MLA_ParseMSTIParams(protStr);
    parseStruct(MSTIParams);
    PsthData = [];
    n = 0;
    for MatDirIdx = 1 : numel(MatDirsInfo)
        clear chSpikeLfp;
        SonDirName = MatDirsInfo(MatDirIdx).name;
        NameTemp = strsplit(SonDirName, "_");
        Date = NameTemp{1};
        Position = NameTemp{2};
        AreaInfo = NameTemp{3};
        MatPath = strcat(MatRootPath, SonDirName, "\");
        load(strcat(MatPath, "spkRes.mat"), "chSpikeLfp");
        load(strcat(MatPath, "ProcessData_ReDoPsthFFT.mat"), "PsthFFTData");
        for IDIdx = 1 : numel(chSpikeLfp(1).chSPK)
            n = n + 1;
            PsthData(n).Date = Date;
            PsthData(n).Position = Position;
            PsthData(n).Area = AreaInfo;
            for trialTypeIdx = 1 : numel(chSpikeLfp)
                trialTypeStr = chSpikeLfp(trialTypeIdx).stimStr;
                KiloSpkData = chSpikeLfp(trialTypeIdx).chSPK;
                FFTPsthData = PsthFFTData(trialTypeIdx).PsthFFTEachTrial;

                PsthData(n).ID = KiloSpkData(IDIdx).info;
                PsthData(n).rawPsth(trialTypeIdx).Trialtype = trialTypeStr;
                PsthData(n).rawPsth(trialTypeIdx).RawPsth = KiloSpkData(IDIdx).PSTH;
                PsthData(n).fftPsth(trialTypeIdx).Trialtype = trialTypeStr;
                PsthData(n).fftPsth(trialTypeIdx).MeanFFTPsth = FFTPsthData(IDIdx).MeanFFT;
                
            end
        end
    end
    save(strcat(MatRootPath, "popData_RawPsthAndFFT.mat"), "PsthData");
end
