%% noise
MATPATH = 'H:\MGB\DDZ\ddz20231124\Block-9';
% MATPATH = 'H:\MGB\CM\cm20231118\Block-10';
% MATPATH = 'H:\AC\CM\cm20231120\Block-12';
% MATPATH = 'M:\DATA\CM\cm20231123\Block-12';
FIGPATH = fullfile(MATPATH, "Figure");
RNP_Noise(MATPATH, FIGPATH, [-100, 800]);

%% CF
MATPATH = 'H:\MGB\DDZ\ddz20231124\Block-6';
% MATPATH = 'H:\MGB\CM\cm20231118\Block-11';
% MATPATH = 'H:\AC\CM\cm20231120\Block-13';
% MATPATH = 'M:\DATA\CM\cm20231123\Block-13';
FIGPATH = fullfile(MATPATH, "Figure");
sFRA_RNP(MATPATH, FIGPATH)

%% BPN
% 500-ms Pure Tone or Band Pass Noise with 1/3 or 1 octave bandwidth
sustainWin = [100, 400]; % ms, if sustainWin is not set, it will be [100, 500];
MATPATH = 'H:\AC\DDZ\ddz20231227\Block-3';
FIGPATH = fullfile(MATPATH, "Figure");
MLA_BPN(MATPATH, FIGPATH);