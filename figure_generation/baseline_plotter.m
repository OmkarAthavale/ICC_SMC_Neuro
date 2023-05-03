% baseline traces

[t, s, a] = ICC_SMC_GT_Neuro_V5([0 0 0 0 0], 0, 0, [0 300000]);

T = a(:, 7);
Vm_ICC = s(:,3); 
Vm_SMC = s(:,1); 

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,22,4] );


plot(t/1000, Vm_ICC, 'k','LineWidth', 1.5);
hold on
plot(t/1000, Vm_SMC, 'Color', [0.7 0.7 0.7],'LineWidth', 1.5)

xlabel('Time (s)');
ylabel({'Membrane potential';'(mV)'});

ylim([0 16])
set(gca, 'XTick', 0:120:1200, 'YTick', [-60:30:0])

set(h, 'PaperPositionMode', 'auto')
saveas(h, 'baseline_3min', 'svg')