function RNP_FRA(MATPATH, FIGPATH)
%% Parameter setting

if exist(FIGPATH, "dir")
    return
end
%% plot FRA
mkdir(FIGPATH);
sFRA_RNP(MATPATH, FIGPATH);
close all
end