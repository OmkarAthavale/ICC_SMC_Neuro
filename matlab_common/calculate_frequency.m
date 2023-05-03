function [f, peak_p, plateau_p] = calculate_frequency(t, x, tRange)

if nargin < 3
    x = x;
else
    eps = 0.6;
    x = x(find(abs(t - tRange(1)) < eps):find(abs(t - tRange(2)) < eps));
end
res_x = rescale(movmean(diff(x), 40));
pos_x = x-min(x);
[~, i_diff] = findpeaks(res_x.*(res_x>0.9), 'MinPeakProminence', 0.5);
% findpeaks(rescale(diff(x)), 'MinPeakProminence', 0.005);

i = [];
cumulative_mask = zeros(size(x));
for j = 1:length(i_diff)
    v = i_diff(j);
    mask = zeros(length(x), 1);
    if v+3000 > length(x)
%         mask(v:end) = 1;
% 		mask_peak = zeros(length(x), 1);
% 		mask_peak(v:v+100) = 1;
%         cumulative_mask = mask | cumulative_mask;
%         [~, i(j)] = max(pos_x.*mask_peak);
        i(j) = NaN;
    else
        mask(v:v+3000) = 1;
		mask_peak = zeros(length(x), 1);
		mask_peak(v:v+100) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask_peak);
    end
end
i(isnan(i)) = [];
% [~, i] = max(x.*mask, 'MinPeakProminence', 0.03);& ((abs(diff(x(2:end)))-1.5e-4) < 0)
cumulative_mask_nan = double(cumulative_mask);
cumulative_mask_nan(cumulative_mask_nan == 0) = NaN;
min_deriv_smooth = min(movmean(abs(diff(x.*cumulative_mask_nan)), 200));
tol = 2.5e-3;
i_plateau = (abs(movmean(abs(diff(x)), 200) - min_deriv_smooth) < tol) & cumulative_mask(2:end) & (pos_x(2:end) > 1);
%i_plateau = ((abs(movmean(diff(x(2:end)), 800))-0.01) < 0) & ((abs(diff(diff(x)))-1e-5) < 0) & cumulative_mask(3:end) & (pos_x(3:end) > 1);
f = 60*1000/mean(diff(t(i)));

peak_p = mean(x(i))-min(x);
plateau_p = mean(x(i_plateau))-min(x);

end