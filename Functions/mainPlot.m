function [] = mainPlot(param)

select.baseline = true;
select.covDisp = true;
select.covDispOpt = true;
select.randWalk = true;

% Count number of data-sets
directory = dir(['Datasets/',param.dataset,'/processedGraph']);
directory = directory(~strncmpi('.', {directory.name}, 1));

num_datasets = length(directory(not([directory.isdir])));

for index_set = 1:num_datasets
    
    fprintf('Applying method to data-set %d of %d...\n',...
        index_set, num_datasets);
    
    if(select.baseline)
        load('temp/previousError');
        error.baseline = wError{index_set};
    end
    if(select.covDisp)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Covariance dispersion/set',...
            num2str(index_set), '.mat'],'wErrorS');
        error.covDisp = wErrorS;
        
    end
    if(select.covDispOpt)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Covariance dispersion/set',...
            num2str(index_set), '.mat'],'optError');
        error.covDispOpt = optError;
    end
    if(select.randWalk)
        load(['Datasets/',param.dataset,'/results/',param.application,...
            '/Random walk/set',...
            num2str(index_set), '.mat'],'wErrorS','Isaved');
        error.randWalk = wErrorS;
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
    
    error.randWalk{size(Ln,1)}=[];
    error.covDispOpt{size(Ln,1)}=[];
    error.covDisp{size(Ln,1)}=[];
    if(index_set == 1)
        results.baseline = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.covDisp = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.covDispOpt = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
        results.randWalk = zeros(num_datasets,param.num_rand_tests,size(Ln,1)-1);
    end
    
    for ntest = 1:param.num_rand_tests
        
        for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
            
            if(strcmp(param.error(1:7),'Optimal'))
                error.baseline = optError{num_nodes}(...
                    randperm(length(optError{num_nodes})));
                s_optError = sort(optError{num_nodes});
                error.randWalk{num_nodes} = s_optError(Isaved{num_nodes});
            end
            fprintf('Dataset %d. Test %d. # nodes: %d \n',index_set,...
                ntest,num_nodes);
            
            chosen_nodes = nodes_added(1:num_nodes);
    
            results.baseline(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.baseline(1:num_nodes));
            
            results.randWalk(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.randWalk{num_nodes});
            
            if(isempty(error.covDisp{num_nodes}))
                results.covDisp(index_set,ntest,num_nodes) = NaN;
            else
                results.covDisp(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.covDisp{num_nodes});
            end
            
            if(isempty(error.covDispOpt{num_nodes}))
                results.covDispOpt(index_set,ntest,num_nodes) = NaN;
            else
                results.covDispOpt(index_set,ntest,num_nodes) = ...
                makePrediction(Ln, chosen_nodes, cutoffs(num_nodes),...
                mem_fn, error.covDispOpt{num_nodes});
            end
            
        end
        
    end
    
end

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

temp = param.stepS:param.stepS:param.maxS(Ln);

m{1} = mean(res.baseline(:,temp),1);
m{2} = mean(res.covDisp(:,temp),1);
m{3} = mean(res.covDispOpt(:,temp),1);
m{4} = mean(res.randWalk(:,temp),1);

v{1} = std(res.baseline(:,temp),0,1);
v{2} = std(res.covDisp(:,temp),0,1);
v{3} = std(res.covDispOpt(:,temp),0,1);
v{4} = std(res.randWalk(:,temp),0,1);

total_nodes = size(Ln,1);
X = (param.stepS:param.stepS:param.maxS(Ln))/total_nodes;

str = num2str(param.num_rand_tests*num_datasets);
str = [str,param.errorName];

save(['Datasets/',param.dataset,'/results/',str,'.mat'],...
        'res','m','v','X','-v7.3');
    
names = cell(1,4);
if(strcmp(param.errorName(1:7),'Optimal'))
    names{1} = 'Random assignation. Optimal error distribution';
    names{2} = 'Constant error curve';
    names{3} = 'Covariance dispersion method. Optimal error distribution';
    names{4} = 'Node contribution method. Optimal error distribution';
else
    names{1} = 'Random assignation.';
    names{2} = 'Covariance dispersion method.';
    names{3} = 'Covariance dispersion method. Optimal error distribution';
    names{4} = 'Node contribution method';
end

color = get(0,'DefaultAxesColorOrder');
leg = [];

for i = 1:4
    H = shadedErrorBar(X,m{i},v{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end
ylabel('Prediction error');
xlabel(['Proportion of labeled samples (total samples = ',...
    num2str(total_nodes),')']);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

hold off;
savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',str,'.fig'])
saveas(gcf,['D:\TFG\figures\',str,'.jpg'])

end