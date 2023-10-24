%%% plot_coverage.m
%%% Omkar N. Athavale, October 2023
%%% Plots the resampled marginal change in fitted parameter values per addiotional iteration of the parameter optimisation. 
%%% Uses saved data files for Step 1 to calculate this. 

% load a saved Step 1 file
addpath('..')
load('data/optim_ICC_data')

% resample the sequence of the 48 iterations 100 times 
for randomSeed = 1:100
	for i = 1:48
	% calculate the running median as more iterations are completed in the resampled sequence
		cumulativeMed(i, :, randomSeed) = median(sol(randperm(48, i), :), 1); 
	end
end

cumulativeMed = sum(cumulativeMed, 3); 
figure; 
plot((diff(cumulativeMed)./cumulativeMed(1:end-1, :)).*100)
yline(1)
yline(-1)
xlabel('Number of initialisations')
ylabel({'Marginal change in solution value' , 'per additional intitialisation (%)'})
ylim([-50, 50])
legend({'k_iAno1', 'k_iNSCC', 'p_iICC'})