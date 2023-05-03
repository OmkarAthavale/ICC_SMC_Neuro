x0 = [0.7 0.8 2];
% A = [1 0 0 0;0 1 0 0; 0 0 1 0; 0 0 0 1];
lb = [0; 0; -5];
ub = [3; 1; 5];
n = 48;
a = sobolset(3);
p = scramble(a,'MatousekAffineOwen');
x0 = net(p,n);
x0(:, 3) = (x0(:, 3)-0.5)*10;

sol = nan(size(x0));
fval = nan(size(x0, 1), 1);
exitflag = nan(size(x0, 1), 1);
output = cell(size(x0, 1), 1);

parpool(48)
parfor i = 1:size(x0, 1)
    options = optimoptions(@fmincon);%('PlotFcns',@optimplotfval);
    disp(x0(i, :))
    [sol(i, :),fval(i),exitflag(i),output{i}] = fmincon(@objFun_SMC, x0(i, :), [], [], [], [], lb, ub, [], options);
end

save(sprintf('optim_SMC_%s', datestr(datetime, 'yymmddHHMMSS')));

%%
names = {'Ca50', 'SK', 'b'};

pts = ones(n,3);
pts = pts.*[1:3];

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,6] );

boxplot(reshape(sol, 1, []), reshape(pts, 1, []), 'Symbol','', 'color', 'k')
set(gca, 'XTickLabel', names)
hold on;
[~, bestInd] = min(fval);
% plot(1:3, sol(bestInd, :), 'r.', 'markerSize', 20)
ylabel('Parameter value')
ylim([0 4])
scatter(reshape(pts, 1, []), reshape(sol, 1, []), 'r.')

%%
names = {'Ca50', 'SK', 'b'};

pts = ones(n,3);
pts = pts.*[1:3];

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,6] );

vert = [];
for var = 1:3
    [count, edge] = histcounts(sol(:, var), -5:0.05:5);
    for i = 1:length(count)
        vert(4*(i-1)+1:4*i, :) = [var, edge(i); var, edge(i+1); var+0.25*count(i)./max(count), edge(i+1); var+0.25*count(i)./max(count), edge(i)];
        
        faces(i, :) = 4*(i-1)+1:4*i;
        
    end
    vert(:, 1) = vert(:, 1) + 0.25;
    patch('Faces', faces, 'Vertices', vert, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', [0.4 0.4 0.4])
end

hold on

boxplot(reshape(sol, 1, []), reshape(pts, 1, []), 'plotstyle', 'traditional', 'boxstyle', 'outline', 'Symbol','', 'color', 'k')
set(gca, 'XTickLabel', names)
hold on;
% [~, bestInd] = min(fval);
% plot(1:3, sol(bestInd, :), 'r.', 'markerSize', 20)
ylabel('Parameter value')
ylim([-5 5])

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('SMC_fitting_%d_%d', gca().YLim), 'svg')
%%

figure;
scatter3(sol(:,1), sol(:,2), sol(:,3))
xlabel(names{1});
ylabel(names{2});
zlabel(names{3});
xlim([0 2])
ylim([0 1])
zlim([-5 5])

figure;
boxplot(fval);
ylim([0 100])
ylabel('Percentage change in plateau amplitude (mN)')