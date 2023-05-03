%%% optim_SMC.m
%%% Omkar N. Athavale, May 2023
%%% Solves a non-linear optimisation problem to identify best fitting
%%% parameters for k_iCa50, k_iNSCC, and p_iSMC. 

addpath(genpath('../'));

% constraint definition, see "help fmincon"
lb = [0; 0; -5];
ub = [3; 1; 5];

% initial guess sampling
n = 48; % number of inital guesses to sample
a = sobolset(3);
p = scramble(a,'MatousekAffineOwen');
x0 = net(p,n); % sequence k_iCa50, kiSK, p_iSMC
x0(:, 3) = (x0(:, 3)-0.5)*10;

% initialise output matrices
sol = nan(size(x0));
fval = nan(size(x0, 1), 1);
exitflag = nan(size(x0, 1), 1);
output = cell(size(x0, 1), 1);

parpool(48)% solve for each initial guess in parallel
parfor i = 1:size(x0, 1)
    options = optimoptions(@fmincon);%('PlotFcns',@optimplotfval);
    disp(x0(i, :))
    % fixed values of k_iAno1, k_iNSCC, and p_iICC are in objFun_SMC
    [sol(i, :),fval(i),exitflag(i),output{i}] = fmincon(@objFun_SMC, x0(i, :), [], [], [], [], lb, ub, [], options);
end

save(sprintf('optim_SMC_%s', datestr(datetime, 'yymmddHHMMSS')));