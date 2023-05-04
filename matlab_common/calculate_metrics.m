function [f, peak_p, plateau_p] = calculate_metrics(t, x, t_range)
%%% optim_SMC.m
%%% Omkar N. Athavale, May 2023
%%% Calculate the peak, plateau, and frequency metrics for a given signal
%%% Can be tension, Vm_ICC, or Vm_SMC
%%% INPUTS
%%% t: n x 1 array of n time steps in ms
%%% x: n x 1 array of quantity at n time steps coresponding to t
%%% t_range (OPTIONAL): 1 x 2 array of time range (in ms) to analyse.
%%% (Default: [0 max(t)]
%%%
%%% OUTPUTS
%%% f: scalar, mean frequency (cpm) of the events within t_range
%%% peak_p: scalar, mean initial peak (x unit) of the events within t_range
%%% plateau_p: scalar, mean plateau (x unit) of the events within t_range

% select relevant period
if nargin < 3
    x = x;
else
    eps = 0.6;
    x = x(find(abs(t - t_range(1)) < eps):find(abs(t - t_range(2)) < eps));
end

% identify events onsets
res_x = rescale(movmean(diff(x), 40));
pos_x = x-min(x);
[~, i_diff] = findpeaks(res_x.*(res_x>0.9), 'MinPeakProminence', 0.5);

% approximately mask out non-events period
i = [];
peak_search_duration = 100; %round(100/(t(2)-t(1))); % in num elements
event_approx_duration = 3000; %round(3000/(t(2)-t(1))); % in num elements

cumulative_mask = zeros(size(x));
for j = 1:length(i_diff)
    v = i_diff(j);
    mask = zeros(length(x), 1);
    
    tgt_t_ind = find_time(t, v, event_approx_duration);
    
    if isnan(tgt_t_ind)
        i(j) = NaN;
    else
        mask(v:tgt_t_ind) = 1;
		mask_peak = zeros(length(x), 1);
        
        search_t_ind = find_time(t, v, peak_search_duration);
        
		mask_peak(v:search_t_ind) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask_peak);
    end
end

i(isnan(i)) = []; % remove events that are partially outside the selected period

cumulative_mask_nan = double(cumulative_mask);
cumulative_mask_nan(cumulative_mask_nan == 0) = NaN;
min_deriv_smooth = min(movmean(abs(diff(x.*cumulative_mask_nan)), 200)); % derivative basline for plateau identification
tol = 2.5e-3; % derivative threshold for plateau identification

% identify sections in plateau
i_plateau = (abs(movmean(abs(diff(x)), 200) - min_deriv_smooth) < tol) & cumulative_mask(2:end) & (pos_x(2:end) > 1);

% calculate metrics
f = 60*1000/mean(diff(t(i))); % in cpm
peak_p = mean(x(i))-min(x);
plateau_p = mean(x(i_plateau))-min(x);

end

function tgt_ind = find_time(t, currInd, t_delta)
tgt_time = t(currInd)+t_delta;
if tgt_time > max(t)
    tgt_ind = NaN;
else
    [~, tgt_ind] = min(abs(tgt_time-t));
end
end

