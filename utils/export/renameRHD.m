temp = dirItem("D:\Lab members\SPR\DATA\RHD", ".wl", "folderOrFile","file");
newName = strrep(temp, '.wl', '.rhd');
cellfun(@(x, y) movefile(x, y), temp, newName, "UniformOutput", false)

