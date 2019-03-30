function [] = randomWalk(param)

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
    
    % One worker per label, optimize the assignation so that the most
    % important nodes of a set S have minimum error. 
    % Do it for every set S.
        
    for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
        S_opt = S_opts{num_nodes};

        % Q columns are the random walk vectors
        Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
        Q2 = Q.^2;

        % The bigger C(i), the bigger impact has the node i
        C{num_nodes} = sum(diag(1./sum(Q2,2))*Q2,1);
        [~, I] = sort(C{num_nodes},'descend');
        Isaved{num_nodes} = I;

        % Errors assigned to each node of S (ordered by index)
        wErrorS{num_nodes} = sort(wError{index_set}(1:num_nodes));
        wErrorS{num_nodes} = wErrorS{num_nodes}(I);
    end

    wErrorS{size(Ln,1)}=[];
    Isaved{size(Ln,1)}=[];

    save(['Datasets/',param.dataset,'/results/' param.application...
        '/Random walk/set' num2str(index_set) '.mat'],...
        'wErrorS','C','Isaved','-v7.3');
    
end

if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

end