close all;
clear all;

% Add needed folders to path
addpath(genpath('GUI'));
addpath(genpath('Functions'));
addpath(genpath('sgwt_toolbox'));

param.application = 'Multiple labeling';
param.dataset = 'USPS';
param.nClass = 10;
param.selection = 'Maximize frequency';

param.errorName = 'Constant0.2';
param.error = @(n) 0.2*ones(1,n);
param.errorMeanImp = 0.831776616671934;

param.num_labels = 500;
param.bandwidth = 'None';
param.stepS = 10;
param.num_rand_tests = 10;
param.maxS = @(A)round(size(A,1)/2);

param.Ncheck = 50;
param.Nlabels = 5;
param.softk = 10000;

randomWalkMultiAdaptReal2(param);