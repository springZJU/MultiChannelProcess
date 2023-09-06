function MSTIparams = MLA_ParseTITSParams(ProtocolStr)

ConfigExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIConfig.xlsx");
SoundRootPATH = "D:\ratClickTrain\monkeySounds\";
MSTIparamsAll = table2struct(readtable(ConfigExcelPATH, "Sheet", "Insert"));
idx = find(strcmp(ProtocolStr, {MSTIparamsAll.ProtocolType}));

%% update
temp = regexpi(string(ProtocolStr), "_", "split");
Ratio = cell2mat(cellfun(@(x) double(string(x)), regexpi(temp(3), "\d*\.?\d*", "match"), 'UniformOutput', false));
BaseICI = cell2mat(cellfun(@(x) double(string(x)), regexpi(temp(2), "\d*\.?\d*", "match"), 'UniformOutput', false));
InsertNum = double(strsplit(strrep(temp(4), "N", ""), "-"));
stimStrs = ["N0", rowFcn(@(x) strcat("N", x), string(InsertNum'))'];

MSTIparamsAll(idx).stimStrs = join(stimStrs, ",");
writetable(struct2table(MSTIparamsAll), ConfigExcelPATH);

%% get params
MSTIparams.Protocol = string(MSTIparamsAll(idx).ProtocolType);
MSTIparams.S1Duration = double(MSTIparamsAll(idx).S1Duration);
MSTIparams.stimStrs = regexpi(string(MSTIparamsAll(idx).stimStrs), ",", "split");
MSTIparams.Colors = regexpi(string(MSTIparamsAll(idx).Colors), ",", "split");
MSTIparams.GroupTypes = cellfun(@double, ...
                                rowFcn(@(x) regexpi(x, ",", "split"), ...
                                regexpi(string(MSTIparamsAll(idx).GroupTypes), ";", "split")', "UniformOutput", false),...
                                'UniformOutput', false);
MSTIparams.Window = double(regexpi(string(MSTIparamsAll(idx).devonset_Window), ",", "split"));
MSTIparams.ICAWindow = double(regexpi(string(MSTIparamsAll(idx).ICAWindow), ",", "split"));
MSTIparams.plotWin = double(regexpi(string(MSTIparamsAll(idx).plotWindow), ",", "split"));
MSTIparams.compareWin = double(regexpi(string(MSTIparamsAll(idx).compareWindow), ",", "split"));
MSTIparams.FFTWin = double(regexpi(string(MSTIparamsAll(idx).FFTWindow), ",", "split"));
MSTIparams.sigTestWin = double(regexpi(string(MSTIparamsAll(idx).sigTestWin), ",", "split"));
MSTIparams.BaseICI = BaseICI;
MSTIparams.sigTestMethod = "ttest2";
MSTIparams.Ratio = Ratio;
eval(strcat("MSTIparams.chPlotFcn = ", string(MSTIparamsAll(idx).chPlotFcn), ";"))

end
