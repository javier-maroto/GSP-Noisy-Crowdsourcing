function [] = createGraph_Isolet()

load('isolet1+2+3+4.data');
load('isolet5.data');

data = [isolet1_2_3_4 ; isolet5];
data = shiftdim(data,1);
[k,~] = size(data);
k = k - 1;
m = 26;

for iter = 1:10
    
    fprintf('Generating data-set %d of 10...\n', iter);

    % number of samples to consider from each class
    num_samples = 100;
    N = m*num_samples;

    % graph signal
    f = zeros(N,1);
    X = zeros(N,k);
    for i = 1:m
        f((i-1)*num_samples + 1 : (i-1)*num_samples + num_samples) = i;
        data_i = data(:,data(end,:) == i);
        data_i(end,:) = [];
        [~,l] = size(data_i);
        X((i-1)*num_samples + 1 : (i-1)*num_samples + num_samples, :) = data_i(:, randsample(1:l, num_samples))';
    end

    % membership functions
    mem_fn = false(N,m);
    for i = 1:m
        mem_fn(f==i,i) = true;
    end

    % compute pairwise distances
    distance = zeros(N);
    % Assign lower triangular part only in loop, saves time
    for i = 1:N
        for j = 1:i-1
            distance(i,j) = sqrt((X(i,:) - X(j,:))*(X(i,:) - X(j,:))');
        end
    end
    % Complete upper triangular part
    distance = distance + distance';

    % Number of nearest neighbors
    knn_param = 10;

    % Calculating distances of k-nearest neighbors
    knn_distance = zeros(N,1);
    for i = 1:N
        % sort all possible neighbors according to distance
        temp = sort(distance(i,:), 'ascend');
        % select k-th neighbor: knn_param+1, as the node itself is considered
        knn_distance(i) = temp(knn_param + 1);
    end

    % sparsification matrix
    nodes_to_retain = true(N);
    for i = 1:N
        nodes_to_retain(i, distance(i,:) > knn_distance(i) ) = false;
        nodes_to_retain(i,i) = false; % diagonal should be zero
    end
    nodes_to_retain( nodes_to_retain ~= nodes_to_retain' ) = true;

    % computing sigma
    sigma = 1/3 * mean(knn_distance);

    % Creating adjacency matrix: only compute values for nodes to retain
    A = zeros(N);
    A(nodes_to_retain) = exp( -distance(nodes_to_retain).^2 / (2*sigma^2) );
    A = sparse(A);

    % save adjacency matrix
    save(['Datasets/Isolet/rawGraph/set' num2str(iter) '.mat'],'A','mem_fn', 'X', 'sigma');

end

end
