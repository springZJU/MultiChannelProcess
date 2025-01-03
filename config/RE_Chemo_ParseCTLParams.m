function CTLParams = RE_Chemo_ParseCTLParams(protStr, excelName)
narginchk(1, 2)
if nargin < 2
    excelName = "RE_Chemo_CTLConfig.xlsx";
end
if ~contains(excelName, ".xlsx")
    excelName = strcat(excelName, ".xlsx");
end
% load excel
    configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\", excelName);

configTable = table2struct(readtable(configPath));
mProtocol = configTable(matches({configTable.paradigm}', protStr));

% parse CTLProt
CTLParams.fs = 1000;
CTLParams.S1Duration = str2double(string(strsplit(mProtocol.S1Duration, ",")));
CTLParams.Window = str2double(string(strsplit(mProtocol.Window, ",")));
CTLParams.selWin = str2double(string(strsplit(mProtocol.selWin, ",")));
CTLParams.Offset = str2double(string(strsplit(mProtocol.Offset, ",")));
CTLParams.stimStr = strrep(string(strsplit(mProtocol.trialTypes, ",")), "_", "-");
CTLParams.colors = string(strsplit(mProtocol.colors, ","));
CTLParams.toPlotFFT = mProtocol.toPlotFFT;
CTLParams.plotRows = mProtocol.plotRows;
CTLParams.plotWin = str2double(string(strsplit(mProtocol.plotWin, ",")));
CTLParams.compareWin = str2double(string(strsplit(mProtocol.compareWin, ",")));
% CTLParams.compareCol = mProtocol.compareCol;
CTLParams.PSTH_CompareSize = str2double(string(strsplit(mProtocol.PSTH_CompareSize, ",")));
CTLParams.LFP_CompareSize = str2double(string(strsplit(mProtocol.LFP_CompareSize, ",")));
CTLParams.BaseICI = str2double(string(strsplit(mProtocol.BaseICI, ",")));
CTLParams.legendFontSize = mProtocol.legendFontSize;
eval(strcat("CTLParams.chPlotFcn = ", string(mProtocol.chPlotFcn), ";"));

Compare_Index =  string(strsplit(mProtocol.Compare_Index, ";"));
for cIndex = 1 : length(Compare_Index)
    CTLParams.Compare_Index{cIndex, 1} = str2double(strsplit(Compare_Index(cIndex), ","))';
end


FFTWin = string(strsplit(mProtocol.FFTWin, "_"));
CTLParams.FFTWin = repmat(str2double(strsplit(FFTWin(1), ",")), length(CTLParams.stimStr), 1);
if length(FFTWin) > 1
    for wIndex = 2 : length(FFTWin)
        temp = strsplit(FFTWin(wIndex), ":");
        CTLParams.FFTWin(str2double(temp(1)), :) = str2double(strsplit(temp(2), ","));
    end
end

end

