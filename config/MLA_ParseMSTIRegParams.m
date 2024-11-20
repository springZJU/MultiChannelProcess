function MSTIparamsAllGet = MLA_ParseMSTIRegParams(ProtocolStr)

ConfigExcelPATH = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIRegConfig.xlsx");

MSTIparamsAll = table2struct(readtable(ConfigExcelPATH, "Sheet", "MSTI"));
idx = find(strcmp(ProtocolStr, {MSTIparamsAll.ProtocolType}));

% %% update
% temp = regexpi(string(ProtocolStr), "_", "split");
% DurationInfo = cell2mat(cellfun(@(x) double(string(x)), regexpi(temp(1), "\d*\.?\d*", "match"), 'UniformOutput', false));
BaseICI = cellfun(@(x) double(string(erase(regexpi(ProtocolStr, [x, '\d*\.?\d*ms'], "match"), {x, 'ms'}))), {'BG-', 'Si-', 'Sii-'});
Groups   = BaseICI([1, 2, 3; 1, 2, 3; 1, 3, 2; 1, 3, 2]);
regType  = ["Reg-"; "Irreg-"; "Reg-"; "Irreg-"]; 
trainDur = double(erase(regexpi(ProtocolStr, "-\d*\.?\d*s-BG", "match"), ["-", "s-BG"]));
stimStrs = rowFcn(@(x, y) strcat(y, "BG", x(1), "ms-Std", x(2), "ms-Dev", x(3), "ms"), string(Groups), regType);

MSTIparamsAll(idx).stimStrs = join(cellfun(@(x) strrep(x, ".", "o"), stimStrs), ",");
MSTIparamsAll(idx).cursor1 = join(string(1000 ./ BaseICI(2:3)), ",");%Std-Si,Std-Sii
MSTIparamsAll(idx).cursor2 = join(string(1000 ./ [BaseICI(1), BaseICI(1)]), ",");%BG
MSTIparamsAll(idx).cursor3 = string(1 / trainDur);
writetable(struct2table(MSTIparamsAll), ConfigExcelPATH, "Sheet", "MSTI");

for comparenum = 1:numel(stimStrs)
    Regtype = regexpi(stimStrs(comparenum), ".*REG", "match");
    Oddtype = regexpi(stimStrs(comparenum), "Std(.*?)ms", "match");
    MSTIparamsAll(idx).MMNcompare(comparenum).sound = strjoin([Regtype, Oddtype], "-");
    MSTIparamsAll(idx).MMNcompare(comparenum).StdOrder_Lagidx = find(contains(stimStrs, regexpi(stimStrs(comparenum), "Std(.*?)ms", "match")) & ...
                                                 cellfun(@(x) isequal(x, 1), regexpi(stimStrs, regexpi(stimStrs(comparenum), Regtype, "match"), "start")));
    MSTIparamsAll(idx).MMNcompare(comparenum).DevOrder = find(contains(stimStrs, strrep(regexpi(stimStrs(comparenum), "Std(.*?)ms", "match"), "Std", "Dev")) & ...
                                           cellfun(@(x) isequal(x, 1), regexpi(stimStrs, regexpi(stimStrs(comparenum), Regtype, "match"), "start")));
end
%% get params
MSTIparamsAllGet.Protocol = string(MSTIparamsAll(idx).ProtocolType);
MSTIparamsAllGet.stimStrs = cellfun(@(x) strrep(x, ".", "o"), stimStrs);

MSTIparamsAllGet.Colors = regexpi(string(MSTIparamsAll(idx).Colors), ",", "split");
MSTIparamsAllGet.MMNcompare = MSTIparamsAll(idx).MMNcompare;
% MSTIparamsAll.GroupTypes = cellfun(@double, ...
%                                 rowFcn(@(x) regexpi(x, ",", "split"), ...
%                                 regexpi(string(MSTIparamsAll(idx).GroupTypes), ";", "split")', "UniformOutput", false),...
%                                 'UniformOutput', false);
% MSTIparamsAll.SoundMatIdx = double(regexpi(string(MSTIparamsAll(idx).SoundMatIdx), ",", "split"));
% MSTIparamsAll.SoundMatPath = string(MSTIparamsAll(idx).SoundMatPath);
MSTIparamsAllGet.trialonset_Win = double(regexpi(string(MSTIparamsAll(idx).trialonset_Window), ",", "split"));
MSTIparamsAllGet.Window = double(regexpi(string(MSTIparamsAll(idx).devonset_Window), ",", "split"));
MSTIparamsAllGet.ICAWindow = double(regexpi(string(MSTIparamsAll(idx).ICAWindow), ",", "split"));
MSTIparamsAllGet.plotWin = double(regexpi(string(MSTIparamsAll(idx).plotWindow), ",", "split"));
MSTIparamsAllGet.compareWin = double(regexpi(string(MSTIparamsAll(idx).compareWindow), ",", "split"));
MSTIparamsAllGet.FFTWin = double(regexpi(string(MSTIparamsAll(idx).FFTWindow), ",", "split"));
MSTIparamsAllGet.CWTplotWindow = double(regexpi(string(MSTIparamsAll(idx).CWTplotWindow), ",", "split"));
MSTIparamsAllGet.sigTestWin = double(regexpi(string(MSTIparamsAll(idx).sigTestWin), ",", "split"));

MSTIparamsAllGet.Duration = double(MSTIparamsAll(idx).Duration);
MSTIparamsAllGet.cursor1 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor1), ",", "split")), -1);
MSTIparamsAllGet.cursor2 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor2), ",", "split")), -1);
MSTIparamsAllGet.cursor3 = roundn(double(regexpi(string(MSTIparamsAll(idx).cursor3), ",", "split")), -1);
MSTIparamsAllGet.BaseICI = Groups;
MSTIparamsAllGet.sigTestMethod = "ttest2";
eval(strcat("MSTIparamsAllGet.chPlotFcn = ", string(MSTIparamsAll(idx).chPlotFcn), ";"))

end
