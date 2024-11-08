%%% aligned_event_plot.m
%%% Omkar N. Athavale, May 2023
%%% Plots a single event with aligned start times but peak rising derivative 
%%% across a configurable sweep of parameter values. Default config is for panels of manuscript
%%% Figure 2B.
addpath('../matlab_common/')

names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'k_{eIP3}', 'p_{iICC}', 'p_{iSMC}', 'p_{e}',};

n = 5; % number of equally spaced values in the sweep
effect_var = [1, 2]; % which k parameter(s) to sweep
duration = [0 120000];
weights = [1, 1, 1]; % dummy values since these only matter if f_i or f_e are not 10 Hz or 0 Hz.
effect_vals = zeros(n, 5);
effect_vals(:, effect_var(1)) = linspace(0, 1, n);

if length(effect_var) > 1
    effect_vals(:, effect_var(2)) = effect_vals(:, effect_var(1));
end

f_e = 0;
f_i = 10;

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,10,11] );

ax(1) = subplot(2,1,1);
colororder([1 1 1] .* linspace(0, 0.75, n)')

ax(2) = subplot(2,1,2);
colororder([1 1 1] .* linspace(0, 0.75, n)')

for i = 1:n
    [t0, s, a] = ICC_SMC_Neuro(effect_vals(i, :), weights, f_e, f_i, duration);
    [tT, T] = start_alignment(t0, a(:, 7), [84000, 120000]);
    [tICC, Vm_ICC] = start_alignment(t0, s(:,3), [84000, 120000]) ;
    [tSMC, Vm_SMC] = start_alignment(t0, s(:,1), [84000, 120000]) ;
    
    subplot(2,1,1);
    if Vm_ICC(3000)-Vm_ICC(1) < 5
        lstyle = '--';
    else
        lstyle = '-';
    end
    plV(i) = plot(tICC./1000, Vm_ICC, 'LineStyle', lstyle, 'LineWidth', 0.5);
    
    hold on;
    
    subplot(2,1,2);
    if T(3000)-T(1) < 1
        lstyle = '--';
    else
        lstyle = '-';
    end
    plT(i) = plot(tT./1000, T, 'LineStyle', lstyle, 'LineWidth', 0.5);
    hold on;
end

set(ax(1), 'XLim', [0 6], 'YLim', [-70 -20], 'XTickLabels', {});
ax(1).YLabel.String = 'V_{ICC} (mV)';
set(ax(2), 'XLim', [0 6], 'YLim', [0 50]);
lgd2 = legend(plV, cellfun(@(x) (sprintf('%.2f, ', x(effect_var))), mat2cell(effect_vals, ones(n, 1)), 'UniformOutput', 0), 'Location', 'eastoutside');
lgd2.Title.String = sprintf('%s, ', names{effect_var});

ax(2).XLabel.String = 'Time (s)';
ax(2).YLabel.String = 'Tension (kPa)';
linkaxes(ax, 'x')
lgd2 = legend(plT, cellfun(@(x) (sprintf('%.2f, ', x(effect_var))), mat2cell(effect_vals, ones(n, 1)), 'UniformOutput', 0), 'Location', 'eastoutside');
lgd2.Title.String = sprintf('%s, ', names{effect_var});

if length(effect_var) > 1
    saveFile = sprintf('../generated_fig/event_sweep_%s_%s_%s', names{effect_var(1)}, names{effect_var(2)}, datestr(datetime, 'yymmddHHMMSS'));
else
    saveFile = sprintf('../generated_fig/event_sweep_%s_%s', names{effect_var(1)}, datestr(datetime, 'yymmddHHMMSS'));
end

set(h, 'PaperPositionMode', 'auto')
saveas(h, saveFile, 'svg')
