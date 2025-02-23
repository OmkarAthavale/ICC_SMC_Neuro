%%% baseline_plot.m
%%% Omkar N. Athavale, May 2023
%%% Run and plot simulation for 120 s with stimulation at varying levels

addpath('../matlab_common/')

% run simulations with stim for 60 seconds
[t01, T01, Vm_ICC01, Vm_SMC01] = run_sim_stim(0, 10);
[t10, T10, Vm_ICC10, Vm_SMC10] = run_sim_stim(10, 0);
[t11, T11, Vm_ICC11, Vm_SMC11] = run_sim_stim(10, 10);

% plot VmICC and tension for each stimulation
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,13,11] );

subplot(2, 3, 1)
plot(t01/1000, Vm_ICC01, 'k','LineWidth', 1.5);

ylabel({'V_{ICC}';'(mV)'});
set(gca, 'XTick', 0:60:1200, 'YTick', [-60:30:0], 'XTickLabel', [])
xlim([60 240])
ylim([-75 -20])

subplot(2, 3, 4)
plot(t01/1000, T01, 'k','LineWidth', 1.5);

ylabel({'Tension';'(kPa)'});
set(gca, 'XTick', 60:60:1200, 'XTickLabels', 0:60:240, 'YTick', [0:25:50])
xlim([60 240])
ylim([0 50])

xlabel('Time (s)');


subplot(2, 3, 2)
plot(t10/1000, Vm_ICC10, 'k','LineWidth', 1.5);

set(gca, 'XTick', 0:60:1200, 'YTick', [-60:30:0], 'XTickLabel', [],  'YTickLabel', [])
xlim([60 240])
ylim([-75 -20])

subplot(2, 3, 5)
plot(t10/1000, T10, 'k','LineWidth', 1.5);

set(gca, 'XTick', 60:60:1200, 'XTickLabels', 0:60:240, 'YTick', [0:25:50],  'YTickLabel', [])
xlim([60 240])
ylim([0 50])

xlabel('Time (s)');


subplot(2, 3, 3)
plot(t11/1000, Vm_ICC11, 'k','LineWidth', 1.5);

set(gca, 'XTick', 0:60:1200, 'YTick', [-60:30:0], 'XTickLabel', [],  'YTickLabel', [])
xlim([60 240])
ylim([-75 -20])

subplot(2, 3, 6)
plot(t01/1000, T01, 'k','LineWidth', 1.5);

set(gca, 'XTick', 60:60:1200, 'XTickLabels', 0:60:240, 'YTick', [0:25:50],  'YTickLabel', [])
xlim([60 240])
ylim([0 50])

xlabel('Time (s)');



% save figure
set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/stimulation_varying_%s', datestr(datetime, 'yymmddHHMMSS')), 'svg')

function [t, T, Vm_ICC, Vm_SMC] = run_sim_stim(f_e, f_i)

% run simulation
[t, s, a] = ICC_SMC_Neuro_Tvar(f_e, f_i);

T = a(:, 48);
Vm_ICC = s(:,3); 
Vm_SMC = s(:,1); 
end