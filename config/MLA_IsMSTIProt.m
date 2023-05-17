function trueFalse = MLA_IsMSTIProt(protStr)
% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIConfig.xlsx");
configTable = table2struct(readtable(configPath));
trueFalse = matches(protStr, {configTable.paradigm}');
end