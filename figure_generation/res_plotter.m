

names = {'Ano1', 'NSCC', 'Tension', 'SK', 'IP3', 'Inhibitory dosage', 'Excitatory dosage'};

n = 5;
effect_var = 6;
duration = [0 120000];
weights = [3.149566984343386, 1.178185077905521, 1];
effect_vals = ones(n, 5).*[0.325665483807710,0.774750185285083, 0.882382705973490,0.441452785127037, 0]; % rows: Ano1, NSCC, Tension, SK, IP3
% effect_vals = ones(n, 5).*[0.470752280897857,0.722024398246064, 0,0, 0]; % rows: Ano1, NSCC, Tension, SK, IP3
% effect_vals(:, effect_var) = linspace(0, 1, n);
% effect_vals(:, 1) = effect_vals(:, 2);%linspace(0, 1, n);
% effect_vals(:, 1) = 0.8;
x_e = 0;
x_i = linspace(0, 1, n);
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,11] );

ax(1) = subplot(2,1,1);
colororder([1 1 1] .* linspace(0, 0.75, n)')

ax(2) = subplot(2,1,2);
colororder([1 1 1] .* linspace(0, 0.75, n)')

for i = 1:n
    [t0, s, a] = ICC_SMC_GT_Neuro_V5_v1(effect_vals(i, :), weights, x_e, x_i(i), duration);
    [tT, T] = start_alignment(t0, a(:, 7), [84000, 120000]);
    [tICC, Vm_ICC] = start_alignment(t0, s(:,3), [84000, 120000]) ;
    [tSMC, Vm_SMC] = start_alignment(t0, s(:,1), [84000, 120000]) ;
    
    subplot(2,1,1);
    
    plot(tICC./1000, Vm_ICC, 'k', 'LineWidth', 0.5);
    
    hold on;
    
    subplot(2,1,2);
    plot(tT./1000, T, 'k', 'LineWidth', 0.5);
    hold on;
end

set(ax(1), 'XLim', [0 6], 'YLim', [-70 -20], 'XTickLabels', {});
ax(1).YLabel.String = 'Potential (mV)';
set(ax(2), 'XLim', [0 6], 'YLim', [0 16]);
ax(2).XLabel.String = 'Time (s)';
ax(2).YLabel.String = 'Tension (mN)';
linkaxes(ax, 'x')

% set(h, 'PaperPositionMode', 'auto')
% saveas(h, 'Ano1_NSCC', 'svg')
% ax(1).Title.String = sprintf('%s in range %d to %d', names{effect_var}, min(effect_vals(:, effect_var)), max(effect_vals(:, effect_var)));
