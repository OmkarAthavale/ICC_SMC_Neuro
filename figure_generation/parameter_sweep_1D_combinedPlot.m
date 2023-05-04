%%% parameter_sweep_1D_combinedPlot.m
%%% Omkar N. Athavale, May 2023
%%% Plot sweeps across k_xXXXX parameters from 0 - 1

names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'k_{eIP3}', 'p_{iICC}', 'p_{iSMC}', 'p_{e}',};

% --- INPUTS ---
var_seq = 1:2; % variable index to sweep (max 2)
sweep_domain = repmat([0; 1], 1, 5); % range to sweep (all variables same)
x_i = ones(1, 5);
x_e = zeros(1, 5);

n = 11; % number of points to sweep (all variables same)
% --------------

for k = 1:length(var_seq)
    sweep_var = var_seq(k);
    effect_vals = zeros(n, 5);
    effect_vals(:, sweep_var) = linspace(0, 1, n);
    effect_vals = [0.627769856911043	0.776142555889738	0.979668821887735	0.228026943965982 1];
    
    weights = [3.149566984343386, 1.178185077905521, 5];
    effect_vals = ones(n, 5).*[0.325665483807710,0.774750185285083, 0.882382705973490,0.441452785127037, 0.92];
    
    % run simulations
    for i = 1:n
        [t, s, a] = ICC_SMC_Neuro(effect_vals(i, :), weights, x_e(k), x_i(k));
        T = a(:, 7);
        Vm_ICC = s(:,3);
        Vm_SMC = s(:,1);
        
        [f(i), peak_p(i), plateau_p(i)] = calculate_metrics(t, T, [60000 180000]);
    end
    
    save(sprintf('../data/Multi_1DSweep_%s_', datestr(datetime, 'yymmddHHMMSS'), names{sweep_var}))
end

%% Single var change plots combo
files = ls('../data/Multi_1DSweep_*');
nF = size(files, 1);
for i = 1:nF
    d{i} = load(files(i, :));
end

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,11] );
ax(1) = subplot(2,1,1);
hold on
for i = 1:nF
    plot(d{i}.effect_vals(:, d{i}.effect_var), d{i}.f-4*i, 'k', 'LineWidth', 1.5);
    yline(d{i}.f(1)-4*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    f_ends_number(i, :) = d{i}.f([1, end])-4*i;
    f_ends(i, :) = d{i}.f([1, end]);
    %     text(0.02, f_ends_number(i, 1)-0.9, d{i}.names{i}, 'FontSize', 8)
end



ax(2) = subplot(2,1,2);
% plot([], [], 'k')
% plot(effect_vals(:, effect_var), peak_p);
hold on
for i = 1:nF
    plot(d{i}.effect_vals(:, d{i}.effect_var), d{i}.plateau_p-14*i, 'k', 'LineWidth', 1.5);
    yline(d{i}.plateau_p(1)-14*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
    plateau_ends_number(i, :) = d{i}.plateau_p([1, end])-14*i;
    plateau_ends(i, :) = d{i}.plateau_p([1, end]);
    %     text(0.02, plateau_ends_number(i, 1)-03, d{i}.names{i}, 'FontSize', 8)
end



% Axis 1
axes(ax(1));
xlim([min(d{i}.effect_vals(:, d{i}.effect_var)), max(d{i}.effect_vals(:, d{i}.effect_var))])
ylim([-20, 3])
ylabel('Frequency (cpm)')
[~, sorterInd] = sort(f_ends_number(:, 1));
set(ax(1), 'XTickLabels', {}, 'YTick',sort(f_ends_number(:, 1)),'YTickLabelMode', 'manual')
set(ax(1).YAxis, 'TickLabel',fliplr(d{i}.names))

box off
[~, sorterInd] = sort(f_ends_number(:, 2));
tmp = axes('Position', ax(1).Position, 'xlim', ax(1).XLim, 'XTick', [], 'ylim', ax(1).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(f_ends_number(:, 1)), 'YAxisLocation', 'right');
set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(f_ends(sorterInd, 2)./f_ends(sorterInd, 1), 2)-1).*100))
box off
% Axis 2
axes(ax(2));
xlim([min(d{i}.effect_vals(:, d{i}.effect_var)), max(d{i}.effect_vals(:, d{i}.effect_var))])
ylim([-67 3])
xlabel(sprintf('Scaling constants'));
ylabel('Tension (mN)')

[~, sorterInd] = sort(plateau_ends_number(:, 1));
set(ax(2), 'XTick', [0 0.5 1], 'YTick',sort(plateau_ends_number(:, 1)),'YTickLabelMode', 'manual')
set(ax(2).YAxis, 'TickLabel',fliplr(d{i}.names))

box off
[~, sorterInd] = sort(plateau_ends_number(:, 2));
tmp = axes('Position', ax(2).Position, 'XTick', [], 'xlim', ax(2).XLim, 'ylim', ax(2).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(plateau_ends_number(:, 1)), 'YAxisLocation', 'right');
set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(plateau_ends(sorterInd, 2)./plateau_ends(sorterInd, 1), 2)-1).*100))

box off

% set(ax(2), 'XTickLabels', {})
% legend({'Frequency', 'Peak tension', 'Plateau tension'}, 'Location', 'southoutside')
set(gcf, 'PaperPositionMode', 'auto')

