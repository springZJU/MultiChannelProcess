temp = dirItem("D:\Lab members\SPR\DATA\TDT\20241223RAT3SPR", "mergePara", "folderOrFile", "file");
for i = 1 : length(temp)
    load(temp{i});
    BLOCKPATH = strrep(BLOCKPATH, 'RHD', 'TDT');
    save(temp{i}, "BLOCKPATH", "segPoint", '-mat');
end