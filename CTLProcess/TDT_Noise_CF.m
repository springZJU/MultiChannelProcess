%% noise
MATPATH = 'H:\MGB\DDZ\ddz20231021\Block-1';
% MATPATH = 'H:\MGB\CM\cm20231020\Block-15';
% MATPATH = 'H:\AC\CM\cm20230901\Block-11';
FIGPATH = fullfile(MATPATH, "Figure");
RNP_Noise(MATPATH, FIGPATH, [-100, 800]);

%% CF
MATPATH = 'H:\MGB\DDZ\ddz20231021\Block-9';
% MATPATH = 'H:\MGB\CM\cm20231020\Block-32';
% MATPATH = 'H:\AC\CM\cm20230901\Block-12';
FIGPATH = fullfile(MATPATH, "Figure");
sFRA_RNP(MATPATH, FIGPATH)
