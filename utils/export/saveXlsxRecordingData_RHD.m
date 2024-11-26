function saveXlsxRecordingData_RHD(ROOTPATH, recordInfo, idx, recordPath, fd_lfp, fd_mua)
narginchk(4, 6);
if nargin < 5
    fd_lfp = 600;
end
if nargin < 6
    fd_mua = 1000;
end
BLOCKPATH = recordInfo(idx).BLOCKPATH;
sitePos = recordInfo(idx).sitePos;
depth = recordInfo(idx).depth;
paradigm = recordInfo(idx).paradigm;
spkExported = logical(recordInfo(idx).spkExported);
lfpExported = logical(recordInfo(idx).lfpExported);
temp = strsplit(BLOCKPATH, "\");
animalID = temp(end - 2);
dateStr = temp(end - 1);
buffer=TDTbin2mat(char(BLOCKPATH), 'TYPE',{'epocs'});  %spike store name should be changed according to your real name

%% TTL synchronization
SR = recordInfo(idx).SR_AP;
TTL_Path = strcat(recordInfo(idx).datPath, "\TTL.mat");
LFP_Path = strcat(recordInfo(idx).datPath, "\rawWave.dat");
load(TTL_Path);
sample_times = (1:length(board_dig_in_data))'/SR;
TTL_Onset = sample_times(find(diff(board_dig_in_data) == 1)+1);


if length(TTL_Onset) == length(buffer.epocs.Swep.onset)
    delta_T = mean(diff([buffer.epocs.Swep.onset, TTL_Onset], 1, 2));
elseif isfield(buffer.epocs, "ordr")
    if length(TTL_Onset) == length(buffer.epocs.ordr.onset)
        delta_T = mean(diff([buffer.epocs.ordr.onset, TTL_Onset], 1, 2));
    end
else
    keyboard;
    isContinue = input('continue? y/n \n', 's');
    if strcmpi(isContinue, "n")
        error("the TTL sync signal does not match the TDT epocs [Swep] store!");
    else %% custom
        delta_T = mean(diff([buffer.epocs.Swep.onset(1:end), TTL_Onset(1:end)], 1, 2));
        %         delta_T = mean(buffer.epocs.Swep.onset) - mean(TTL_Onset);

        % delta_T = 0;
    end
end

%% try to get epocs
try
    data.epocs  = rewriteEpocsTime(buffer.epocs, delta_T);
catch e
    data.epocs = [];
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

data.SR_AP = SR;

%% try to get lfp data
try
    data.lfp = RHD2TDT_LFP(LFP_Path, SR, fd_lfp);
catch e
    data.lfp = [];
    disp(e.message);
end

%% try to get MUA
% try
costomInfo = evalin("base", "customInfo");
if costomInfo.ExportMUA
    data.mua = RHD2TDT_MUA(LFP_Path, SR, fd_mua);
else
    data.mua = [];
end
% catch e
%     data.mua = [];
%     disp(e.message);
% end


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
SAVEPATH = strcat(ROOTPATH, "\", animalID, "\CTL_New\", paradigm, "\", dateStr, "_", sitePos);

mkdir(SAVEPATH);
dataCopy = data;
if ~spkExported || getOr(evalin("base", "customInfo"), "ReSaveMAT", false)
    data = rmfield(dataCopy, ["lfp", "Wave", "mua"]);
    save(fullfile(SAVEPATH, "spkData.mat"), "data", "-v7.3");
    recordInfo(idx).spkExported = 1;
end

if ~lfpExported || getOr(evalin("base", "customInfo"), "ReSaveMAT", false)
    data = rmfield(dataCopy, ["sortdata", "mua"]);
    save(fullfile(SAVEPATH, "lfpData.mat"), "data", "-v7.3");
    data = rmfield(dataCopy, ["sortdata", "lfp", "Wave"]);
    save(fullfile(SAVEPATH, "muaData.mat"), "data", "-v7.3");
    recordInfo(idx).lfpExported = 1;
end

writetable(struct2table(recordInfo), recordPath);

end
