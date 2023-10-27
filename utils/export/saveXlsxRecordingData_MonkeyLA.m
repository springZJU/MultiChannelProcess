function saveXlsxRecordingData_MonkeyLA(ROOTPATH, recordInfo, idx, recordPath, fd_lfp)
e = [];
narginchk(4, 5);
if nargin < 5
    fd_lfp = 1200;
end
BLOCKPATH = char(recordInfo(idx).BLOCKPATH);
sitePos = recordInfo(idx).sitePos;
depth = recordInfo(idx).depth;
paradigm = recordInfo(idx).paradigm;
spkExported = logical(recordInfo(idx).spkExported);
lfpExported = logical(recordInfo(idx).lfpExported);
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

%% try to get sort data
% sort data
SORTPATH = fullfile(BLOCKPATH, "sortdata.mat");
try
    load(SORTPATH);
    data.sortdata = sortdata;
catch e
    data.sortdata = [];
    disp(e.message);
end

% spike waveform
try
    data.spkWave = spkWave;
catch e
    data.spkWave = [];
    disp(e.message);
end
%% try to get lfp data
try
    data.lfp = ECOGResample(buffer.streams.Llfp, fd_lfp);
catch e
    data.lfp = [];
    disp(e.message);
end

%% try to get Wave data for CSD
if contains(paradigm, 'CSD')
    try 
        data.Wave = buffer.streams.Wave;
    catch e
        data.Wave = [];
        disp(e.message);
    end
else
    data.Wave = [];
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
customInfo = evalin("base", "customInfo");
if ~spkExported || customInfo.ReSaveMAT
    data = rmfield(dataCopy, ["lfp", "Wave"]);
    save(fullfile(SAVEPATH, "spkData.mat"), "data", "-mat");
    recordInfo(idx).spkExported = 1;
end
if ~lfpExported || customInfo.ReSaveMAT
    data = rmfield(dataCopy, ["spikeRaw", "sortdata", "spkWave"]);
    save(fullfile(SAVEPATH, "lfpData.mat"), "data", "-mat");
    recordInfo(idx).lfpExported = 1;
end
    writetable(struct2table(recordInfo), recordPath);


end
