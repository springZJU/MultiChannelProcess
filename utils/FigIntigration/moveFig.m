FigRootpath = "H:\MLA_A1补充\Figure\CTL_New\TB_BaseICI_4_8_16";
TargetRootpath = "E:\MonkeyLinearArray\Figure\CTL_New\TB_BaseICI_4_8_16";
FIGPATH = dirItem(FigRootpath, "(cm|ddz)\w*_AC", "folderOrFile", "folder");
TargetPath = strrep(FIGPATH, FigRootpath, TargetRootpath);
cellfun(@(x, y) movefile(x, y, "f"), FIGPATH, TargetPath, "uni", false);