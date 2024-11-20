function MSTIparamsAll = RLA_ParseMSTIAnesthesiaParams(ProtocolStr)

ConfigExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\RLA_MSTIAnesthesiaConfig.xlsx");

MSTIparamsAll = table2struct(readtable(ConfigExcelPATH, "Sheet", "MSTI"));
idx = find(strcmp(strcat("MSTIAnesthesia-", regexpi(ProtocolStr, '\d*\.?\d*\w-BG.*ms', 'match')), {MSTIparamsAll.ProtocolType}));

%%% update
BaseICI = cellfun(@(x) double(string(erase(regexpi(ProtocolStr, [x, '\d*\.?\d*ms'], "match"), {x, 'ms'}))), {'BG-', 'Si-', 'Sii-'});
Groups   = BaseICI([1, 2, 3;1, 3, 2]);
trainDur = double(erase(regexpi(ProtocolStr, "-\d*\.?\d*s-BG", "match"), ["-", "s-BG"]));
stimStrs = rowFcn(@(x) strcat("BG", x(1), "ms-Std", x(2), "ms-Dev", x(3), "ms"), string(Groups));

MSTIparamsAll(idx).stimStrs = join(cellfun(@(x) strrep(x, ".", "o"), stimStrs), ",");
MSTIparamsAll(idx).cursor1 = join(string(1000 ./ BaseICI(2:3)), ",");%Std-Si,Std-Sii
MSTIparamsAll(idx).cursor2 = join(string(1000 ./ [BaseICI(1), BaseICI(1)]), ",");%BG
MSTIparamsAll(idx).cursor3 = string(1 / trainDur);
writetable(struct2table(MSTIparamsAll), ConfigExcelPATH, "Sheet", "MSTI");

%% get params
MSTIparamsAll.Protocol = string(MSTIparamsAll(idx).ProtocolType);
MSTIparamsAll.stimStrs = cellfun(@(x) strrep(x, ".", "o"), stimStrs);
MSTIparamsAll.GroupTypes = cellfun(@double, ...
                                rowFcn(@(x) regexpi(x, ",", "split"), ...
                                regexpi(string(MSTIparamsAll(idx).GroupTypes), ";", "split")', "UniformOutput", false),...
                                'UniformOutput', false);
MSTIparamsAll.SoundMatIdx = double(regexpi(string(MSTIparamsAll(idx).SoundMatIdx), ",", "split"));
MSTIparamsAll.SoundMatPath = string(MSTIparamsAll(idx).SoundMatPath);
MSTIparamsAll.StdNum = double(string(MSTIparamsAll(idx).StdNum));
MSTIparamsAll.Colors = regexpi(string(MSTIparamsAll(idx).Colors), ",", "split");
MSTIparamsAll.Window = double(regexpi(string(MSTIparamsAll(idx).devonset_Window), ",", "split"));
MSTIparamsAll.ICAWindow = double(regexpi(string(MSTIparamsAll(idx).ICAWindow), ",", "split"));
MSTIparamsAll.plotWin = double(regexpi(string(MSTIparamsAll(idx).plotWindow), ",", "split"));
MSTIparamsAll.compareWin = double(regexpi(string(MSTIparamsAll(idx).compareWindow), ",", "split"));
MSTIparamsAll.FFTWin = double(regexpi(string(MSTIparamsAll(idx).FFTWindow), ",", "split"));
MSTIparamsAll.CWTplotWindow = double(regexpi(string(MSTIparamsAll(idx).CWTplotWindow), ",", "split"));
MSTIparamsAll.sigTestWin = double(regexpi(string(MSTIparamsAll(idx).sigTestWin), ",", "split"));

MSTIparamsAll.Duration = double(MSTIparamsAll(idx).Duration);
MSTIparamsAll.cursor1 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor1), ",", "split")), -1);
MSTIparamsAll.cursor2 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor2), ",", "split")), -1);
MSTIparamsAll.cursor3 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor3), ",", "split")), -1);
MSTIparamsAll.BaseICI = Groups;
MSTIparamsAll.sigTestMethod = "ttest2";
eval(strcat("MSTIparamsAll.chPlotFcn = ", string(MSTIparamsAll(idx).chPlotFcn), ";"))

end
