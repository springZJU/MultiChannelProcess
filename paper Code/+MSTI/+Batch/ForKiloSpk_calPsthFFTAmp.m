clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-14ms-Si-11.7ms-Sii-16.8ms_devratio-1.2_BGstart2s"];
Area = ["AC", "MGB"];

%%
for SettingParamIdx = [3]%1 : numel(SettingParams)
    % load .mat 
    MatRootPath = strcat(DataRootPath, SettingParams(SettingParamIdx), "\");
    MatDirsInfo = dir(MatRootPath);
    MatDirsInfo(~(contains(string({MatDirsInfo.name}'), "cm") | contains(string({MatDirsInfo.name}'), "ddz"))) = [];
    % load params
    MSTIParams = MLA_ParseMSTIParams(SettingParams(SettingParamIdx));
    parseStruct(MSTIParams);
    n = 0;
    PsthFFTAmpData = [];

    for AreaIdx = 1%1 : numel(Area)
        TargetArea = Area(AreaIdx);
        TargetDirIdx = find(contains(string({MatDirsInfo.name}'), TargetArea));
        for MatDirIdx = 1 : numel(TargetDirIdx)
            clear ProcessPsthFFTData;
            SonDirName = MatDirsInfo(TargetDirIdx(MatDirIdx)).name;
            NameTemp = strsplit(SonDirName, "_");
            Date = NameTemp{1};
            Position = NameTemp{2};
            AreaInfo = NameTemp{3};
            MatPath = strcat(MatRootPath, SonDirName, "\");
            ProcessPsthFFTData = load(strcat(MatPath, "ProcessData_ReDoPsthFFT.mat"), "PsthFFTData");
            
            for IDIdx = 1 : numel(ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial)
                n = n + 1;
                PsthFFTAmpData(n).Date = Date;
                PsthFFTAmpData(n).Position = Position;
                PsthFFTAmpData(n).Area = AreaInfo;
                PsthFFTAmpData(n).ID = ProcessPsthFFTData.PsthFFTData(1).PsthFFTEachTrial(IDIdx).info;
                for trialTypeIdx = 1 : numel(ProcessPsthFFTData.PsthFFTData)
                    trialTypeStr = ProcessPsthFFTData.PsthFFTData(trialTypeIdx).trialType;
                    trialTypeStrTemp = strrep(trialTypeStr, "o", ".");
                    PsthFFTAmpData(n).MeanTargetFFTAmp(trialTypeIdx, 1).trialtype = trialTypeStr;
                    PsthFFTAmpData(n).EachTrialTargetFFTAmp(trialTypeIdx, 1).trialtype = trialTypeStr;

                    BGICI =  double(string(regexpi(trialTypeStrTemp, "BG(\d*\.?\d*)ms", "tokens")));
                    StdICI =  double(string(regexpi(trialTypeStrTemp, "Std(\d*\.?\d*)ms", "tokens")));
                    ICISeq = [BGICI, StdICI];
                    InterestFreq = [1000 ./ BGICI, 1000 / 300];

                    % calculate FFT Power
                    MeanFFTFreq = ProcessPsthFFTData.PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx).MeanFFT(:, 1);                    
                    MeanFFTAmp = ProcessPsthFFTData.PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx).MeanFFT(:, 2);       
                    [MeanInterestAmp, ~]  = MSTI.tool.calFFTAmp(InterestFreq, MeanFFTAmp, MeanFFTFreq);
                    PsthFFTAmpData(n).MeanTargetFFTAmp(trialTypeIdx, 1).value = MeanInterestAmp;

                    FFTTemp_EachTrial = ProcessPsthFFTData.PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx).FFT;                    
                    [EachTrialInterestAmp, Ampinfo] = cellfun(@(x) MSTI.tool.calFFTAmp(InterestFreq, x(:, 2), x(:, 1)), FFTTemp_EachTrial, "UniformOutput", false);
                    PsthFFTAmpData(n).EachTrialTargetFFTAmp(trialTypeIdx, 1).value = Ampinfo;

                end 
                PsthFFTAmpData(n).ClickFFT = mean(cellfun(@(x) x(1), [PsthFFTAmpData(n).MeanTargetFFTAmp(1).value(1); PsthFFTAmpData(n).MeanTargetFFTAmp(2).value(1)])); % Background ICI             
                PsthFFTAmpData(n).ClickTrainFFT = mean(cellfun(@(x) x(1), [PsthFFTAmpData(n).MeanTargetFFTAmp(1).value(2); PsthFFTAmpData(n).MeanTargetFFTAmp(2).value(2)]));
                % significant test
                TestData = cellfun(@(x) x{1}, [num2cell(PsthFFTAmpData(n).EachTrialTargetFFTAmp(1).value); num2cell(PsthFFTAmpData(n).EachTrialTargetFFTAmp(2).value)],...
                    "UniformOutput", false);
                ClickFFTRes = cellfun(@(x) [x{1}(1), x{2}(1)], TestData, "UniformOutput", false);%col1:test;col2:baseline;
                ClickTrainFFTRes = cellfun(@(x) [x{3}(1), x{4}(1)], TestData, "UniformOutput", false);
                [h_ClickFFT, p_value_ClickFFT] = ttest(cellfun(@(x) x(1), ClickFFTRes), cellfun(@(x) x(2), ClickFFTRes), "Tail", "right");
                [h_ClickTrainFFT, p_value_ClickTrainFFT] = ttest(cellfun(@(x) x(1), ClickTrainFFTRes), cellfun(@(x) x(2), ClickTrainFFTRes), "Tail", "right");
                
                PsthFFTAmpData(n).sigClickFFT = h_ClickFFT; PsthFFTAmpData(n).pvalueClickFFT = p_value_ClickFFT;
                PsthFFTAmpData(n).sigClickTrainFFT = h_ClickTrainFFT; PsthFFTAmpData(n).pvalueClickTrainFFT = p_value_ClickTrainFFT;

            end
            
        end

    end

    save(strcat(MatRootPath, "PopData_PsthFFTAmp.mat"), "PsthFFTAmpData", "-mat");
end



