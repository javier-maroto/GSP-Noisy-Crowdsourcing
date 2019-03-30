function [] = randomWalkMulti(param)

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
    
    %% Create worker error probabilities
    
    maxLabels = 10000;
    
    if ~loadErrorFlag
        wError{index_set} = param.error(maxLabels);
    end

    for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
        S_opt = S_opts{num_nodes};

        % Q columns are the random walk vectors
        Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
        Q2 = Q.^2;

        c = sum(diag(1./sum(Q2,2))*Q2,1);
        e = 0.5*ones(1,num_nodes);
        o = c/4;

        d = zeros(1,num_nodes);
        l = zeros(1,num_nodes);

        for numLabel = 1:param.num_labels
            eLabel = wError{index_set}(numLabel);
            dLabel = log((1-eLabel)/eLabel);
            [~,index] = max(o);
            if(rand(1) < eLabel)
                d(index) = d(index) - dLabel;
            else
                d(index) = d(index) + dLabel;
            end
            e(index) = 1/(1+exp(abs(d(index))));
            o(index) = c(index)*e(index)*(1-e(index));
            l(index) = l(index)+1;
        end

        wErrorS{num_nodes} = 1/2*(1-sign(d));
        perror(index_set,num_nodes) = mean(e);
        proplabels{num_nodes} = sum(l~=0)/num_nodes;
    end

    save(['Datasets/',param.dataset,'/results/' param.application...
        '/Random walk/set' num2str(index_set) '.mat'],...
        'wErrorS','proplabels','perror','-v7.3');
    
end

if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

end