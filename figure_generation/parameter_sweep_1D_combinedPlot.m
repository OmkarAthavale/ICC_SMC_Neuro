%%% parameter_sweep_1D_combinedPlot.m
%%% Omkar N. Athavale, May 2023
%%% Plot sweeps across k_xXXXX parameters from 0 - 1

% --- INPUTS ---
var_seq = 1:4; % variable index to sweep (max 2)
n = 11; % number of points to sweep (all variables same)
% --------------

% parameter info
names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'k_{eIP3}', 'p_{iICC}', 'p_{iSMC}', 'p_{e}',};
sweep_domain = repmat([0; 1], 1, 5); % range to sweep one column per variable
x_i = ones(1, 5);
x_e = ones(1, 5);

for k = 1:length(var_seq)
    sweep_var = var_seq(k); % select sweep variable

    
    weights = [3.149566984343386, 1.178185077905521, 5]; % these make no difference here, w_i=w_e=1
    effect_vals = zeros(n, 5);
    effect_vals(:, sweep_var) = linspace(sweep_domain(1, sweep_var), sweep_domain(2, sweep_var), n);
    
    % initialise results
    f = zeros(n, 1);
    peak_p = zeros(n, 1);
    plateau_p = zeros(n, 1);
    
    % run simulations
    for i = 1:n
        [t, s, a] = ICC_SMC_Neuro(effect_vals(i, :), weights, x_e(sweep_var), x_i(sweep_var));
        T = a(:, 7);
        Vm_ICC = s(:,3);
        Vm_SMC = s(:,1);
        
        [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]);
    end
    
    save(sprintf('../data/Multi_1DSweep_%s_%s', datestr(datetime, 'yymmddHHMMSS'), names{sweep_var}))
end

%% Single var change plots combined
% read in all saved results
files = ls('../data/Multi_1DSweep_*');
nF = size(files, 1);
for i = 1:nF
    d{i} = load(['../data/', files(i, :)]);
end

% offsets set to space out traces, about 1.5x initial value
freq_offset = 4;        %cpm
tension_offset = 65;    %kPa

% figure generation
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,9,11] );

% plot frequency
ax(1) = subplot(2,1,2);
hold on
for i = 1:nF
    plot(d{i}.effect_vals(:, d{i}.sweep_var), d{i}.f-freq_offset*i, 'k', 'LineWidth', 1.5); 
    yline(d{i}.f(1)-freq_offset*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    f_ends_number(i, :) = d{i}.f([1, end])-freq_offset*i;
    f_ends(i, :) = d{i}.f([1, end]);
end

ax(2) = subplot(2,1,1);

hold on
for i = 1:nF
    plot(d{i}.effect_vals(:, d{i}.sweep_var), d{i}.plateau_p-tension_offset*i, 'k', 'LineWidth', 1.5);
    yline(d{i}.plateau_p(1)-tension_offset*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    plateau_ends_number(i, :) = d{i}.plateau_p([1, end])-tension_offset*i;
    plateau_ends(i, :) = d{i}.plateau_p([1, end]);
end

% Axis 1 (frequency, bottom axis)
axes(ax(1));
xlim([min(d{i}.effect_vals(:, d{i}.sweep_var)), max(d{i}.effect_vals(:, d{i}.sweep_var))])
ylim([-20, 3])
ylabel('Frequency (cpm)')
xlabel(sprintf('Scaling constants'));
[~, sorterInd] = sort(f_ends_number(:, 1));
set(ax(1).YAxis, 'TickLabel',fliplr(d{i}.names(1:5)))
set(ax(1), 'XTick', [0 0.5 1], 'YTick',sort(f_ends_number(:, 1)),'YTickLabelMode', 'manual')

box off
% add end labels
[~, sorterInd] = sort(f_ends_number(:, 2));
tmp = axes('Position', ax(1).Position, 'xlim', ax(1).XLim, 'XTick', [], 'ylim', ax(1).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(f_ends_number(:, 1)), 'YAxisLocation', 'right');
set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(f_ends(sorterInd, 2)./f_ends(sorterInd, 1), 2)-1).*100))
box off

% Axis 2 (tension, top axis)
axes(ax(2));
xlim([min(d{i}.effect_vals(:, d{i}.sweep_var)), max(d{i}.effect_vals(:, d{i}.sweep_var))])
ylim([-300 3])

ylabel('Tension (mN)')

[~, sorterInd] = sort(plateau_ends_number(:, 1));
set(ax(2).YAxis, 'TickLabel',fliplr(d{i}.names(1:5)))
set(ax(2), 'XTickLabels', {}, 'YTick',sort(plateau_ends_number(:, 1)),'YTickLabelMode', 'manual')

box off
% add end labels
[~, sorterInd] = sort(plateau_ends_number(:, 2));
tmp = axes('Position', ax(2).Position, 'XTick', [], 'xlim', ax(2).XLim, 'ylim', ax(2).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(plateau_ends_number(:, 1)), 'YAxisLocation', 'right');
set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(plateau_ends(sorterInd, 2)./plateau_ends(sorterInd, 1), 2)-1).*100))

box off

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/1D_multiSweeps_%s', datestr(datetime, 'yymmddHHMMSS')), 'svg')
