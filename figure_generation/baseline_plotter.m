%%% baseline_plot.m
%%% Omkar N. Athavale, May 2023
%%% Run and plot simulation for an extended duration (300 s) with no
%%% stimulation

addpath('../matlab_common/')

% run simulation
[t, s, a] = ICC_SMC_Neuro([0 0 0 0 0], [1 1 1], 0, 0, [0 300000]);

T = a(:, 7);
Vm_ICC = s(:,3); 
Vm_SMC = s(:,1); 

%% quantify variation over time
dat = {'Vm_ICC', 'Vm_SMC', 'T'};

fprintf('%10s: %10s (%10s %10s) | %10s (%10s %10s) | %10s (%10s %10s) |\n', 'VarName', 'Mean peak', 'Min peak', 'Max peak',  'Mean inter', 'Min inter', 'Max inter',  'Mean RMP', 'Min RMP', 'Max RMP');

for i = 1:length(dat)
    currDat = eval(dat{i});
    [pk,loc] = findpeaks(currDat, 'MinPeakProminence', 10);
    pk = pk(2:end);
    loc = loc(2:end);
    
    mean_peak = mean(pk);
    mean_interval = mean(diff(t(loc)));
    mean_RMP = mean(currDat(loc(1:end-1)+round(diff(loc)./2)));
    
    range_peak = [min(pk), max(pk)];
    range_interval = [min(diff(t(loc))), max(diff(t(loc)))];
    range_RMP = [min(currDat(loc(1:end-1)+round(diff(loc)./2))), max(currDat(loc(1:end-1)+round(diff(loc)./2)))];
    fprintf('%10s: %10.4f (%10.4f %10.4f) | %10.4f (%10.4f %10.4f) | %10.4f (%10.4f %10.4f) |\n', dat{i}, mean_peak, range_peak, mean_interval, range_interval, mean_RMP, range_RMP);
    
end

%% plot VmICC, VmSMC and tension on three subplots
h = figure('Units', 'centimeters');
set(h, 'position', [18,18,18,10] );

subplot(3, 1, 1)
plot(t/1000, Vm_ICC, 'k','LineWidth', 1.5);
ylabel({'V_{ICC}';'(mV)'});
set(gca, 'XTick', 0:60:1200, 'YTick', [-60:30:0], 'XTickLabel', [])
xlim([0 300])
ylim([-75 -20])

subplot(3, 1, 2)
plot(t/1000, Vm_SMC, 'k','LineWidth', 1.5)
ylabel({'V_{SMC}';'(mV)'});
set(gca, 'XTick', 0:60:1200, 'YTick', [-60:30:0], 'XTickLabel', [])
xlim([0 300])
ylim([-75 -20])

subplot(3, 1, 3)
plot(t/1000, T, 'k','LineWidth', 1.5)
ylabel({'Tension';'(kPa)'});
set(gca, 'XTick', 0:60:1200, 'YTick', [0:25:50])
xlim([0 300])
ylim([0 50])

xlabel('Time (s)');

% save figure
set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('../generated_fig/baseline_3min_%s', datestr(datetime, 'yymmddHHMMSS')), 'svg')
