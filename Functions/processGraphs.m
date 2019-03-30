function [] = processGraphs(dataset)
    
% Count number of data-sets
directory = dir(['Datasets/',dataset,'/rawGraph']);
num_datasets = length(directory(not([directory.isdir])));

% Power of Laplacian
k = 8; % higher k leads to better estimate of the cut-off frequency

for index_set = 1:num_datasets
    %% Load graphs
    
    fprintf('Processing data-set %d of %d...\n', index_set, num_datasets);
    
    % Load adjacency matrix (A), multiclass signal (mem_fn),
    %   feature matrix (X) and the weight regularizator (sigma)
    load(['Datasets/',dataset,'/rawGraph/set' num2str(index_set) '.mat']);
    
    N = size(A,1);
    
    %% Laplacian matrix operations
    
    % compute the symmetric normalized Laplacian matrix
    D = sum(A,2);
    D(D~=0) = D.^(-1/2);
    Dinv = spdiags(D,0,N,N);
    Ln = speye(N) - Dinv*A*Dinv;
    clear Dinv;
    
    % make sure the Laplacian is symmetric
    Ln = 0.5*(Ln+Ln.');

    % higher power of Laplacian
    Ln_k = 1;
    for j = 1:k
        Ln_k = Ln_k*Ln;
    end
    Ln_k = 0.5*(Ln_k+Ln_k.');
    
    
    %% Optimal set S (frequency)
    
    % index & cut-off frequencies vectors
    p = (1:N)';
    cutoffs = zeros(N,1);
    nodes_added = zeros(N,1);
    
    S_opt = false(N,1);
    q = p(~S_opt);
    [y,~] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
    
    for iter = 1:N

        % find direction of maximum increment in reduced (|Sc|) dimensions
        [~,max_index] = max(abs(y));

        % Find corresponding node in N dimensions
        node_to_add = q(max_index);

        % Update indicator function
        S_opt(node_to_add) = 1;
        S_opts{iter} = S_opt;
        nodes_added(iter) = node_to_add;
        
        if(mod(iter,10) == 0)
            fprintf('   Nodes added = %d...\n', iter);
        end
        
        % create index vector for Sc from indicator functions
        q = p(~S_opt);
        
        if(iter ~= N) 
            % compute minimum eigen-pair: efficient way
            [y,omega] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
            omega = abs(omega)^(1/k);

            % store a list of omega
            cutoffs(iter) = omega;
        end
    end
    
    %% Optimal set S (distance)
    
    [S_opts_dist, nodes_added_dist] = distanceSelection(A);
    
    
    %% Matrices for error labeling
    
    rho = 1E-6;
    K = (Ln + rho*speye(N))^(-1);
    
    %% Save
    
    save(['Datasets/',dataset,'/processedGraph/set' num2str(index_set) '.mat'],...
        'A','mem_fn','X','sigma','Ln','cutoffs','S_opts','nodes_added',...
        'S_opts_dist','nodes_added_dist','K','-v7.3');
end

end