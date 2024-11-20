
BLOCKPATH = "H:\SPR Paper\Intrinsic Temporal Scale\TANK\ratBXH\ratB20231123\Block-26";
sitePos = "Site1";
depth = "Depth1";
paradigm = "Intrinsic";
spkExported = 0;
lfpExported = 0;
temp = strsplit(BLOCKPATH, "\");
animalID = temp{end - 2};
dateStr = temp{end - 1};

buffer=TDTbin2mat(char(BLOCKPATH));  %spike store name should be changed according to your real name
%% try to get epocs
try
    data.epocs = buffer.epocs;
catch e
    data.epocs = [];
    disp(e.message);
end

%% try to get raw spike data
try
    data.spikeRaw.snips = buffer.snips;
catch e
    data.spikeRaw = [];
    disp(e.message);
end

%% try to get lfp data
try
    data.lfp = ECOGResample(buffer.streams.Llfp, fd_lfp);
catch e
    data.lfp = [];
    disp(e.message);
end



%% save params
params.BLOCKPATH = BLOCKPATH;
params.paradigm = paradigm;
params.sitePos = sitePos;
params.depth = depth;
params.animalID = animalID;
params.dateStr = dateStr;
data.params = params;

%% export result
if contains(paradigm, ["PEOdd7-10_Active", "PEOdd7-10_Passive"])
    SAVEPATH = strcat(ROOTPATH, animalID, "\PEOdd_Behavior\", paradigm, "\", dateStr, "_", sitePos);
else
    SAVEPATH = strcat(ROOTPATH, animalID, "\CTL_New\", paradigm, "\", dateStr, "_", sitePos);
end
mkdir(SAVEPATH);
dataCopy = data;
data = rmfield(dataCopy, ["lfp", "Wave"]);
save(fullfile(SAVEPATH, "spkData.mat"), "data", "-mat");


data = rmfield(dataCopy, ["spikeRaw", "sortdata", "spkWave"]);
save(fullfile(SAVEPATH, "lfpData.mat"), "data", "-mat");




