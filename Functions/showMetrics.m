function [] = showMetrics(results,param)

res.baseline = reshape(results.baseline,...
    size(results.baseline,1)*size(results.baseline,2),...
    size(results.baseline,3));
res.covDisp = reshape(results.covDisp,...
    size(results.covDisp,1)*size(results.covDisp,2),...
    size(results.covDisp,3));
res.covDispOpt = reshape(results.covDispOpt,...
    size(results.covDispOpt,1)*size(results.covDispOpt,2),...
    size(results.covDispOpt,3));
res.randWalk = reshape(results.randWalk,...
    size(results.randWalk,1)*size(results.randWalk,2),...
    size(results.randWalk,3));

m.baseline = mean(res.baseline,1);
m.covDisp = mean(res.covDisp,1);
m.covDispOpt = mean(res.covDispOpt,1);
m.randWalk = mean(res.randWalk,1);

v.baseline = std(res.baseline,0,1);
v.covDisp = std(res.covDisp,0,1);
v.covDispOpt = std(res.covDispOpt,0,1);
v.randWalk = std(res.randWalk,0,1);

X = 1:size(res.baseline,2);

figure;
plot(X(m.baseline ~= 0),m.baseline(m.baseline ~= 0),...
    X(m.covDisp ~= 0),m.covDisp(m.covDisp ~= 0),...
    X(m.covDispOpt ~= 0),m.covDispOpt(m.covDispOpt ~= 0),...
    X(m.randWalk ~= 0),m.randWalk(m.randWalk ~= 0));
hleg1 = legend('random','constant error',...
    'optimal covariance distorsion','random walk');
title(['Mean value for ',param.database,' datasets. ',param.numsim,' simulations']);
ylabel('Prediction error');
xlabel(['Number of samples (',param.nodes,' = 1%)']);
set(hleg1,'Location','NorthEast');


figure;
plot(X(v.baseline ~= 0),v.baseline(v.baseline ~= 0),...
    X(v.covDisp ~= 0),v.covDisp(v.covDisp ~= 0),...
    X(v.covDispOpt ~= 0),v.covDispOpt(v.covDispOpt ~= 0),...
    X(v.randWalk ~= 0),v.randWalk(v.randWalk ~= 0));
hleg1 = legend('random','constant error',...
    'optimal covariance distorsion','random walk');
title(['Variance value for ',param.database,' datasets. ',param.numsim,' simulations']);
ylabel('Prediction error');
xlabel(['Number of samples (',param.nodes,' = 1%)']);
set(hleg1,'Location','SouthEast');

end