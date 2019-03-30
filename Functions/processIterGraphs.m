% processIterGraphs('USPS',0.05,0.5,10,10)
function [S_opts, cutoffs, S_opts_fixed, cutoffs_fixed] =...
    processIterGraphs(dataset,propS,propF,max_iter,kRand)

% Count number of data-sets
directory = dir([dataset, ' data/rawGraph']);
num_datasets = length(directory(not([directory.isdir])));

% Power of Laplacian
k = 8; % higher k leads to better estimate of the cut-off frequency

for index_set = 1%:num_datasets
    %% Load graphs
    
    fprintf('Processing data-set %d of %d...\n', index_set, num_datasets);
    fprintf('   Iteration %d\n', 1);
    % Load adjacency matrix (A), multiclass signal (mem_fn),
    %   feature matrix (X) and the weight regularizator (sigma)
    load([dataset, ' data/rawGraph/set' num2str(index_set) '.mat']);
    
    N = size(A,1);
    
    % Sample size
    S = round(propS*N);
	fixed_samples = round(propF*S);
    
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
    
    rho = 1E-6;
    K = (Ln + rho*speye(N))^(-1);
    
    %% Optimal set S
    
    % index & cut-off frequencies vectors
    p = (1:N)';
    
    S_opt = false(N,1);
    q = p(~S_opt);
    [y,~] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
    
    for iter = 1:S

        % find direction of maximum increment in reduced (|Sc|) dimensions
        [~,max_index] = max(abs(y));

        % Find corresponding node in N dimensions
        node_to_add = q(max_index);

        % Update indicator function
        S_opt(node_to_add) = 1;
        
        % create index vector for Sc from indicator functions
        q = p(~S_opt);
        
        if(iter ~= S) 
            if(iter == fixed_samples)
                S_opts_fixed = cell(1,max_iter);
                S_opts_fixed{1} = S_opt;
                cutoffs_fixed = zeros(1,max_iter);
                cutoffs_fixed(1) = omega;
            end
            
            % compute minimum eigen-pair: efficient way
            [y,omega] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
            omega = abs(omega)^(1/k);
        end
    end
    
    S_opts = cell(1,max_iter);
    cutoffs = zeros(1,max_iter);
    
    S_opts{1} = S_opt;
    cutoffs(1) = omega;
	
	for i = 2:max_iter
        fprintf('   Iteration %d\n', i);
        
		% Q columns are the random walk vectors
        Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
        Q = full(Q);
        
        % Transform the weights in decision power (Banzhaf power index)
        for i2 = 1:size(Q,1)
            [values,indexes] = sort(Q(i2,:),'descend');
            values = values(1:kRand);
            indexes = indexes(1:kRand);
            setMatrix = dec2bin(0:2^kRand-1,kRand);
            setMatrix = logical(setMatrix(:,:)'-'0');
            sums = values*setMatrix;
            sums = sums - sum(values)/2;
            setMatrix = [setMatrix ; sums];
            setMatrix = setMatrix(:,(sums > 0));
            power = zeros(1,kRand);
            for i3 = 1:kRand
                power(i3) = sum(setMatrix(i3,(setMatrix(end,:) < values(i3)))); 
            end
            power = power/sum(power);    
            row = zeros(1,size(Q,2));
            row(indexes) = power;
            Q(i2,:) = row;
        end
        
        % The bigger C(i), the bigger impact has the node i
        C = sum(Q,1);
        [~, I] = sort(C,'descend');
        
        % Select the nodes 
        C(I((fixed_samples+1):end)) = 0;
        C = ceil(C);
        S_opt(S_opt == 1) = C;
        
        %% Add new nodes
        
        q = p(~S_opt);
        [y,omega] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
        cutoffs_fixed(i) = abs(omega)^(1/k);
        S_opts_fixed{i} = S_opt;
        for iter = (sum(S_opt)+1):S

            % find direction of maximum increment in reduced (|Sc|) dimensions
            [~,max_index] = max(abs(y));

            % Find corresponding node in N dimensions
            node_to_add = q(max_index);

            % Update indicator function
            S_opt(node_to_add) = 1;

            % create index vector for Sc from indicator functions
            q = p(~S_opt);

            if(iter ~= S) 
                % compute minimum eigen-pair: efficient way
                [y,omega] = eigs(Ln_k(~S_opt,~S_opt),1,'sm');
                omega = abs(omega)^(1/k);
            end
        end
        
        S_opts{i} = S_opt;
        cutoffs(i) = omega;
        
	end
    
end

end
