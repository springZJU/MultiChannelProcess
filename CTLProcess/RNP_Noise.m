function RNP_Noise(MATPATH, FIGPATH)

if exist(FIGPATH, "dir")
    return
end
%% plot Noise
sNoise_RNP(MATPATH, FIGPATH);

end