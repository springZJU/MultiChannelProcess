function halfWidth = calHalfWidth(t, wave, peakTrough)
troughT   = peakTrough(2, 1);
halfAmp   = 0.5 * (peakTrough(1, 2) - peakTrough(2, 2));
halfLate  = t(find(t == troughT) + find(wave(t>troughT) >= (peakTrough(2, 2) + halfAmp), 1, "first"));
halfEarly = t(find(t == troughT) - find(flip(wave(t<troughT)) >= (peakTrough(2, 2) + halfAmp), 1, "first"));
halfWidth = halfLate - halfEarly;
end