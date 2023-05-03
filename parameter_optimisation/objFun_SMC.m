function o = objFun_SMC(effect_vals)
%%% objFun_SMC.m
%%% Omkar N. Athavale, May 2023
%%% Calculate objective function for Step 2 of optimisation procedure (SMC inhibitory component)

% p_iSMC cannot be 0
if effect_vals(end) == 0
    effect_vals(end) = 1e-4;
end

% evaulation points
x_i = [0.0	1.0	5.0	10.0]./10;
x_e = 0;

f = zeros(4, 1);
peak_p = zeros(4, 1);
plateau_p = zeros(4, 1);

weighting = [3.14837166407295, effect_vals(end), 1];  % fixed parameters
effect_vals = [0.342283772749732,0.768840891004290, effect_vals(1:end-1), 0]; % fixed parameters

for i = 1:length(x_i)
    [t, s, a] = ICC_SMC_Neuro(effect_vals, weighting, x_e, x_i(i));
    T = a(:, 7);
    Vm_ICC = s(:,3);
    Vm_SMC = s(:,1);
    [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]); % uses tension peak
end

peak_p_rescale = peak_p/peak_p(1);

% data extracted from Kim et al. 2003 Fig 1B
exp_peak = [1.0	0.8646840148698886	0.48698884758364325	0.2654275092936803]';%	0.15836431226765812]';

o = sum(sqrt((exp_peak-peak_p_rescale).^2)); % sum of absolute deviation objective function

end