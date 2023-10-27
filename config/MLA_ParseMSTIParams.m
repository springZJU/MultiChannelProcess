function MSTIparams = MLA_ParseMSTIParams(ProtocolStr)

ConfigExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIConfig.xlsx");
SoundRootPATH = "D:\ratClickTrain\monkeySounds\";
MSTIparamsAll = table2struct(readtable(ConfigExcelPATH, "Sheet", "MSTI"));
idx = find(strcmp(ProtocolStr, {MSTIparamsAll.ProtocolType}));

%% update
temp = regexpi(string(ProtocolStr), "_", "split");
DurationInfo = cell2mat(cellfun(@(x) double(string(x)), regexpi(temp(1), "\d*\.?\d*", "match"), 'UniformOutput', false));
BaseICI = cell2mat(cellfun(@(x) double(string(x)), regexpi(temp(2), "\d*\.?\d*", "match"), 'UniformOutput', false));
Groups = [BaseICI(1), BaseICI(2), BaseICI(3); BaseICI(1), BaseICI(3), BaseICI(2)];%1:BG 2:ICI1 3:ICI2
stimStrs = rowFcn(@(x) strcat("BG", x(1), "ms-Std", x(2), "ms-Dev", x(3), "ms"), string(Groups));
for comparenum = 1:numel(stimStrs)
    MMNcompare(comparenum).sound = regexpi(stimStrs(comparenum), "Std(.*?)ms", "match");
    MMNcompare(comparenum).StdOrder_Lagidx = find(contains(stimStrs, MMNcompare(comparenum).sound) == 1);
    MMNcompare(comparenum).DevOrder = find(contains(stimStrs, strrep(MMNcompare(comparenum).sound, "Std", "Dev")) == 1);
end
MSTIparamsAll(idx).stimStrs = join(cellfun(@(x) strrep(x, ".", "o"), stimStrs), ",");
MSTIparamsAll(idx).Duration = string(DurationInfo(1) * 1000);
MSTIparamsAll(idx).cursor1 = join(string(1000 ./ BaseICI(2:3)), ",");%Std-Si,Std-Sii
MSTIparamsAll(idx).cursor2 = join(string(1000 ./ [BaseICI(1), BaseICI(1)]), ",");%BG
MSTIparamsAll(idx).cursor3 = string(1 / DurationInfo(1));
writetable(struct2table(MSTIparamsAll), ConfigExcelPATH, "Sheet", "MSTI");

%% get params
MSTIparams.Protocol = string(MSTIparamsAll(idx).ProtocolType);
MSTIparams.stimStrs = cellfun(@(x) strrep(x, ".", "o"), stimStrs);
MSTIparams.Colors = regexpi(string(MSTIparamsAll(idx).Colors), ",", "split");
MSTIparams.GroupTypes = cellfun(@double, ...
                                rowFcn(@(x) regexpi(x, ",", "split"), ...
                                regexpi(string(MSTIparamsAll(idx).GroupTypes), ";", "split")', "UniformOutput", false),...
                                'UniformOutput', false);
MSTIparams.SoundMatIdx = double(regexpi(string(MSTIparamsAll(idx).SoundMatIdx), ",", "split"));
MSTIparams.SoundMatPath = string(MSTIparamsAll(idx).SoundMatPath);
MSTIparams.trialonset_Win = double(regexpi(string(MSTIparamsAll(idx).trialonset_Window), ",", "split"));
MSTIparams.Window = double(regexpi(string(MSTIparamsAll(idx).devonset_Window), ",", "split"));
MSTIparams.ICAWindow = double(regexpi(string(MSTIparamsAll(idx).ICAWindow), ",", "split"));
MSTIparams.plotWin = double(regexpi(string(MSTIparamsAll(idx).plotWindow), ",", "split"));
MSTIparams.compareWin = double(regexpi(string(MSTIparamsAll(idx).compareWindow), ",", "split"));
MSTIparams.FFTWin = double(regexpi(string(MSTIparamsAll(idx).FFTWindow), ",", "split"));
MSTIparams.CWTplotWindow = double(regexpi(string(MSTIparamsAll(idx).CWTplotWindow), ",", "split"));
MSTIparams.sigTestWin = double(regexpi(string(MSTIparamsAll(idx).sigTestWin), ",", "split"));

MSTIparams.Duration = double(MSTIparamsAll(idx).Duration);
MSTIparams.cursor1 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor1), ",", "split")), -1);
MSTIparams.cursor2 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor2), ",", "split")), -1);
MSTIparams.cursor3 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor3), ",", "split")), -1);
MSTIparams.BaseICI = Groups;
MSTIparams.sigTestMethod = "ttest2";
eval(strcat("MSTIparams.chPlotFcn = ", string(MSTIparamsAll(idx).chPlotFcn), ";"))

load(strcat(SoundRootPATH, MSTIparams.SoundMatPath, "\MMNSequence.mat"));
MSTIparams.MSTIsoundinfo = RegMMNSequence(1, 1:2);
MSTIparams.MMNcompare = MMNcompare;

end
