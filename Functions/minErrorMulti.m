function [] = minErrorMulti(param)

% Count number of data-sets
directory = dir(['Datasets/',param.dataset,'/processedGraph']);
directory = directory(~strncmpi('.', {directory.name}, 1));
num_datasets = length(directory(not([directory.isdir])));

% Load error for comparisons
loadErrorFlag = strcmp(param.error,'Previous distribution');
if loadErrorFlag
    load('temp/previousError');
end

for index_set = 1:num_datasets
    %% Load graphs
    
    fprintf('Applying method to data-set %d of %d...\n',...
        index_set, num_datasets);
    
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
    
    %% Create worker error probabilities
    
    maxLabels = 10000;
    
    if ~loadErrorFlag
        wError{index_set} = param.error(maxLabels);
    end

    for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
        S_opt = S_opts{num_nodes};

        e = 0.5*ones(1,num_nodes);
    
        d = zeros(1,num_nodes);
        l = zeros(1,num_nodes);

        for numLabel = 1:param.num_labels
            eLabel = wError{index_set}(numLabel);
            dLabel = log((1-eLabel)/eLabel);
            [~,index] = max(e);
            if(rand(1) < eLabel)
                d(index) = d(index) - dLabel;
            else
                d(index) = d(index) + dLabel;
            end
            e(index) = 1/(1+exp(abs(d(index))));
            l(index) = l(index)+1;
        end

        wErrorS{num_nodes} = 1/2*(1-sign(d));
        perror(index_set,num_nodes) = mean(e);
    end

    save(['Datasets/',param.dataset,'/results/' param.application...
        '/MinError/set' num2str(index_set) '.mat'],...
        'wErrorS','perror','-v7.3');
    
end

if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

end