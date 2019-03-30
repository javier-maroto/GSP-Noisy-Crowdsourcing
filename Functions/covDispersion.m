function [] = covDispersion(param)

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
    
    switch param.application
        % One worker per label, optimize the assignation so that the most
        % important nodes of a set S have minimum error. 
        % Do it for every set S.
        case 'Compare assignation methods'
       
            for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
                fprintf('Dataset %d. # nodes: %d \n',index_set,num_nodes);
                S_opt = S_opts{num_nodes};
                
                % Obtain the conditional covariance matrix
                Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
                Kcond = K(~S_opt,~S_opt) - Q*K(S_opt,~S_opt);
                Kcond = full(Kcond);
                
                % Obtain the base change matrix with the variance values
                [U,D] = eig(Kcond);
                
                % Solve the overdetermined and constrained system Ax = b
                A = (D^-1/2)*U*Q;
                b = zeros(size(A,1),1);
                z = zeros(size(A,2),1);
                Aeq = zeros(size(A,2),size(A,2)); 
                Aeq(1,:) = 1;
                beq = zeros(size(A,2),1);
                beq(1) = sum(wError{index_set}(1:num_nodes));
                optError{num_nodes} = lsqlin(A,b,[],[],Aeq,beq,z,z+1,[],...
                    optimoptions(@lsqlin,'Display','off',...
                    'Algorithm','active-set'));
                
                % The smaller C(i), the bigger impact has the node i
                [~, I] = sort(optError{num_nodes},'ascend');
                
                % Errors assigned to each node of S (ordered by index)
                wErrorS{num_nodes} = sort(wError{index_set}(1:num_nodes));
                wErrorS{num_nodes} = wErrorS{num_nodes}(I);

            end
            
            wErrorS{size(Ln,1)}=[];
            optError{size(Ln,1)}=[];
            
            save(['Datasets/',param.dataset,'/results/' param.application...
                '/Covariance dispersion/set' num2str(index_set) '.mat'],...
                'wErrorS','optError','-v7.3');
    end
    
end

if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

end