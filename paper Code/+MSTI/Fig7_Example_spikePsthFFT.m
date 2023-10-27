clear; clc;
DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";

SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
Area = "AC";

% For plot
colors = ["b", "r"];
SubRowNum = 2;% R1:BG-3.6ms-Si-3ms-Sii-4.3ms; R2:BG-18.2ms-Si-15.2ms-Sii-21.9ms;
SubColNum = 3;% C1:local--PsthFFT; C2:global--PsthFFT; C3:Compare Std and Dev;

%% load spkRes.mat 
for SettingParamIdx = 1 : numel(SettingParams)
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);
    if contains(SettingParams(SettingParamIdx), "BG-3.6ms-Si-3ms-Sii-4.3ms", "IgnoreCase", true)
        kiloID = 8;
        AnimalName = "cm"; % "cm", "ddz"
        Date = "20230901";
        Position = "A46R18";
    
    elseif contains(SettingParams(SettingParamIdx), "BG-18.2ms-Si-15.2ms-Sii-21.9ms", "IgnoreCase", true)
        kiloID = 9;% or "cm20230901_A47R18_kiloID7", "ddz20230906_A48R15_kiloID12"
        AnimalName = "cm"; % "cm", "ddz"
        Date = "20230831";   
        Position = "A48R18";

    end
    SonDirName = strcat(AnimalName, Date, "_", Position, "_", Area, "\");
    MatPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\", SonDirName);
    load(strcat(MatPath, "ProcessData_PsthFFT.mat"));

    %% Plot
    if SettingParamIdx == 1
        posIdx = [1, 2, 3];
    elseif SettingParamIdx == 2
        posIdx = [4, 5, 6];
    end

    for subAxesIdx = 1 : numel(posIdx)    
        Axes(SettingParamIdx, subAxesIdx) = mSubplot(SubRowNum, SubColNum, posIdx(subAxesIdx), [1, 1]);
        if subAxesIdx == 1 | subAxesIdx == 2 % C1:local--PsthFFT; C2:global--PsthFFT;
            for lineIdx = 1 : numel(PsthFFTData)
                AllID = string({PsthFFTData(lineIdx).PsthFFT.info}');
                IDIdx = find(contains(AllID, string(kiloID)));
                X = PsthFFTData(lineIdx).PsthFFT(IDIdx).FFT(:, 1);
                Y = PsthFFTData(lineIdx).PsthFFT(IDIdx).FFT(:, 2);
                plot(X, Y, "LineWidth", 2, "Color", colors(lineIdx)); hold on;
            end
        elseif subAxesIdx == 3 % C3:Compare Std and Dev;
            for lineIdx = 1 : numel(PsthFFTData)
                AllID = string({PsthFFTData(lineIdx).PsthFFT.info}');
                IDIdx = find(contains(AllID, string(kiloID)));
                X = PsthFFTData(lineIdx).PsthFFT(IDIdx).rawPsth(:, 1);
                Y = PsthFFTData(lineIdx).PsthFFT(IDIdx).rawPsth(:, 2);
                plot(X, Y, "LineWidth", 2, "Color", colors(lineIdx)); hold on;
            end    
        end  
    end
    %scales
    scaleAxes(Axes(SettingParamIdx, 1), "x", [1000/max(BaseICI, [], "all"), 1000/min(BaseICI, [], "all")]);  
    scaleAxes(Axes(SettingParamIdx, 2), "x", [0, 8]);
    scaleAxes(Axes(SettingParamIdx, 3), "x", compareWin);
    %addlines

end

