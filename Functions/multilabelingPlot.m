function [] = multilabelingPlot(param)

select.randWalk = true;
select.minError = true;
select.uniform = true;

% Count number of data-sets
directory = dir(['Datasets/',param.dataset,'/processedGraph']);
directory = directory(~strncmpi('.', {directory.name}, 1));

num_datasets = length(directory(not([directory.isdir])));

for index_set = 1:num_datasets
    
    fprintf('Applying method to data-set %d of %d...\n',...
        index_set, num_datasets);
    
    if(select.randWalk)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Random walk/set',...
            num2str(index_set), '.mat'],'wErrorS','proplabels','perror');
        error.randWalk = wErrorS;
        propLabel.randWalk = proplabels;
        perrors.randWalk = perror;
    end
    
    if(select.minError)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/MinError/set',...
            num2str(index_set), '.mat'],'wErrorS','perror');
        error.minError = wErrorS;
        perrors.minError = perror;
    end
    
    if(select.uniform)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Uniform/set',...
            num2str(index_set), '.mat'],'wErrorS','perror');
        error.uniform = wErrorS;
        perrors.uniform = perror;
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
    
    if(~strcmp(param.bandwidth,'None'))
        filterlen = 10;
        cutoff = cutoffs(param.bandwidth);
        alpha = 8;
        freq_range = [0 2];
        g = @(x)(1./(1+exp(alpha*(x-cutoff))));
        c = sgwt_cheby_coeff(g,filterlen,filterlen+1,freq_range);
        mem_fn = sgwt_cheby_op(mem_fn,Ln,c,freq_range);
        [~,ind] = max(mem_fn,[],2);
        mem_fn(:,:) = 0;
        for ii = 1:size(mem_fn,1)
            mem_fn(ii,ind(ii)) = 1;
        end
    end
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
            
            cutoff = cutoffs(num_nodes);
            
            if(~strcmp(param.bandwidth,'None'))
                if(num_nodes > param.bandwidth)
                    cutoff = cutoffs(param.bandwidth);
                end
            end
            
            results.randWalk(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoff,...
                mem_fn, error.randWalk{num_nodes});
            
            results.minError(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoff,...
                mem_fn, error.minError{num_nodes});
            
            results.uniform(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoff,...
                mem_fn, error.uniform{num_nodes});
            
            results.zeroError(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoff,...
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
str = [num2str(param.num_labels),'lab',str,'sim',param.errorName,'bwf',num2str(param.bandwidth)];

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