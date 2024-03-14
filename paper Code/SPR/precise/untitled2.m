cellfun(@(x) [x.ACCHalfH]' .* [x.ACCHalfFRDiff]', {result.res}', "UniformOutput", false);
NPTopo = flip([(3:4:384)', (1:4:384)', (4:4:384)', (2:4:384)']);