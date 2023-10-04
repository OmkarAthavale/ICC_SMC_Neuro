%%% optim_ICC.m
%%% Omkar N. Athavale, May 2023
%%% Solves a non-linear optimisation problem to identify best fitting
%%% parameters for k_iAno1, k_iNSCC, and p_iICC. 

addpath(genpath('../'));
rng(106676, 'twister')

% constraint definition, see "help fmincon"
lb = [0; 0; -5];
ub = [1; 1; 5];
A = [10/9, 1, 0];
b = [253/180];

% initial guess sampling
n = 48; % number of inital guesses to sample
a = sobolset(3);
p = scramble(a,'MatousekAffineOwen');
candidate = net(p,1000);
candidate((candidate(:, 1)*10/9+candidate(:, 2)) > 253/180, :) = [];
x0 = candidate(1:n, :); % sequence k_iAno1, kiNSCC, p_iICC
x0(:, 3) = (x0(:, 3)-0.5)*10;

% initialise output matrices
sol = nan(size(x0));
fval = nan(size(x0, 1), 1);
exitflag = nan(size(x0, 1), 1);
output = cell(size(x0, 1), 1);

parpool(48) % solve for each initial guess in parallel
parfor i = 1:size(x0, 1)
    options = optimoptions(@fmincon);%, 'PlotFcns',@optimplotfval);
    disp(x0(i, :))
    [sol(i, :),fval(i),exitflag(i),output{i}] = fmincon(@objFun_ICC,x0(i, :), A, b, [], [], lb, ub, [], options); 
end

save(sprintf('../data/optim_ICC_%s', datestr(datetime, 'yymmddHHMMSS')));

