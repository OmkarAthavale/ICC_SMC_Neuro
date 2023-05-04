%%% optimisation_results.m
%%% Omkar N. Athavale, May 2023
%%% Plots the results of optimisation procedures and prints summary statistics
%%% in combination using saved data files

% ---INPUTS---
% data inputs
smc_data_path = '../data/optim_SMC_230504200253';
icc_data_path = '../data/optim_ICC_230502001619';

% plot options
histogram_edges = 0:0.05:1;
y_limits = [0 1];
save_plot = true;

k_iAno1_cluster_division = 0.2;

% ------------
addpath(genpath('../'));

% load and combine data
icc = load(icc_data_path);
smc = load(smc_data_path);

if icc.n ~= smc.n
    error('both SMC and ICC step should have the same n to plot');
end

sol = [icc.sol(:, 1:2), smc.sol(:, 1:2), icc.sol(:, 3), smc.sol(:, 3)];
fval = [icc.fval, smc.fval];

names = {'k_{iAno1}', 'k_{iNSCC}', 'k_{iCa50}', 'k_{iSK}', 'p_{iICC}', 'p_{iSMC}'};

sol_plot = sol(:, 1:4);
n_var = size(sol_plot, 2);
pts = ones(size(sol_plot));
pts = pts.*[1:n_var];

% figure plotting
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,8,6] );

% box plot
boxplot(reshape(sol_plot, 1, []), reshape(pts, 1, []), ...
    'plotstyle', 'traditional', 'boxstyle', 'outline', ...
    'Symbol','', 'color', 'k', 'Widths', 0.25)

hold on;

% generate and plot histograms
vert = [];
x_offset = -0.2;

for var = 1:n_var
    [count, edge] = histcounts(sol_plot(:, var), histogram_edges);
    for i = 1:length(count)
        vert(4*(i-1)+1:4*i, :) =   [var+x_offset, edge(i); 
                                    var+x_offset, edge(i+1); 
                                    var+x_offset+0.25*count(i)./max(count), edge(i+1); 
                                    var+x_offset+0.25*count(i)./max(count), edge(i)
                                   ];
        faces(i, :) = 4*(i-1)+1:4*i;
        
    end
    vert(:, 1) = vert(:, 1) + 0.25;
    patch('Faces', faces, 'Vertices', vert, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', [0.4 0.4 0.4])
end

set(gca, 'XTick', 0.1+(1:n_var), 'XTickLabel', names(1:n_var), 'TickLabelInterpreter', 'tex')

ylabel('Parameter value')
xlim([0.5 n_var+0.5])
ylim(y_limits)

if save_plot
    set(h, 'PaperPositionMode', 'auto')
    saveas(h, sprintf('../generated_fig/optim_results_%d_%d_%s', y_limits, datestr(datetime, 'yymmddHHMMSS')), 'svg')
end

% Print statistics
disp(names);

fprintf('Overall:\nMedian parameter: %.4f %.4f %.4f %.4f %.4f %.4f \nMedian+/-IQR objective: %.4f+/-%.4f  %.4f+/-%.4f%%\n',...
median(sol),...
100.*median(fval),...
100.*(quantile(fval, 0.75, 1) - quantile(fval, 0.25, 1)));
fprintf('\n')

% cluster masks
low_mask = icc.sol(:, 1)<k_iAno1_cluster_division & icc.sol(:,1)< 0.38 & icc.sol(:, 3)>3;
high_mask = icc.sol(:, 1)>k_iAno1_cluster_division & icc.sol(:,1)< 0.38 & icc.sol(:, 3)>3;
disp(names([1, 2, 5]));

% Low kiAno1 cluster
fprintf('Low k_iAno1:\nMedian parameter: %.4f %.4f %.4f \nMedian+/-IQR objective: %.4f+/-%.4f%%\n',...
median(icc.sol(low_mask, :)), ...
100.*median(icc.fval(low_mask)), ...
100.*(quantile(icc.fval(low_mask), 0.75) - quantile(icc.fval(low_mask), 0.25)))
fprintf('\n')

% High kiAno1 cluster
fprintf('High k_iAno1:\nMedian parameter: %.4f %.4f %.4f \nMedian+/-IQR objective: %.4f+/-%.4f%%\n',...
median(icc.sol(high_mask, :)), ...
100.*median(icc.fval(high_mask)), ...
100.*(quantile(icc.fval(high_mask), 0.75) - quantile(icc.fval(high_mask), 0.25)))
fprintf('\n')

% IQRs for sensitivity analysis

[quantile(icc.sol(high_mask, 1:2), 0.25), quantile(smc.sol(:, 1:2), 0.25); quantile(icc.sol(high_mask, 1:2), 0.75), quantile(smc.sol(:, 1:2), 0.25)]'

fprintf('[%.5f, %.5f],\n',...
[quantile(icc.sol(high_mask, 1:2), 0.1), quantile(smc.sol(:, 1:2), 0.1); quantile(icc.sol(high_mask, 1:2), 0.9), quantile(smc.sol(:, 1:2), 0.9)])
