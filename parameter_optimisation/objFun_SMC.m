function o = objFun_SMC(effect_vals)
%%% objFun_SMC.m
%%% Omkar N. Athavale, May 2023
%%% Calculate objective function for Step 2 of optimisation procedure (SMC inhibitory component)
%%% INPUTS
%%% effect_vals: 1 x 3 array of k_iCa50, k_iSK, p_iSMC
%%%
%%% OUTPUTS
%%% o: objective function value

% p_iSMC cannot be 0
if effect_vals(end) == 0
    effect_vals(end) = 1e-4;
end

% evaulation points
f_i = [0.0	1.0	5.0	10.0];
f_e = 0;

f = zeros(4, 1);
peak_p = zeros(4, 1);
plateau_p = zeros(4, 1);

%%%% SELECT A SET OF STEP 1 FITTED VALUES TO USE IN STEP 2. %%%%%
%%%% The low kiAno1 cluster was used in the manuscript and model The high kiAno1 cluster was tested as well for reviewers. %%%%%

%%% high kiAno1 cluster
% weighting = [3.34182038994190, effect_vals(end), 1];  % fixed parameters
% effect_vals = [0.329454438664630,0.773384113014197, effect_vals(1:end-1), 0]; % fixed parameters

%%% low kiAno1 cluster
weighting = [3.14933156638040, effect_vals(end), 1];  % fixed parameters
effect_vals = [0.0914532418255071,0.844691701303740, effect_vals(1:end-1), 0]; % fixed parameters

for i = 1:length(f_i)
    [t, s, a] = ICC_SMC_Neuro(effect_vals, weighting, f_e, f_i(i));
    T = a(:, 7);
    Vm_ICC = s(:,3);
    Vm_SMC = s(:,1);
    [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]); % uses tension peak
end

peak_p_rescale = peak_p/peak_p(1);

% data extracted from Kim et al. 2003 Fig 1B
exp_peak = [1.0	0.8646840148698886	0.48698884758364325	0.2654275092936803]';%	0.15836431226765812]';

o = sum(abs(exp_peak-peak_p_rescale)); % sum of absolute deviation objective function

end