function trueFalse = MouseLA_IsCTLProt(protStr)
% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MouseLA_CTLConfig.xlsx");
configTable = table2struct(readtable(configPath));
trueFalse = matches(protStr, {configTable.paradigm}');
end

    