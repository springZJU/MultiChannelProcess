%cd("D:\Lab members\GSR\Offset\BDF Data");
%temp = dirItem("D:\Lab members\ISH\(preliminary) LocalProcessing\DATA\RHD", ".wl", "folderOrFile","file");
temp = dirItem("D:\Lab members\GSR\Offset\BDF Data\RAT_AC\RHD", ".wl", "folderOrFile","file");
newName = strrep(temp, '.wl', '.rhd');
cellfun(@(x, y) movefile(x, y), temp, newName, "UniformOutput", false)

        