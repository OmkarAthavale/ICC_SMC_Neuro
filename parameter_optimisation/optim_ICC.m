x0 = [0.5 0.5];
n = 48;
lb = [0; 0; -5];
ub = [1; 1; 5];

A = [10/9, 1, 0];
b = [253/180];

a = sobolset(3);
p = scramble(a,'MatousekAffineOwen');
candidate = net(p,1000);
candidate((candidate(:, 1)*10/9+candidate(:, 2)) > 253/180, :) = [];

x0 = candidate(1:n, :);
x0(:, 3) = (x0(:, 3)-0.5)*10;

sol = nan(size(x0));
fval = nan(size(x0, 1), 1);
exitflag = nan(size(x0, 1), 1);
output = cell(size(x0, 1), 1);
parpool(48)

parfor i = 1:size(x0, 1)
    options = optimoptions(@fmincon);%, 'PlotFcns',@optimplotfval);
    disp(x0(i, :))
    [sol(i, :),fval(i),exitflag(i),output{i}] = fmincon(@objFun_ICC,x0(i, :), A, b, [], [], lb, ub, [], options); 
end

save(sprintf('optim_ICC_%s', datestr(datetime, 'yymmddHHMMSS')));

%%
names = {'Ano1', 'NSCC', 'a'};

pts = ones(n,3);
pts = pts.*[1:3];

h = figure('Units', 'centimeters');
set(h, 'position', [18,18,7,6] );

boxplot(reshape(sol, 1, []), reshape(pts, 1, []), 'Symbol','', 'color', 'k')
set(gca, 'XTickLabel', names)
hold on;
% [~, bestInd] = min(fval);
% plot(1:3, sol(bestInd, :), 'r.', 'markerSize', 20)
ylabel('Parameter value')
ylim([0 1])
scatter(reshape(pts, 1, [])+0.2.*(rand(1, numel(pts))-0.5), reshape(sol, 1, []), 10, 'r', 'filled', 'MarkerFaceAlpha', 1)
%%
names = {'Ano1', 'NSCC', 'a'};

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
ylim([0 1])

set(h, 'PaperPositionMode', 'auto')
saveas(h, sprintf('ICC_fitting_%d_%d', gca().YLim), 'svg')
%%
figure;
scatter3(sol(:,1), sol(:,2), sol(:,3))
xlabel(names{1});
ylabel(names{2});
zlabel(names{3});
xlim([0 1])
ylim([0 1])
zlim([-5 5])

figure;
boxplot(fval*100);
ylim([0 100])
ylabel('Percentage change in plateau amplitude (mV)')
ylabel('RMS error of solution')

figure;
violin(sol, 'xlabel', names)