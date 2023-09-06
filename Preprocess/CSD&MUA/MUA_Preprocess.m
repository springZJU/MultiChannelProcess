function [trialAll, WaveDataset] = MUA_Preprocess(MATPATH)
%% Parameter settings
processFcn = @PassiveProcess_NoiseTone;

%% Validation
if isempty(processFcn)
    error("Process function is not specified");
end

%% Loading data
try
    disp("Try loading data from MAT");
    load(MATPATH);
    WaveDataset = data.Wave;
    epocs = data.epocs;
    trialAll = processFcn(epocs);
catch e
    disp(e.message);
    disp("Try loading data from TDT BLOCK...");
    rmpath("D:\LAB\RatNeuroPixels\utils\data process\load data");
    try
        BLOCKPATH = MLA_GetMatBlock(MATPATH);
    catch
        BLOCKPATH = MATPATH;
    end
    temp = TDTbin2mat(char(BLOCKPATH), 'TYPE', {'epocs'});
    epocs = temp.epocs;
    trialAll = processFcn(epocs);
    temp = TDTbin2mat(char(BLOCKPATH), 'TYPE', {'streams'}, 'STORE', 'Wave');
    streams = temp.streams;
    WaveDataset = streams.Wave;
end
return;
end