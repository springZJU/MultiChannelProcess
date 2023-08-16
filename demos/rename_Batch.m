MATPATH = "E:\MonkeyLinearArray\MAT Data\DDZ\CTL_New\Offset_Duration_Effect_4ms_Reg_New\MGB";
temp = dirItem(MATPATH, "ddz");
temp(contains(temp, "data.mat")) = [];
parts = cellfun(@(x) strsplit(x, "\"), temp , "UniformOutput", false);
dates = cellfun(@(x) strjoin(x(end), "\"), parts, "UniformOutput", false);
cellfun(@(x) renameItem(MATPATH, x, strcat(x, "_MGB")), dates, "UniformOutput", false);