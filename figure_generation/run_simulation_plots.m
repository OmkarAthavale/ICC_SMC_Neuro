names = {'Ano1', 'NSCC', 'Tension', 'SK', 'IP3'};

%% three changing
% [X, Y, Z] = meshgrid(linspace(0,1,30));
% x_i = linspace(0, 1, 5)';
% x_e = 0;
% effect_vals = [reshape(X, [], 1), reshape(Y, [], 1), reshape(Z, [], 1)];


%% two changing
% N = 2;
% n = N*N;
% v1 = 1;
% v2 = 2;
% 
% [X, Y] = meshgrid(linspace(0,1,N));
% x_i = 1;
% x_e = 0;
% effect_vals = zeros(n, 5);
% 
% effect_vals(:, v1) = reshape(X, [], 1);
% effect_vals(:, v2) = reshape(Y, [], 1);

%% one changing
n = 11;
effect_var = 1;

effect_vals = zeros(n, 5); % rows: Ano1, NSCC, Tension, SK, IP3
effect_vals(:, effect_var) = linspace(0, 1, n);
effect_vals = [0.627769856911043	0.776142555889738	0.979668821887735	0.228026943965982 1];

weights = [3.149566984343386, 1.178185077905521, 5];
effect_vals = ones(n, 5).*[0.325665483807710,0.774750185285083, 0.882382705973490,0.441452785127037, 0.92];

% effect_vals(:, 1) = 0.8;
x_i = linspace(0, 1, 11);%zeros(1, 11);
x_e = linspace(0, 1, 11);%linspace(0, 1, 11);

%% run sims
f = zeros(n, 1);
peak_p = zeros(n, 1);
plateau_p = zeros(n, 1);

for i = 1:n
    [t, s, a] = ICC_SMC_GT_Neuro_V5_v1(effect_vals(i, :), weights, x_e(i), x_i(i));
    T = a(:, 7);
    Vm_ICC = s(:,3); 
    Vm_SMC = s(:,1); 
    [~, peak_p_ICC(i), plateau_p_ICC(i)] = calculate_frequency(t, Vm_ICC, [60000 180000]);
    [f(i), peak_p(i), plateau_p(i)] = calculate_frequency(t, T, [60000 180000]);
    %     [plateau_a, plateau_p] = calculate_plateau();
    %     [peak_a, peak_p] = calculate_peak();
end

%% 1D over stim range
% figure
% % plot(x_i, f/max(f))
% hold on
% plot(x_i, peak_p)
% plot(x_i, plateau_p)
% 
% legend({'peak p', 'plateau p'})
%% Save 1D data
% save(sprintf('1DSweep_%s_', datestr(datetime, 'yymmddHHMMSS'), names{effect_var}), 'effect_vals', 'f', 'peak_p', 'plateau_p', 'names', 'effect_var')
%% Save 2D data
% save(sprintf('2DSweep_%s', datestr(datetime, 'yymmddHHMMSS')), 'effect_vals', 'f', 'peak_p', 'plateau_p','peak_p_ICC', 'plateau_p_ICC', 'v1', 'v2', 'N')
%% Save 3D data
% save('3DSweep', 'effect_vals', 'f', 'peak_p', 'plateau_p')
%% 3D scatter plot inhibitory scaling
% figure;
% scatter3(effect_vals(:, 1), effect_vals(:, 2), effect_vals(:, 3), 30, f, 'filled')
% xlabel('ano1')
% ylabel('nscc')
% zlabel('tension')
% title('Frequency (cpm)')
% 
% figure;
% scatter3(effect_vals(:, 1), effect_vals(:, 2), effect_vals(:, 3), 30, peak_p, 'filled')
% xlabel('ano1')
% ylabel('nscc')
% zlabel('tension')
% title('Initial amplitude (mN)')
% 
% figure;
% scatter3(effect_vals(:, 1), effect_vals(:, 2), effect_vals(:, 3), 30, plateau_p, 'filled')
% xlabel('ano1')
% ylabel('nscc')
% zlabel('tension')
% title('Plateau amplitude (mN)')


%% Two var change plot

% figure; 
% subplot(2,1,1)
% surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(peak_p_ICC, N, N), 'EdgeColor', 'b')
% 
% zlim([0, 15])
% xlabel(sprintf('%s scaling constant', names{v1}));
% ylabel(sprintf('%s scaling constant', names{v2}));
% zlabel('Peak tension (mN)')
% 
% % subplot(2,1,2)
% hold on;
% surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p_ICC, N, N), 'EdgeColor', 'r')
% zlim([0, 15])
% xlabel(sprintf('%s scaling constant', names{v1}));
% ylabel(sprintf('%s scaling constant', names{v2}));
% zlabel('Plateau tension (mN)')

%% contour tension 2D
% figure; 
% plateau_p_rescale = (plateau_p+66)/(plateau_p(1)+66);
% contourf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p_rescale, N, N), [94.8185619463529;92.7261969788078;83.0232202801652;76.3685106316160]./100)

%% contour vm icc 2D
% figure; 
% plateau_p_ICC_rescale = (plateau_p_ICC)/(plateau_p_ICC(1));
% contourf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p_ICC_rescale, N, N), [1;0.885236705411731;0.835212426850925;0.797609950489086;0.769498776686641])
% xlim([0 1])
% ylim([0 1])
% 
% xlabel('kAno1')
% ylabel('kNSCC')
% colormap(bone)
% caxis([0 1]);
% c = colorbar('Ticks',flipud([1;0.885236705411731;0.835212426850925;0.797609950489086;0.769498776686641]), 'TickLabels', fliplr({'100%',  '89%', '84%', '80%', '77%'}));
% c.Label.String = 'Percentage of no stimulation V_{ICC} amplitude';
% 
% hold on;
% plot([zeros(1, 36);sol(:, 1)'], [zeros(1, 36);sol(:, 2)'], 'r:')
% scatter(sol(:, 1), sol(:, 2), 'r.')
% 
% line([0,0], [0, 253/180], 'Color', 'g', 'LineWidth', 2);
% line([0,1.265], [0, 0], 'Color', 'g', 'LineWidth', 2);
% line([0,1.265], [253/180, 0], 'Color', 'g', 'LineWidth', 2);
% line([0,1.265], [253/180, 0], 'Color', 'g', 'LineWidth', 2);
%% Still 2D
% figure; 
% m1 = reshape(effect_vals(:, v1), N, N);
% m2 = reshape(effect_vals(:, v2), N, N);
% d = reshape(plateau_p, N, N);
% 
% subplot(2,1,1)
% plot(m1(1, :), d(1, :))
% hold on
% plot(m1(9, :), d(9, :))
% plot(m1(17, :), d(17, :))
% plot(m1(end, :), d(end, :))
% 
% subplot(2,1,2)
% plot(m2(:, 1), d(:, 1))
% hold on
% plot(m2(:, 9), d(:, 9))
% plot(m2(:, 17), d(:, 17))
% plot(m2(:, end), d(:, end))
% 
% zlim([0, 15])
% xlabel(sprintf('%s scaling constant', names{v1}));
% ylabel(sprintf('%s scaling constant', names{v2}));
% zlabel('Peak tension (mN)')
% 
% subplot(2,1,2)
% surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p, N, N))
% zlim([0, 15])
% xlabel(sprintf('%s scaling constant', names{v1}));
% ylabel(sprintf('%s scaling constant', names{v2}));
% zlabel('Plateau tension (mN)')

%% Single var change plots
% h = figure('Units', 'centimeters');
% set(h, 'position', [18,18,7,11] );
% ax(1) = subplot(2,1,1);
% plot(effect_vals(:, effect_var), f, 'k');
% 
% xlim([min(effect_vals(:, effect_var)), max(effect_vals(:, effect_var))])
% ylim([0, 7])
% ylabel('Frequency (cpm)')
% set(ax(1), 'XTickLabels', {})
% 
% ax(2) = subplot(2,1,2);
% % plot([], [], 'k')
% plot(effect_vals(:, effect_var), peak_p);
% hold on
% plot(effect_vals(:, effect_var), plateau_p, 'k');
% 
% xlim([min(effect_vals(:, effect_var)), max(effect_vals(:, effect_var))])
% ylim([0, 15])
% xlabel(sprintf('%s scaling constant', names{effect_var}));
% ylabel('Tension (mN)')
% 
% % ylim([-60, 0])
% % xlabel(sprintf('%s scaling constant', names{effect_var}));
% % ylabel('Peak depolarisation (mV)')
% 
% % set(ax(2), 'XTickLabels', {})
% % legend({'Frequency', 'Peak tension', 'Plateau tension'}, 'Location', 'southoutside')

%% Single var xe or xi change plots %% fig 4%%
indep_var = x_e;

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,11] );
ax(1) = subplot(2,1,2);
plot(indep_var, f, 'k');

xlim([min(indep_var), max(indep_var)])
ylim([0, 7])
ylabel('Frequency (cpm)')
set(ax(1), 'XTickLabels', {})

ax(2) = subplot(2,1,1);
% plot([], [], 'k')
plot(indep_var, peak_p, 'r');
hold on
plot(indep_var, plateau_p, 'k');

xlim([min(indep_var), max(indep_var)])
ylim([0, 15])
xlabel(sprintf('x_i'));
ylabel('Tension (mN)')

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('sweeping_%d_%d', max(x_e), max(x_i)), 'svg')

% ylim([-60, 0])
% xlabel(sprintf('%s scaling constant', names{effect_var}));
% ylabel('Peak depolarisation (mV)')

% set(ax(2), 'XTickLabels', {})
% % legend({'Frequency', 'Peak tension', 'Plate

%% Single var change plots combo
% files = ls('1DSweep_*');
% nF = size(files, 1);
% for i = 1:nF
%     d{i} = load(files(i, :));
% end
% 
% h = figure('Units', 'centimeters');
% set(h, 'position', [18,18,7,11] );
% ax(1) = subplot(2,1,1);
% hold on
% for i = 1:nF
%     plot(d{i}.effect_vals(:, d{i}.effect_var), d{i}.f-4*i, 'k', 'LineWidth', 1.5);
%     yline(d{i}.f(1)-4*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
%     f_ends_number(i, :) = d{i}.f([1, end])-4*i;
%     f_ends(i, :) = d{i}.f([1, end]);
% %     text(0.02, f_ends_number(i, 1)-0.9, d{i}.names{i}, 'FontSize', 8)
% end
% 
% 
% 
% ax(2) = subplot(2,1,2);
% % plot([], [], 'k')
% % plot(effect_vals(:, effect_var), peak_p);
% hold on
% for i = 1:nF
%     plot(d{i}.effect_vals(:, d{i}.effect_var), d{i}.plateau_p-14*i, 'k', 'LineWidth', 1.5);
%     yline(d{i}.plateau_p(1)-14*i, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--');
%     plateau_ends_number(i, :) = d{i}.plateau_p([1, end])-14*i;
%     plateau_ends(i, :) = d{i}.plateau_p([1, end]);
% %     text(0.02, plateau_ends_number(i, 1)-03, d{i}.names{i}, 'FontSize', 8)
% end
% 
% 
% 
% % Axis 1
% axes(ax(1));
% xlim([min(d{i}.effect_vals(:, d{i}.effect_var)), max(d{i}.effect_vals(:, d{i}.effect_var))])
% ylim([-20, 3])
% ylabel('Frequency (cpm)')
% [~, sorterInd] = sort(f_ends_number(:, 1));
% set(ax(1), 'XTickLabels', {}, 'YTick',sort(f_ends_number(:, 1)),'YTickLabelMode', 'manual')
% set(ax(1).YAxis, 'TickLabel',fliplr(d{i}.names))
% 
% box off
% [~, sorterInd] = sort(f_ends_number(:, 2));
% tmp = axes('Position', ax(1).Position, 'xlim', ax(1).XLim, 'XTick', [], 'ylim', ax(1).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(f_ends_number(:, 1)), 'YAxisLocation', 'right');
% set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(f_ends(sorterInd, 2)./f_ends(sorterInd, 1), 2)-1).*100))
% box off
% % Axis 2
% axes(ax(2));
% xlim([min(d{i}.effect_vals(:, d{i}.effect_var)), max(d{i}.effect_vals(:, d{i}.effect_var))])
% ylim([-67 3])
% xlabel(sprintf('Scaling constants'));
% ylabel('Tension (mN)')
% 
% [~, sorterInd] = sort(plateau_ends_number(:, 1));
% set(ax(2), 'XTick', [0 0.5 1], 'YTick',sort(plateau_ends_number(:, 1)),'YTickLabelMode', 'manual')
% set(ax(2).YAxis, 'TickLabel',fliplr(d{i}.names))
% 
% box off
% [~, sorterInd] = sort(plateau_ends_number(:, 2));
% tmp = axes('Position', ax(2).Position, 'XTick', [], 'xlim', ax(2).XLim, 'ylim', ax(2).YLim, 'color', 'none','YTickLabelMode', 'manual', 'YTick',sort(plateau_ends_number(:, 1)), 'YAxisLocation', 'right');
% set(tmp.YAxis, 'TickLabel',sprintf('%+.0f%%\n', (round(plateau_ends(sorterInd, 2)./plateau_ends(sorterInd, 1), 2)-1).*100))
% 
% box off
% 
% % set(ax(2), 'XTickLabels', {})
% % legend({'Frequency', 'Peak tension', 'Plateau tension'}, 'Location', 'southoutside')
% set(gcf, 'PaperPositionMode', 'auto')
% 
