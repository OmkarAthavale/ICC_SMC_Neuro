function [t, x] = start_alignment(t, x, t_range)
%%% start_alignment.m
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
%%% t: scalar, mean frequency (cpm) of the events within t_range
%%% x: scalar, mean initial peak (x unit) of the events within t_range

if nargin < 3
    x = x;
else
    eps = 0.6;
    time_mask = find(abs(t - t_range(1)) < eps):find(abs(t - t_range(2)) < eps);
    x = x(time_mask);
    t = t(time_mask);
end

res_x = rescale(diff(x));
pos_x = x-min(x);
[~, i_diff] = findpeaks(res_x.*(res_x>0.9), 'MinPeakProminence', 0.5);

% approximately mask out non-events period
i = [];
cumulative_mask = zeros(size(x));
for j = 1:length(i_diff)
    v = i_diff(j);
    mask = zeros(length(x), 1);
    if find_time(t, v, 10) > length(x)
        mask(v:end) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask);
    else
        mask(v:find_time(t, v, 10)) = 1;
        cumulative_mask = mask | cumulative_mask;
        [~, i(j)] = max(pos_x.*mask);
    end
end

start_offset = 2000; % in ms
duration = 4000; % in ms

% get first event only
initInd = i(1);
startInd = find_time(t, initInd, -start_offset); % duration before onset to display
endInd = find_time(t, initInd, duration); % duration after onset to display
padding = nan(max(0, endInd-startInd - numel(x(startInd:end))), 1);

x = x(startInd:endInd);
t = t(startInd:endInd)-min(t(startInd:endInd));

end