function [] = randomWalkMultiAdapt(param)

% Limit elements of Q
kk = @(n) 10;
% kk = @(n) ceil(n/10);

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
    N = size(Ln,1);
    k = 8;
    Ln_k = 1;
    for j = 1:k
        Ln_k = Ln_k*Ln;
    end
    Ln_k = 0.5*(Ln_k+Ln_k.');
    
    if ~loadErrorFlag
        wError{index_set} = param.error(maxLabels);
    end

    for num_nodes = param.stepS:param.stepS:param.maxS(Ln)
        S_opt = S_opts{num_nodes};

        % Q columns are the random walk vectors
        Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
%         kk2 = kk(num_nodes);
%         [~,I] = sort(Q,2,'descend');
%         for i = 1:size(Q,1)
%             q = Q(i,:);
%             q(I(i,kk2+1:end))=0;
%             Q(i,:) = q;
%         end
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
            if(mod(numLabel,10) == 0)
                S_optL = S_opt;
                S_optL(S_optL==1) = (l~=0);
                chosen_nodes = 1:N;
                chosen_nodes = chosen_nodes(S_optL);
                [~,cutoff] = eigs(Ln_k(~S_optL,~S_optL),1,'sm');
                newWError = 1/2*(1-sign(d));
                new_error = ...
                makePrediction(Ln, chosen_nodes, cutoff,...
                mem_fn, newWError(l~=0));
                e(l==0) = new_error;
            end
        end

        lerror(index_set,num_nodes) = mean(e(l~=0));
        perror(index_set,num_nodes) = new_error;
        proplabels{num_nodes} = sum(l~=0)/num_nodes;
        coeffs{num_nodes} = c;
    end
    lerrorSet = lerror(index_set,:);
    perrorSet = perror(index_set,:);
    
    save(['Datasets/',param.dataset,'/results/' param.application...
        '/Random walk adapt/set' num2str(index_set) '.mat'],...
        'lerrorSet','proplabels','perrorSet','coeffs','-v7.3');
    
end

if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

temp = param.stepS:param.stepS:param.maxS(Ln);


m = mean(perror(:,temp),1);
s = std(perror(:,temp),1);

X = (param.stepS:param.stepS:param.maxS(Ln))/N;

str = num2str(param.num_rand_tests*num_datasets);
str = [num2str(param.num_labels),'lab',str,'sim',param.errorName,'AdapK10'];

color = get(0,'DefaultAxesColorOrder');
H = shadedErrorBar(X,m,s,{'.-','Color',color(1,:)},1);

ylabel('Prediction error');
xlabel(['Proportion of labeling set size (total samples = ',...
    num2str(N),')']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels. Adaptatively computing the prediction error.']);

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Pred.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Pred.jpg'])

m = mean(lerror(:,temp),1);
s = std(lerror(:,temp),1);

figure;
H = shadedErrorBar(X,m,s,{'.-','Color',color(1,:)},1);
ylabel('Labeling error');
xlabel(['Proportion of labeling set size (total samples = ',...
    num2str(N),')']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels. Adaptatively computing the prediction error.']);

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Lab.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Lab.jpg'])

end