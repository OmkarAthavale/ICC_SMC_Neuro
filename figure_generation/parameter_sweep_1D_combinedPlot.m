%%% parameter_sweep_1D_combinedPlot.m
%%% Omkar N. Athavale, May 2023
%%% Plot sweeps across k_xXXXX parameters from 0 - 1

% --- INPUTS ---
var_seq = 1:5; % variable index to sweep (max 2)
n = 51; % number of points to sweep (all variables same)
% --------------

addpath('../matlab_common/')

non_sweeped_values = [0 0 0 0 0];
non_sweep = input('Select a choice for the value of non-sweep parameters\n0: non-sweep params are 0 (as in paper)\n1: non-sweep params are fitted values --- (as in JNE reviewer response)\n');
switch non_sweep % [kiAno1, kiNSCC, kiCa50, kiSK, keIP3]. 
	case 0
		non_sweeped_values = [0 0 0 0 0];  % this is the paper figure
	case 1
		non_sweeped_values = [0.329454438664630,0.773384113014197, 0.396950911630671, 0.303891480696183, 1]; % this was used for the response to reviewers
end

% parameter info
names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'k_{eIP3}', 'p_{iICC}', 'p_{iSMC}', 'p_{e}',};
sweep_domain = repmat([0; 1], 1, 5); % range to sweep one column per variable
f_i = 10.*ones(1, 5);
f_e = 10.*ones(1, 5);

for k = 1:length(var_seq)
    sweep_var = var_seq(k); % select sweep variable
    
    weights = [1 1 1]; % these make no difference here, w_i=w_e=1
    effect_vals = non_sweeped_values.*ones(n, 5);
    effect_vals(:, sweep_var) = linspace(sweep_domain(1, sweep_var), sweep_domain(2, sweep_var), n);
    
    % initialise results
    f = zeros(n, 1);
    peak_p = zeros(n, 1);
    plateau_p = zeros(n, 1);
    
    % run simulations
    parfor i = 1:n
        [t, s, a] = ICC_SMC_Neuro(effect_vals(i, :), weights, f_e(sweep_var), f_i(sweep_var));
        T = a(:, 7);
        Vm_ICC = s(:,3);
        Vm_SMC = s(:,1);
        
        [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]);
    end
    
    save(sprintf('../data/Multi_1DSweep_%s_%s', datestr(datetime, 'yymmddHHMMSS'), names{sweep_var}))
end

%% Single var change plots combined
% read in all saved results
if ispc
    files = ls('../data/Multi_1DSweep_*');
    nF = size(files, 1);
    for i = 1:nF
        d{i} = load(['../data/', files(i, :)]);
    end
else
    files = splitlines(ls('../data/Multi_1DSweep_*'));
    nF = size(files, 1)-1;
    for i = 1:nF
        d{i} = load([files{i}]);
    end
end

% offsets set to space out traces, about 1.5x initial value
freq_offset = 0;        %cpm
tension_offset = 0;    %kPa

% figure generation
h = figure('Units', 'centimeters');
set(h, 'position', [10,10,9,11] );

% plot frequency
ax(1) = subplot(2,1,2);
hold on
for i = 1:nF
    pLV(i) = plot(d{i}.effect_vals(:, d{i}.sweep_var), d{i}.f-freq_offset*i, 'LineWidth', 1.5); 
    yline(d{i}.f(1)-freq_offset*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    f_ends_number(i, :) = d{i}.f([1, end])-freq_offset*i;
    f_ends(i, :) = d{i}.f([1, end]);
end

ax(2) = subplot(2,1,1);

hold on
for i = 1:nF
    pLT(i) = plot(d{i}.effect_vals(:, d{i}.sweep_var), d{i}.plateau_p-tension_offset*i, 'LineWidth', 1.5);
    yline(d{i}.plateau_p(1)-tension_offset*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    plateau_ends_number(i, :) = d{i}.plateau_p([1, end])-tension_offset*i;
    plateau_ends(i, :) = d{i}.plateau_p([1, end]);
end

% Axis 1 (frequency, bottom axis)
axes(ax(1));
xlim([min(d{i}.effect_vals(:, d{i}.sweep_var)), max(d{i}.effect_vals(:, d{i}.sweep_var))])
ylim([0 6])
ylabel('Frequency (cpm)')
xlabel(sprintf('Parameter value'));

set(ax(1), 'XTick', [0 0.5 1]);
box off
% add end labels
% for i = 1:nF
%     text(1.01, f_ends_number(i, 2), d{i}.names(i))
% end
legend(pLV, d{1}.names, 'Location', 'eastoutside')

% Axis 2 (tension, top axis)
axes(ax(2));
xlim([min(d{i}.effect_vals(:, d{i}.sweep_var)), max(d{i}.effect_vals(:, d{i}.sweep_var))])
ylim([0 50])

ylabel('Tension (kPa)')

set(ax(2), 'XTickLabels', {});

box off
% add end labels
% for i = 1:nF
%     text(1.01, plateau_ends_number(i, 2), d{i}.names(i))
% end
legend(pLT, d{1}.names, 'Location', 'eastoutside')

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/1D_multiSweeps_%d_%d_%s', freq_offset, tension_offset, datestr(datetime, 'yymmddHHMMSS')), 'svg')
