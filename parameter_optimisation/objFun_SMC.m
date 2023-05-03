function o = objFun_SMC(effect_vals)

if effect_vals(end) == 0
    effect_vals(end) = 1e-4;
end

x_i = [0.0	1.0	5.0	10.0]./10;
x_e = 0;

f = zeros(4, 1);
peak_p = zeros(4, 1);
plateau_p = zeros(4, 1);

w = @(x)((1-exp(-effect_vals(end).*x))/(1-exp(-effect_vals(end))));
weighting = [3.14837166407295, effect_vals(end), 1];

effect_vals = [0.342283772749732,0.768840891004290, effect_vals(1:end-1), 0];

for i = 1:length(x_i)
    [t, s, a] = ICC_SMC_GT_Neuro_V5_v1(effect_vals, weighting, x_e, x_i(i));
    T = a(:, 7);
    Vm_ICC = s(:,3);
    Vm_SMC = s(:,1);
    [f(i), peak_p(i), plateau_p(i)] = calculate_frequency(t, T, [60000 180000]);
end

peak_p_rescale = peak_p/peak_p(1);

exp_peak = [1.0	0.8646840148698886	0.48698884758364325	0.2654275092936803]';%	0.15836431226765812]';
exp_plateau = [];

o = sum(sqrt((exp_peak-peak_p_rescale).^2));%+ (exp_plateau-plateau_p).^2);

end