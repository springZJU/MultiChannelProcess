function [InterestAmp, Amp]  = calFFTAmp(InterestFreq, FFTAmp, FFTFreq)

for InterestAmpIdx = 1 : numel(InterestFreq)
    InterestFreqTemp = InterestFreq(InterestAmpIdx);
    if InterestFreqTemp < 10
        WindowEdgeRatio = 0.15;
    elseif InterestFreqTemp > 10 & InterestFreqTemp < 100
        WindowEdgeRatio = 0.015;
    elseif InterestFreqTemp > 100
        WindowEdgeRatio = 0.002;
    end
    HalfWindowLength = InterestFreqTemp * WindowEdgeRatio;
    MainWindow = [InterestFreqTemp - HalfWindowLength, InterestFreqTemp + HalfWindowLength];
    MainWindowLength = MainWindow(2) - MainWindow(1);

    LeftBaselineWindow = [MainWindow(1) - MainWindowLength, MainWindow(1)];
    RightBaselineWindow = [MainWindow(2), MainWindow(2) + MainWindowLength];
    
    MainFreqIdx = find(FFTFreq > MainWindow(1) & FFTFreq < MainWindow(2));
    BaseFreqIdx = [find(FFTFreq > LeftBaselineWindow(1) & FFTFreq < LeftBaselineWindow(2));
        find(FFTFreq > RightBaselineWindow(1) & FFTFreq < RightBaselineWindow(2))];
    Amp{2 * InterestAmpIdx - 1, 1} = [mean(FFTAmp(MainFreqIdx)), InterestFreqTemp]; Amp{2 * InterestAmpIdx - 1, 2} = "Target"; 
    Amp{2 * InterestAmpIdx, 1} = [mean(FFTAmp(BaseFreqIdx)), InterestFreqTemp]; Amp{2 * InterestAmpIdx, 2} = "Baseline";
    InterestAmp{InterestAmpIdx, 1} = [Amp{2 * InterestAmpIdx - 1, 1}(1) - Amp{2 * InterestAmpIdx, 1}(1), InterestFreqTemp];

end

return;
end