function [InterestAmp, Amp]  = calFFTAmp(InterestFreq, FFTAmp, FFTFreq, HalfWindowLength)
narginchk(3,4);

for InterestAmpIdx = 1 : numel(InterestFreq)
    InterestFreqTemp = InterestFreq(InterestAmpIdx);
    if nargin == 4
        HalfWindowLength = HalfWindowLength;
    elseif nargin < 4
        if InterestFreqTemp < 10
            HalfWindowLength = 0.5;
        elseif InterestFreqTemp > 10
            HalfWindowLength = 2.5;
        end
    end
    MainWindow = [InterestFreqTemp - HalfWindowLength, InterestFreqTemp + HalfWindowLength];
    LeftBaselineWindow = [MainWindow(1) - HalfWindowLength, MainWindow(1)];
    RightBaselineWindow = [MainWindow(2), MainWindow(2) + HalfWindowLength];
    
    MainFreqIdx = find(FFTFreq > MainWindow(1) & FFTFreq < MainWindow(2));
    TargetFreqAmp = mean(FFTAmp(MainFreqIdx));
    BaseFreqIdx = [find(FFTFreq > LeftBaselineWindow(1) & FFTFreq < LeftBaselineWindow(2));
        find(FFTFreq > RightBaselineWindow(1) & FFTFreq < RightBaselineWindow(2))];
    BaselineAmp = mean(FFTAmp(BaseFreqIdx));
    Amp{2 * InterestAmpIdx - 1, 1} = [TargetFreqAmp, InterestFreqTemp]; Amp{2 * InterestAmpIdx - 1, 2} = "TargetPeak"; 
    Amp{2 * InterestAmpIdx, 1} = [BaselineAmp, InterestFreqTemp]; Amp{2 * InterestAmpIdx, 2} = "Baseline";
    InterestAmp{InterestAmpIdx, 1} = [Amp{2 * InterestAmpIdx - 1, 1}(1) - Amp{2 * InterestAmpIdx, 1}(1), InterestFreqTemp];

end

return;
end