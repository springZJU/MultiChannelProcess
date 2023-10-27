clear; clc;

DataRootPath = "H:\MLA_A1补充\Figure\CTL_New\";
SettingParams = ["MSTI-0.3s_BaseICI-BG-3.6ms-Si-3ms-Sii-4.3ms_devratio-1.2_BGstart2s",...
                "MSTI-0.3s_BaseICI-BG-18.2ms-Si-15.2ms-Sii-21.9ms_devratio-1.2_BGstart2s"];
PSTHFFTWindow = [-5400, 0];

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
    % PSTH params
    minBaseICI = min(BaseICI, [], "all");
    psthPara.binsize = roundn(minBaseICI / 2, -1); % ms
    psthPara.binstep = 1; % ms

    for MatDirIdx = 1 : numel(MatDirsInfo)
        clear chSpikeLfp PsthFFTData;
        MatPath = strcat(MatRootPath, MatDirsInfo(MatDirIdx).name, "\");
        load(strcat(MatPath, "spkRes.mat"), "chSpikeLfp");
        
        tic;
        % Process
        for trialTypeIdx = 1 : numel(chSpikeLfp)
            trialTypeStr = chSpikeLfp(trialTypeIdx).stimStr;
            KiloSpkData = chSpikeLfp(trialTypeIdx).chSPK;
            PsthFFTData(trialTypeIdx).trialType = trialTypeStr;
            PsthFFTData(trialTypeIdx).ReDoPSTHParams = psthPara;

            for IDIdx = 1 : numel(KiloSpkData)
                clear Amp1 f1 Amp2 f2;
                IDSpikeData = chSpikeLfp(trialTypeIdx).chSPK(IDIdx).spikePlot;
                AllTrialSpikeTime = IDSpikeData(:, 1);
                AlltrialNum = unique(IDSpikeData(:, 2));

                %cal FFT-PSTH for each trial, then Mean
                PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx, 1).info = KiloSpkData(IDIdx).info;  
                for trialIdx = 1 : numel(AlltrialNum)
                    trialSpkIdx = find(AlltrialNum(trialIdx) == IDSpikeData(:, 2));
                    OneTrialSpikeTime = IDSpikeData(trialSpkIdx, 1);
                    resTemp1{trialIdx, 1} = calPsth(OneTrialSpikeTime, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', 1);
                end
                t = resTemp1{1, 1}(:, 1);                
                FFTIdx = find(t > PSTHFFTWindow(1) & t < PSTHFFTWindow(2));
                fs = length(t) / ((t(end) - t(1) + 1) / 1000);
                [Amp1, f1, ~] = cellfun(@(x) mfft(x(FFTIdx, 2), fs), resTemp1, "UniformOutput", false);
                FFTTemp = cellfun(@(x, y) [x', y'], f1, Amp1, "UniformOutput", false);
                PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx, 1).FFT = FFTTemp; 

                PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx, 1).MeanFFT(:, 1) = f1{1}';
                PsthFFTData(trialTypeIdx).PsthFFTEachTrial(IDIdx, 1).MeanFFT(:, 2) = mean(cell2mat(Amp1), 1)';                

                %cal all trials PSTH, then FFT
                TargetTrialSpikeTime = IDSpikeData(:, 1);
                resTemp2{trialTypeIdx} = calPsth(TargetTrialSpikeTime, psthPara, 1e3, 'EDGE', Window, 'NTRIAL', length(AlltrialNum));

                PSTHDataTemp2 = resTemp2{trialTypeIdx};
                t = PSTHDataTemp2(:, 1);
                PSTHLine = PSTHDataTemp2(:, 2);

                FFTIdx = find(t > PSTHFFTWindow(1) & t < PSTHFFTWindow(2));
                fs = length(t) / ((t(end) - t(1) + 1) / 1000);
                [Amp2, f2, ~] = mfft(PSTHLine(FFTIdx), fs);

                PsthFFTData(trialTypeIdx).PsthFFTAllTrials(IDIdx, 1).info = KiloSpkData(IDIdx).info;
                PsthFFTData(trialTypeIdx).PsthFFTAllTrials(IDIdx, 1).FFT(:, 1) = f2';
                PsthFFTData(trialTypeIdx).PsthFFTAllTrials(IDIdx, 1).FFT(:, 2) = Amp2';
                PsthFFTData(trialTypeIdx).PsthFFTAllTrials(IDIdx, 1).ReDoPsth = PSTHDataTemp2;

            end
        end
        toc;
        save(strcat(MatPath, "ProcessData_ReDoPsthFFT.mat"), "PsthFFTData");
    end
end
