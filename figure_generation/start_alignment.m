function [t, x] = start_alignment(t, x, tRange)

if nargin < 3
    x = x;
else
    eps = 0.6;
    time_mask = find(abs(t - tRange(1)) < eps):find(abs(t - tRange(2)) < eps);
    x = x(time_mask);
    t = t(time_mask);
end

res_x = rescale(diff(x));
pos_x = x-min(x);
[~, i_diff] = findpeaks(res_x.*(res_x>0.9), 'MinPeakProminence', 0.5);
% findpeaks(rescale(diff(x)), 'MinPeakProminence', 0.005);

i = [];
cumulative_mask = zeros(size(x));
for j = 1:length(i_diff)
    v = i_diff(j);
    mask = zeros(length(x), 1);
    if v+10 > length(x)
        mask(v:end) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask);
    else
        mask(v:v+10) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask);
    end
end

startOffsetSamples = 2000;
duration = 4000;

initInd = i(1);
startInd = initInd - startOffsetSamples;
endInd = initInd + duration;
padding = nan(max(0, endInd-startInd - numel(x(startInd:end))), 1);

if numel(padding) > 0 % this doesn't work right
    x = [x(startInd:end); padding];
    t = [t(startInd:end); padding]-min(t(startInd:end));
else
    x = x(startInd:endInd);
    t = t(startInd:endInd)-min(t(startInd:endInd));
end

end