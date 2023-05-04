%%% sweep_plots.m
%%% Omkar N. Athavale, May 2023
%%% Plot results from 1D or 2D parameter sweeps
%%% Run the data load section first, then the seciton of the figure to plot

%% Data load
data_path = '../data/2DSweep_230429201029';

load(data_path)

if length(sweep_var) == 2
    v1 = sweep_var(1);
    v2 = sweep_var(2);
end

%% 2D surface plot of VmICC and tension
% Blue is peak, red is plateau

figure;
subplot(2,1,1) % Vm_ICC
surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(peak_p_ICC, N, N), 'EdgeColor', 'b')
hold on;
surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p_ICC, N, N), 'EdgeColor', 'r')

zlim([0, 50])
xlabel(sprintf('%s scaling constant', names{v1}));
ylabel(sprintf('%s scaling constant', names{v2}));
zlabel('Vm_ICC (mV)')

subplot(2,1,2) % Tension
surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(peak_p, N, N), 'EdgeColor', 'b')
hold on;
surf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p, N, N), 'EdgeColor', 'r')

zlim([0, 15])
xlabel(sprintf('%s scaling constant', names{v1}));
ylabel(sprintf('%s scaling constant', names{v2}));
zlabel('Tension (kPa)')

%% Isolines for experimental values of percentage change in Vm_ICC amplitude
% additionally plot the Step 1 parameter optimisation solutions for Ano1
% and NSCC

optim_data = '../data/optim_ICC_230502001619'; % '' if none
isoline = [1;0.885236705411731;0.835212426850925;0.797609950489086;0.769498776686641]; % for [0, 2.5, 5, 7.5, 10] Hz interpolated from Kim 2003, see objFun_ICC.m

figure;
plateau_p_ICC_rescale = (plateau_p_ICC)/(plateau_p_ICC(1));
contourf(reshape(effect_vals(:, v1), N, N), reshape(effect_vals(:, v2), N, N), reshape(plateau_p_ICC_rescale, N, N), isoline)
xlim([0 1])
ylim([0 1])

xlabel('kAno1')
ylabel('kNSCC')
colormap(bone)
caxis([0 1]);
c = colorbar('Ticks',flipud(isoline), 'TickLabels', fliplr({'100%',  '89%', '84%', '80%', '77%'}));
c.Label.String = 'Percentage of no stimulation V_{ICC} amplitude';

if ~strcmp(optim_data, '')
    hold on;
    opt = load(optim_data);
    
    % plot contraints for Ano1, NSCC optim
    line([0,0], [0, 253/180], 'Color', 'g', 'LineWidth', 2);
    line([0,1.265], [0, 0], 'Color', 'g', 'LineWidth', 2);
    line([0,1.265], [253/180, 0], 'Color', 'g', 'LineWidth', 2);
    line([0,1.265], [253/180, 0], 'Color', 'g', 'LineWidth', 2);
    
    % plot solutions
    plot([zeros(1, opt.n);opt.sol(:, 1)'], [zeros(1, opt.n);opt.sol(:, 2)'], 'r:')
    scatter(opt.sol(:, 1), opt.sol(:, 2), 'r.')
end

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

