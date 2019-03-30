clear all;
close all;


% Add needed folders to path
addpath(genpath('GUI'));
addpath(genpath('Functions'));
addpath(genpath('sgwt_toolbox'));


%% Select general parameters

[param, ok] = guiGeneral();
if(~ok)
    return
end

% New parameters to add in the GUI
param.bandwidth = 10;

%% Select application parameters
switch param.application
    case 'Multiple labeling'
        param.num_labels = guiApplicationMultLabeling();
end

%% Select error parameters
switch param.errorName
    case 'Constant'
        a = guiErrorConstant();
        param.error = @(n) a*ones(1,n);
        param.errorName = [param.errorName,num2str(a)];
        param.errorMeanImp = (1-2*a)*log((1-a)/a);
    case 'Beta'
        [a,b] = guiErrorBeta();
        param.error = @(n) betarnd(a,b,[1 n]);
        param.errorName = [param.errorName,num2str(a),'a',num2str(b),'b'];
        syms p;
        param.errorMeanImp = int((1-2*p)*log((1-p)/p)*p^(a-1)*(1-p)^(b-1),p,[0 1])/beta(a,b);
    case 'Hammer-Spammer'
        a = guiErrorHammer();
        param.error = @(n) 0.5*(rand(1,n) < a);
        param.errorName = ['Spammer',num2str(a)];
    case 'Optimal'
        a = guiErrorOptimal();
        param.error = @(n) a*ones(1,n);
        param.errorName = [param.errorName,num2str(a)];
end
pause(0.5);


%% Execution parameters

param.num_rand_tests = 10;
param.stepS = 10;
param.maxS = @(A) round(size(A,1)/2);


%% Run application

switch param.application
    case 'Process dataset'
        addpath(genpath(['Datasets/',param.dataset]));
        createGraphs(param.dataset);
        processGraphs(param.dataset);
    case 'Compare assignation methods'
        covDispersion(param);
        param.error = 'Previous distribution';
        randomWalk(param);
        mainPlot(param);
    case 'Multiple labeling'
%         randomWalkMultiAdapt(param);
        randomWalkMulti(param);
        param.error = 'Previous distribution';
        minErrorMulti(param);
        uniformMulti(param);
        multilabelingPlot(param);
end