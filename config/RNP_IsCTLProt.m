function trueFalse = RNP_IsCTLProt(protStr)
% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\RNP_CTLConfig.xlsx");
configTable = table2struct(readtable(configPath));
trueFalse = matches(protStr, {configTable.paradigm}');
end

    