temp     = dir('D:\Lab members\ISH\(preliminary) LocalProcessing\DATA\RHD\**\*.rhd');
RHDPATH  = {temp.folder}';
[C,IA,IC] = unique(RHDPATH);
duplicateIdx = find(diff(IC) == 0)+1;
rowFcn(@(x) delete(fullfile(x.folder, x.name)), temp(duplicateIdx), "UniformOutput", false);


