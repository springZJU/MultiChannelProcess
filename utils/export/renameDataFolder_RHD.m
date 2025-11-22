ROOTPATH = "D:\Lab members\KXK\Reflection\RHD\20250803KXK\";    
temp = dirItem(ROOTPATH, ".*\d\d$", "folderOrFile","folder");
newName = cellfun(@(x) strcat("Data", num2str(x)), num2cell(1:length(temp))');
cellfun(@(x, y) movefile(x, fullfile(ROOTPATH, y), "f"), temp, newName, "UniformOutput", false)

        