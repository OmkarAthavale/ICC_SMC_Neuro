%%% parameter_sweep.m
%%% Omkar N. Athavale, May 2023
%%% Perform equally spaced parameter sweeps for one or two changing variables

% --- INPUTS ---
sweep_var = [1]; % variable index to sweep (max 2)
sweep_domain = [0 1]; % range to sweep (all variables same)
n = 2; % number of points to sweep (all variables same)
x_i = ones(1, n);
x_e = zeros(1, n);
% --------------

names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'k_{eIP3}', 'p_{iICC}', 'p_{iSMC}', 'p_{e}',};

if length(sweep_var) == 2 % two changing dimenisons
    N = n;
    n = N*N;
    
    [X, Y] = meshgrid(linspace(0,1,N));
    
    effect_vals = zeros(n, 5);
    effect_vals(:, sweep_var(1)) = reshape(X, [], 1);
    effect_vals(:, sweep_var(2)) = reshape(Y, [], 1);
    
elseif length(sweep_var) == 1 % one changing dimension
    effect_vals = zeros(n, 5);
    effect_vals(:, sweep_var) = linspace(0, 1, n);
    effect_vals = [0.627769856911043	0.776142555889738	0.979668821887735	0.228026943965982 1];
    
    weights = [3.149566984343386, 1.178185077905521, 5];
    effect_vals = ones(n, 5).*[0.325665483807710,0.774750185285083, 0.882382705973490,0.441452785127037, 0.92];
    
else
    error('Must have one or two dimensions to sweep')
end

% initialise results arrays
f = zeros(n, 1);
peak_p = zeros(n, 1);
plateau_p = zeros(n, 1);

% run simulations
for i = 1:n
    [t, s, a] = ICC_SMC_Neuro(effect_vals(i, :), weights, x_e(i), x_i(i));
    T = a(:, 7);
    Vm_ICC = s(:,3);
    Vm_SMC = s(:,1);
    
    [~, peak_p_ICC(i), plateau_p_ICC(i)] = calculate_metrics(t, Vm_ICC, [60000 180000]);
    [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]);
end

% save results
if length(sweep_var) == 2 % two changing dimenisons
    save(sprintf('Sweep2D_%s_%s', datestr(datetime, 'yymmddHHMMSS'), names{sweep_var}))
elseif length(sweep_var) == 1 % one changing dimenisons
    
    save(sprintf('Sweep1D_%s_', datestr(datetime, 'yymmddHHMMSS'), names{sweep_var}))
end