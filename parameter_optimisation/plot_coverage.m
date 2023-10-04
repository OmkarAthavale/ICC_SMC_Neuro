% display the percentage change in solution values per intialisation 
% (note randomisation)
for randomSeed = 1:100
for i = 1:48
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

%%
for i = 1:100
    seq = randperm(48, 48);
    margChange(:, :, i) = cumsum(sol(seq(2:end), :))./cumsum(sol(seq(1:end-1), :)) -1;
end
seq = 1:48;
margChange= vecnorm(sol(seq(2:end), :)-sol(seq(1:end-1), :), 2, 2)cumsum(sol(seq(2:end), :))./cumsum(sol(seq(1:end-1), :)) -1;

figure; plot(mean(margChange, 3));
yline(0.01)
yline(-0.01)
xlim([0 48])
ylim([-0.1, 0.1])
xlabel('Number of iterations')
ylabel('Marginal change in cumulative parameter value')