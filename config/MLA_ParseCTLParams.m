function CTLParams = MLA_ParseCTLParams(protStr)

% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_CTLConfig.xlsx");
configTable = table2struct(readtable(configPath));
mProtocol = configTable(matches({configTable.paradigm}', protStr));

% parse CTLProt
CTLParams.S1Duration = str2double(string(strsplit(mProtocol.S1Duration, ",")));
CTLParams.Window = cell2mat(cellfun(@(x) str2double(string(strsplit(x, ","))), strsplit(mProtocol.Window, ";")', "UniformOutput", false));
CTLParams.selWin = str2double(string(strsplit(mProtocol.selWin, ",")));
CTLParams.Offset = str2double(string(strsplit(mProtocol.Offset, ",")));
eval(strcat("CTLParams.segPoint = ", string(mProtocol.segPoint), ";"));
CTLParams.ordr2Onset = str2double(string(strsplit(mProtocol.ordr2Onset, ",")));
CTLParams.stimStr = strrep(string(strsplit(mProtocol.trialTypes, ",")), "_", "-");
CTLParams.colors = string(strsplit(mProtocol.colors, ","));
CTLParams.toPlotFFT = mProtocol.toPlotFFT;
CTLParams.plotRows = mProtocol.plotRows;
CTLParams.plotWin = str2double(string(strsplit(mProtocol.plotWin, ",")));
CTLParams.acfWin = str2double(string(strsplit(mProtocol.acfWin, ",")));
CTLParams.maxLag = str2double(string(strsplit(mProtocol.maxLag, ",")));
CTLParams.compareWin = str2double(string(strsplit(mProtocol.compareWin, ",")));
CTLParams.compareCol = mProtocol.compareCol;
CTLParams.PSTH_CompareSize = str2double(string(strsplit(mProtocol.PSTH_CompareSize, ",")));
CTLParams.LFP_CompareSize = str2double(string(strsplit(mProtocol.LFP_CompareSize, ",")));
CTLParams.BaseICI = str2double(string(strsplit(mProtocol.BaseICI, ",")));
CTLParams.ICI2 = str2double(string(strsplit(mProtocol.ICI2, ",")));

CTLParams.legendFontSize = mProtocol.legendFontSize;
eval(strcat("CTLParams.chPlotFcn = ", string(mProtocol.chPlotFcn), ";"));

Compare_Index =  string(strsplit(mProtocol.Compare_Index, ";"));
for cIndex = 1 : length(Compare_Index) 
    CTLParams.Compare_Index{cIndex, 1} = str2double(strsplit(Compare_Index(cIndex), ","))';
end


FFTWin = string(strsplit(mProtocol.FFTWin, "_"));
CTLParams.FFTWin = repmat(str2double(strsplit(FFTWin(1), ",")), max([length(CTLParams.stimStr), length(CTLParams.segPoint)]), 1);
if length(FFTWin) > 1
    for wIndex = 2 : length(FFTWin)
        temp = strsplit(FFTWin(wIndex), ":");
        CTLParams.FFTWin(str2double(temp(1)), :) = str2double(strsplit(temp(2), ","));
    end
end

end

