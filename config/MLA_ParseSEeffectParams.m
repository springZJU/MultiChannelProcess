function getparams = MLA_ParseSEeffectParams(ProtocolStr)

ConfigExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_SEeffectConfig.xlsx");
SoundRootPATH = "D:\ratClickTrain\monkeySounds\";
SEparamsAll = table2struct(readtable(ConfigExcelPATH));
idx = find(strcmp(ProtocolStr, {SEparamsAll.ProtocolType}));

ChangePosition_temp = regexpi(SEparamsAll(idx).ChangePosition, ',', 'split');
ChangePosition = cell2mat(cellfun(@(x) double(string(x)), ChangePosition_temp, 'UniformOutput', false));
hasControl = SEparamsAll(idx).hasControl;

%% update
SEparamsAll(idx).Duration = string(regexpi(ProtocolStr, 'Dur(.*?)_dev', 'tokens'));
SEparamsAll(idx).Diffratio = string(regexpi(ProtocolStr, 'dev(.*?)_change', 'tokens'));
Diffratio_temp = double(regexpi(SEparamsAll(idx).Diffratio, "_", "split"));
f0_temp = regexpi(ProtocolStr, 'f0(.*?)_', 'tokens');

if contains(ProtocolStr, "Oddball", "IgnoreCase", true)
    StdNum = double(string(SEparamsAll(idx).StdNum));
    StdDuration = StdNum * 2 * double(SEparamsAll(idx).Duration);
end
if isempty(regexpi(string(f0_temp), "-", "split"))
    SEparamsAll(idx).f0 = string(f0_temp);
    f1_temp = double(f0_temp) * (1 + Diffratio_temp);
else
    f0_temp = regexpi(string(f0_temp), "-", "split");
    SEparamsAll(idx).f0 = join(f0_temp, ",");
    f1_temp = cell2mat(rowFcn(@(x) x * (1 + Diffratio_temp), double(f0_temp)', "UniformOutput", false)');
end
f0Seq = double(f0_temp);
SEparamsAll(idx).f1 = join(string(f1_temp), ",");

%change info
changeinfo_temp = string(regexpi(ProtocolStr, 'change(\d*\w{2})', 'tokens'));
changeinfo = regexp(changeinfo_temp, "\d+", "match");
if contains(changeinfo_temp, "ms", "IgnoreCase", true)
    SEparamsAll(idx).ChangeDuration = changeinfo;%ms
    SEparamsAll(idx).ChangePeriod = join(string(roundn((double(changeinfo)/1000) ./ (1 ./ f1_temp), 0)),",");
elseif contains(changeinfo_temp, "pe", "IgnoreCase", true)
    SEparamsAll(idx).ChangePeriod = changeinfo;%period
    SEparamsAll(idx).ChangeDuration = join(string((1 ./ f1_temp) * double(changeinfo) * 1000), ",");%ms
end      

DiffratioStrs_temp = regexpi(SEparamsAll(idx).Diffratio, '_', 'split');
SEparamsAll(idx).Diffratio = join(DiffratioStrs_temp, ',');
TrialTypes = [];
for f0Num = 1:numel(f0Seq)
    TrialTypesStr_temp1 = []; TrialTypesStr_temp2 = []; TrialTypesStr_temp3 = [];
    TrialTypesStr_temp1 = repmat(["f0_pos_diffratio"], numel(ChangePosition), 1);
    TrialTypesStr_temp1 = strrep(TrialTypesStr_temp1, "pos", strcat("pos", string(ChangePosition)', "ms"));
    for difflevel = 1:numel(DiffratioStrs_temp)
        TrialTypesStr_temp2 = strrep(TrialTypesStr_temp1, "diffratio", repmat(DiffratioStrs_temp(difflevel), numel(ChangePosition), 1));
        TrialTypesStr_temp3 = [TrialTypesStr_temp3; TrialTypesStr_temp2];
    end
    if double(string(hasControl)) == 1
        TrialTypesStr_temp3 = ["f0_NaN_NaN"; TrialTypesStr_temp3];
        TrialTypesStr_temp3 = strrep(TrialTypesStr_temp3, "f0", repmat(string(f0Seq(f0Num)), numel(TrialTypesStr_temp3), 1));
    else
        TrialTypesStr_temp3 = strrep(TrialTypesStr_temp3, "f0", repmat(string(f0Seq(f0Num)), numel(TrialTypesStr_temp3), 1));
    end
    TrialTypes = [TrialTypes; TrialTypesStr_temp3];
end
SEparamsAll(idx).stimStrs = join(TrialTypes', ",");

% load soundinfo
if SEparamsAll(idx).loadSoundchoice == 1 && ~isempty(SEparamsAll(idx).SoundPath)
    if contains(ProtocolStr, "Oddball", "IgnoreCase", true)
        SoundPATH = strcat(SoundRootPATH, SEparamsAll(idx).SoundPath, "\Oddball_FreqLoc\fs", string(f0Seq(1)), "\SoundSequence.mat");
    elseif contains(ProtocolStr, "Single", "IgnoreCase", true)
        SoundPATH = strcat(SoundRootPATH, SEparamsAll(idx).SoundPath, "\Single_FreqLoc\fs", string(f0Seq(1)), "\SoundSequence.mat");            
    end
    load(SoundPATH);
    if ~isnan(SEparamsAll(idx).SoundInDirIdx) && SEparamsAll(idx).SoundInDirIdx ~= 0
        SoundNum = SEparamsAll(idx).SoundInDirIdx;
        ChangeTime = {soundinfo(SoundNum).changestage}';
    else
        ChangeTime = {soundinfo.changestage}';
    end
    ChangeTime = cellfun(@(x) x(1), ChangeTime);

else
    pos_temp = cellfun(@(x) regexpi(x(2), "\d+(\.?)\d*", "match"), regexpi(TrialTypes, "_", "split"), "UniformOutput", false);
    pos_temp(cellfun(@isempty, pos_temp)) = {"0"};
    pos_temp = cellfun(@double, pos_temp);
    ChangePosition = pos_temp;
    if contains(ProtocolStr, "Oddball", "IgnoreCase", true)
        ChangeTime = ChangePosition + StdDuration;
    elseif contains(ProtocolStr, "Single", "IgnoreCase", true)
        ChangeTime = ChangePosition;
    end

end
writetable(struct2table(SEparamsAll), ConfigExcelPATH);

%% get params
SEeffectparams = SEparamsAll(idx);
SEeffectparams.ChangeTime = ChangeTime;
if contains(ProtocolStr, "Oddball", "IgnoreCase", true)
    SEeffectparams.StdDuration = StdDuration;
end

parseStruct(SEeffectparams);
getparams.plotMMN = double(string(plotMMN));
getparams.colors = regexpi(string(colors), ',', 'split');
getparams.Window = double(regexpi(string(trialonset_Window), ',', 'split'));
getparams.ICAWindow = double(regexpi(string(ICAWindow), ',', 'split'));
getparams.plotWindow = double(regexpi(string(plotWindow), ',', 'split'));
getparams.compareWindow = double(regexpi(string(compareWindow), ',', 'split'));
getparams.CWTplotWindow = double(regexpi(string(CWTplotWindow), ',', 'split'));
getparams.sigTestWin = double(regexpi(string(sigTestWin), ',', 'split'));
getparams.Diffratio = double(regexpi(string(Diffratio), ',', 'split'));
getparams.GroupTypes = cellfun(@double, rowFcn(@(x) regexpi(x, ',', 'split'), regexpi(string(GroupTypes), ';', 'split')', ...
    "UniformOutput", false), "UniformOutput", false);
getparams.ChangeTime = ChangeTime;
getparams.stimStrs = TrialTypes;
getparams.chPlotFcn = eval(chPlotFcn);
getparams.sigTestMethod = "ttest2";
if isempty(regexpi(string(f0), ",", "split"))
    getparams.f0 = double(f0);
else
    getparams.f0 = double(regexpi(f0, ",", "split"));
end

if exist('StdDuration', 'var') 
    getparams.StdDuration = StdDuration;
end

end
