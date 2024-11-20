                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               %% noise
% MATPATH = 'H:\SPR Paper\Two-Photo Imaging\electrophysiological\Tank\20240131Rat2\Block-22';
% MATPATH = 'H:\MGB\CM\cm20231118\Block-10';
% MATPATH = 'H:\AC\CM\cm20231120\Block-12';
% MATPATH = 'M:\DATA\CM\cm20231123\Block-12';
% MATPATH = '\\Xtzj-2024sygfoi\data\DDZ\ddz20240528\Block-12';
MATPATH = '\\Xtzj-2024sygfoi\data\CM\CM20240602\Block-2';
FIGPATH = fullfile(MATPATH, "Figure");
RNP_Noise(MATPATH, FIGPATH, [-50, 100]);

%% CF
% MATPATH = 'H:\SPR Paper\Two-Photo Imaging\electrophysiological\Tank\20240131Rat2\Block-23';
% MATPATH = 'H:\MGB\CM\cm20231118\Block-11';
% MATPATH = 'H:\AC\CM\cm20231120\Block-13';
% MATPATH = 'O:\MonkeyLA\DDZ\ddz20240612\Block-2';
% MATPATH = '\\Win-6jbl2qksvfr\data\DDZ\ddz20240508\Block-4';
% MATPATH = '\\Win-6jbl2qksvfr\DATA\CM\CM20241118\Block-6';
MATPATH = '\\Win-6jbl2qksvfr\DATA\Joker\Joker20241120\Block-6';                                           
FIGPATH = fullfile(MATPATH, "Figure");
sFRA_RNP(MATPATH, FIGPATH);

%% BPN
% 500-ms Pure Tone or Band Pass Noise with 1/3 or 1 octave bandwidth
sustainWin = [100, 400]; % ms, if sustainWin is not set, it will be [100, 500];
MATPATH = 'H:\AC\DDZ\ddz20231227\Block-3';
FIGPATH = fullfile(MATPATH, "Figure");
MLA_BPN(MATPATH, FIGPATH);

