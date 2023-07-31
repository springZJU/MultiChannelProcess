function saveXlsxRecordingData_RatNP(ROOTPATH, recordInfo, idx, recordPath, fd_lfp)
narginchk(4, 5);
if nargin < 5
    fd_lfp = 1200;
end

BLOCKPATH = recordInfo(idx).BLOCKPATH;
sitePos = recordInfo(idx).sitePos;
depth = recordInfo(idx).depth;
paradigm = recordInfo(idx).paradigm;
temp = strsplit(BLOCKPATH, "\");
animalID = temp(end - 2);
dateStr = temp(end - 1);
buffer=TDTbin2mat(char(BLOCKPATH));  %spike store name should be changed according to your real name

%% TTL synchronization
SR_AP = recordInfo(idx).SR_AP;
SR_LFP = recordInfo(idx).SR_LFP;
NP_Path = strcat(recordInfo(idx).datPath, "\", recordInfo(idx).hardware, "-AP");
LFP_Path = strcat(recordInfo(idx).datPath, "\", recordInfo(idx).hardware, "-LFP");
sample_numbers = readNPY(strcat(NP_Path, "\sample_numbers.npy"));
sample_times = (1:length(sample_numbers))'/SR_AP;
mmf = memmapfile(strcat(NP_Path, "\continuous.dat"),'Format', {"int16", [385 length(sample_numbers)], 'x'});
TTL = mmf.Data.x(end, :);
TTL_Onset = sample_times([0, diff(TTL)] > 0);
if length(TTL_Onset) == length(buffer.epocs.Swep.onset)
    delta_T = mean(diff([buffer.epocs.Swep.onset, TTL_Onset], 1, 2));
else
    keyboard;
    isContinue = input('continue? y/n \n', 's');
    if strcmpi(isContinue, "n")
        error("the TTL sync signal does not match the TDT epocs [Swep] store!");
    else %% custom
        delta_T = mean(diff([buffer.epocs.ordr.onset, TTL_Onset], 1, 2));
    end
end

%% try to get epocs
try
    data.epocs  = rewriteEpocsTime(buffer.epocs, delta_T);
catch e
    disp(e.message);
end

%% try to get sort data
% sort data
SORTPATH = fullfile(BLOCKPATH, "sortdata.mat");
try
    load(SORTPATH);
    data.sortdata = sortdata;
catch e
    disp(e.message);
end

% spike waveform
try
    data.spkWave = spkWave;
catch e
    disp(e.message);
end
%% try to get lfp data
try
   data.lfp = NP2TDT_LFP(LFP_Path, SR_LFP, fd_lfp);
catch e
    disp(e.message);
end

%% try to get Wave data for CSD
if contains(paradigm, 'CSD')
    try 
        data.Wave = buffer.streams.Wave;
    catch e
        disp(e.message);
    end
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
SAVEPATH = strcat(ROOTPATH, "\", animalID, "\CTL_New\", paradigm, "\", dateStr, "_", sitePos);

mkdir(SAVEPATH);
save(fullfile(SAVEPATH, "data.mat"), "data", "-v7.3");
recordInfo(idx).exported = 1;

writetable(struct2table(recordInfo), recordPath);

end
