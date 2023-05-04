%%% baseline_plot.m
%%% Omkar N. Athavale, May 2023
%%% Run and plot simulation for an extended duration (300 s) with no
%%% stimulation

% run simulation
[t, s, a] = ICC_SMC_Neuro([0 0 0 0 0], [1 1 1], 0, 0, [0 300000]);

T = a(:, 7);
Vm_ICC = s(:,3); 
Vm_SMC = s(:,1); 

% plot VmICC, VmSMC and tension on three subplots
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,18,10] );

subplot(3, 1, 1)
plot(t/1000, Vm_ICC, 'k','LineWidth', 1.5);
ylabel({'Membrane potential';'(mV)'});
set(gca, 'XTick', 0:120:1200, 'YTick', [-60:30:0])
xlim([0 300])
ylim([-75 -20])

subplot(3, 1, 2)
plot(t/1000, Vm_SMC, 'k','LineWidth', 1.5)
ylabel({'Membrane potential';'(mV)'});
set(gca, 'XTick', 0:120:1200, 'YTick', [-60:30:0])
xlim([0 300])
ylim([-75 -20])

subplot(3, 1, 3)
plot(t/1000, T, 'k','LineWidth', 1.5)
ylabel({'Tension';'(kPa)'});
set(gca, 'XTick', 0:120:1200, 'YTick', [0:25:50])
xlim([0 300])
ylim([0 50])

xlabel('Time (s)');

% save figure
set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/baseline_3min_%s', datestr(datetime, 'yymmddHHMMSS')), 'svg')
