function MSTIParams = MLA_ParseMSTIParams(protStr)

MSTI_Update_Config;

% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIConfig.xlsx");
configTable = table2struct(readtable(configPath));
mProtocol = configTable(matches({configTable.paradigm}', protStr));

% parse CTLProt
MSTIParams.fs = 600;
MSTIParams.orderIndex = cell2mat(cellfun(@(x) str2double(string(strsplit(x, "-"))), strsplit(string(strsplit(mProtocol.orderIndex, ";")), ",")', "uni", false));
MSTIParams.Std_Dev_Onset = cell2mat(cellfun(@(x) str2double(strsplit(x, ",")), string(strsplit(mProtocol.Std_Dev_Onset, ";")), "uni", false)');
MSTIParams.DevOnset = MSTIParams.Std_Dev_Onset(:, end);
MSTIParams.S1_S2 = table2array(cell2table(cellfun(@(x) string(strsplit(x, "_")), string(strsplit(mProtocol.S1_S2, ";")), "uni", false)'));
MSTIParams.Window = str2double(string(strsplit(mProtocol.Window, ",")));
MSTIParams.selWin = str2double(string(strsplit(mProtocol.selWin, ",")));
MSTIParams.sigTestMethod = string(mProtocol.sigTestMethod);
MSTIParams.sigTestWin = str2double(string(strsplit(mProtocol.sigTestWin, ",")));
MSTIParams.stimStr = strrep(string(strsplit(mProtocol.trialTypes, ",")), "_", "-");
MSTIParams.colors = string(strsplit(mProtocol.colors, ","));
MSTIParams.toPlotFFT = mProtocol.toPlotFFT;
MSTIParams.plotRows = mProtocol.plotRows;
MSTIParams.plotWin = str2double(string(strsplit(mProtocol.plotWin, ",")));
MSTIParams.compareWin = str2double(string(strsplit(mProtocol.compareWin, ",")));
MSTIParams.compareCol = mProtocol.compareCol;
MSTIParams.PSTH_CompareSize = str2double(string(strsplit(mProtocol.PSTH_CompareSize, ",")));
MSTIParams.LFP_CompareSize = str2double(string(strsplit(mProtocol.LFP_CompareSize, ",")));
MSTIParams.legendFontSize = mProtocol.legendFontSize;
eval(strcat("MSTIParams.chPlotFcn = ", string(mProtocol.chPlotFcn), ";"));
Compare_Index =  string(strsplit(mProtocol.Compare_Index, ";"));
for cIndex = 1 : length(Compare_Index) 
    MSTIParams.Compare_Index{cIndex, 1} = str2double(strsplit(Compare_Index(cIndex), ","));
end

end

