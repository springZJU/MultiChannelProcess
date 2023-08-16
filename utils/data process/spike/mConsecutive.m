function [first_position, last_position, result] = mConsecutive(data, n)

result = zeros(length(data)-n+1, 1);
for i = 1:length(data)-n
    if all(diff(data(i:i+n)) == 1)
        result(i) = i;
    end
end
result = result(result>0);

if ~isempty(result)

    first_position = result(1);
    last_position = result(end)+n;
else
    first_position = [];
    last_position = [];
end
end
