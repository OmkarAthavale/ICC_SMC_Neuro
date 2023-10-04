%%% dosage_sweep_plot.m
%%% Omkar N. Athavale, May 2023
%%% Plot sweeps across f_i and f_e with fixed parameter

% --- INPUTS ---
n = 21; % number of points to sweep (all variables same)
% --------------

% parameter info
names = {'f_i', 'f_e', 'f_i & f_e'};
effect_vals = [0.320920220620083,0.776439073613402,0.399007024312299,0.302229718784617, 1];
weighting = [3.149932963402147, 0.121722979829497, 5]; 

f_e = [zeros(1, n); linspace(0, 10, n); linspace(0, 10, n)]';
f_i = [linspace(0, 10, n); zeros(1, n); linspace(0, 10, n)]';

% initialise results
f = zeros(n, size(f_e, 2));
peak_p = zeros(n, size(f_e, 2));
plateau_p = zeros(n, size(f_e, 2));

for k = 1:size(f_e, 2)
    % run simulations
    for i = 1:n
        [t, s, a] = ICC_SMC_Neuro(effect_vals, weighting, f_e(i, k), f_i(i, k));
        T = a(:, 7);
        Vm_ICC = s(:,3);
        Vm_SMC = s(:,1);
        
        [f(i, k), peak_p(i, k), plateau_p(i, k)] = calculate_metrics(t, T, [60000 180000]);
    end
    
    save(sprintf('../data/dosage_sweep_%d_%s', n, datestr(datetime, 'yymmddHHMMSS')))
end

combo_x(:, :, 1) = f_e;
combo_x(:, :, 2) =  f_i;
plot_x = max(combo_x, [], 3);
colours = [0 0 0; 0.4 0.4 0.4; 0.7 0.7 0.7];

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,11] );

ax(1) = subplot(2,1,2);
colororder(colours);
plot(plot_x, f, 'LineWidth', 1.5);
xlim([0, 1])
ylim([0, 7])
ylabel('Frequency (cpm)')
xlabel(sprintf('Stimulation frequency (Hz)'));

ax(2) = subplot(2,1,1);
colororder(colours)
plot(plot_x, plateau_p, 'LineWidth', 1.5);
xlim([0 1])
ylim([0, 50])
set(ax(2), 'XTickLabels', {})
ylabel('Tension (kPa)')

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/dosage_sweep_%d_%s', n, datestr(datetime, 'yymmddHHMMSS')), 'svg')