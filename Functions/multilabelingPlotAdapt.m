function [] = multilabelingPlotAdapt(param)

select.randWalk = true;

% Count number of data-sets
directory = dir(['Datasets/',param.dataset,'/processedGraph']);
directory = directory(~strncmpi('.', {directory.name}, 1));

num_datasets = length(directory(not([directory.isdir])));

for index_set = 1:num_datasets
    
    fprintf('Applying method to data-set %d of %d...\n',...
        index_set, num_datasets);
    
    if(select.randWalk)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Random walk adapt/set',...
            num2str(index_set), '.mat'],'wErrorS','proplabels','perror');
        error.randWalk = wErrorS;
        propLabel.randWalk = proplabels;
        perrors.randWalk = perror;
        coeff.randWalk = coeffs; 
    end
    
    % Load adjacency matrix (A), multiclass signal (mem_fn),
    %   feature matrix (X) and the weight regularizator (sigma),
    %   Laplacian matrix (Ln), cut-off frequencies (cutoffs),
    %   (maximize frequency)
    %       optimal sets of points (S_opts), selection order (nodes_added),
    %   (minimize distance)
    %       optimal sets of points (S_opts_dist), 
    %       selection order (nodes_added_dist),
    %   covariance matrix (K)
    load(['Datasets/',param.dataset,'/processedGraph/set', num2str(index_set), '.mat']);
    
    if(strcmp(param.selection,'Minimize distance'))
        S_opts = S_opts_dist;
        nodes_added = nodes_added_dist;
    end
    
    if(index_set == 1)
        results.randWalk = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.minError = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.uniform = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.zeroError = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
    end
    
    for ntest = 1:param.num_rand_tests
        
        for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
            
            fprintf('Dataset %d. Test %d. # nodes: %d \n',index_set,...
                ntest,num_nodes);
            
            chosen_nodes = nodes_added(1:num_nodes);
    
            results.randWalk(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.randWalk{num_nodes});
            
            results.minError(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.minError{num_nodes});
            
            results.uniform(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.uniform{num_nodes});
            
            results.zeroError(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, zeros(1,num_nodes));
            
        end
        
    end
    
end

res.randWalk = reshape(results.randWalk,...
    size(results.randWalk,1)*size(results.randWalk,2),...
    size(results.randWalk,3));

res.minError = reshape(results.minError,...
    size(results.minError,1)*size(results.minError,2),...
    size(results.minError,3));

res.uniform = reshape(results.uniform,...
    size(results.uniform,1)*size(results.uniform,2),...
    size(results.uniform,3));

res.zeroError = reshape(results.zeroError,...
    size(results.zeroError,1)*size(results.zeroError,2),...
    size(results.zeroError,3));

temp = param.stepS:param.stepS:param.maxS(Ln);

m{1} = mean(res.randWalk(:,temp),1);
m{2} = mean(res.minError(:,temp),1);
m{3} = mean(res.uniform(:,temp),1);
m{4} = mean(res.zeroError(:,temp),1);

v{1} = std(res.randWalk(:,temp),0,1);
v{2} = std(res.minError(:,temp),0,1);
v{3} = std(res.uniform(:,temp),0,1);
v{4} = std(res.zeroError(:,temp),0,1);

total_nodes = size(Ln,1);
X = (param.stepS:param.stepS:param.maxS(Ln))/total_nodes;

str = num2str(param.num_rand_tests*num_datasets);
str = [num2str(param.num_labels),'lab',str,'sim',param.errorName];

save(['Datasets/',param.dataset,'/results/',param.application,'/',str,'.mat'],...
        'res','X','perror','-v7.3');
    
names = cell(1,4);

names{1} = 'Node contribution method';
names{2} = 'Minimum labeling error';
names{3} = 'Uniform labeling';
names{4} = 'Zero error curve';

color = get(0,'DefaultAxesColorOrder');
leg = [];

for i = 1:4
    H = shadedErrorBar(X,m{i},v{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end
ylabel('Prediction error');
xlabel(['Proportion of labeling set size (total samples = ',...
    num2str(total_nodes),')']);
title(['Multiple labeling with ',num2str(param.num_labels),' labels']);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

hold off;
savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Pred.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Pred.jpg'])

m{1} = mean(perrors.randWalk(:,temp),1);
m{2} = mean(perrors.minError(:,temp),1);
m{3} = mean(perrors.uniform(:,temp),1);

v{1} = std(perrors.randWalk(:,temp),0,1);
v{2} = std(perrors.minError(:,temp),0,1);
v{3} = std(perrors.uniform(:,temp),0,1);

leg = [];

for i = 1:3
    H = shadedErrorBar(X,m{i},v{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end
ylabel('Labeling error');
xlabel(['Proportion of labeling set size (total samples = ',...
    num2str(total_nodes),')']);
title(['Multiple labeling with ',num2str(param.num_labels),' labels']);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

hold off;
savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Lab.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Lab.jpg'])
end