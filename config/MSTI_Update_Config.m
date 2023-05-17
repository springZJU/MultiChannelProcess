function MSTI_Update_Config
% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\config\MLA_MSTIConfig.xlsx");
configTable = table2struct(readtable(configPath));

trialTypes = cell2mat(cellfun(@(x) any(isnan(x))|isempty(x), {configTable.trialTypes}', "UniformOutput", false));
Std_DevIndex = cell2mat(cellfun(@(x) any(isnan(x))|isempty(x), {configTable.Std_Dev_Onset}', "UniformOutput", false));
Index = find(any([trialTypes, Std_DevIndex], 2));


mProtocol = configTable(Index);

for pIndex = 1 : length(mProtocol)
soundPaths = string(strsplit(mProtocol(pIndex).soundPath, ";"))';

S1_S2 = cellfun(@(x) string(strsplit(x, "_")), string(strsplit(mProtocol(pIndex).S1_S2, ";")), "uni", false)';
S1_S2 = table2array(cell2table(S1_S2));

temp = cellfun(@(x) load(fullfile(x, "MMNSequence.mat"), "-mat"), soundPaths, "uni", false);
fieldNames = string(cellfun(@(x) fields(x), temp, "UniformOutput", false));
MMNSequences = cellfun(@(x, y) x.(y), temp, fieldNames, "UniformOutput", false);
orderIndex = cellfun(@(x) str2double(string(strsplit(x, "-"))), strsplit(string(strsplit(mProtocol.orderIndex, ";")), ",")', "uni", false);

trialTypes = cellfun(@(x) MMNSequences{x(1)}(x(2)).Tag, orderIndex, "uni", false);
trialTypes = cellfun(@(x, y) strrep(x, "S1", S1_S2(y(1),1)), trialTypes, orderIndex, "UniformOutput", false);
trialTypes = strjoin(string(cellfun(@(x, y) strrep(x, "S2", S1_S2(y(1),2)), trialTypes, orderIndex, "UniformOutput", false)), ",");
configTable(Index(pIndex)).trialTypes = trialTypes;

Std_Dev_Onset = cellfun(@(x) round(MMNSequences{x(1)}(x(2)).Std_Dev_Onset(1 : end)), orderIndex, "uni", false);
Std_Dev_Onset_Str = strjoin(table2array(cell2table(cellfun(@(x) strjoin(string(x), ","), Std_Dev_Onset, "uni", false))), ";");
configTable(Index(pIndex)).Std_Dev_Onset = Std_Dev_Onset_Str;
end

writetable(struct2table(configTable), configPath);