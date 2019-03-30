function [] = randomWalkMultiAdaptReal(param)

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
%     
%     if(~strcmp(param.bandwidth,'None'))
%         filterlen = 10;
%         cutoff = cutoffs(param.bandwidth);
%         alpha = 8;
%         freq_range = [0 2];
%         g = @(x)(1./(1+exp(alpha*(x-cutoff))));
%         c = sgwt_cheby_coeff(g,filterlen,filterlen+1,freq_range);
%         mem_fn = sgwt_cheby_op(mem_fn,Ln,c,freq_range);
%         [~,ind] = max(mem_fn,[],2);
%         mem_fn(:,:) = 0;
%         for ii = 1:size(mem_fn,1)
%             mem_fn(ii,ind(ii)) = 1;
%         end
%     end
    
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

    num_nodes = param.maxS(Ln);
    Ncheck = 50;
    Nlabels = 5;
    
    S_opt = S_opts{num_nodes};

    % Q columns are the random walk vectors
    Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
    Q2 = Q.^2;

    I = sort(nodes_added(1:num_nodes));
    
    c = sum(diag(1./sum(Q2,2))*Q2,1);
    e = 0.5*ones(1,num_nodes);
    o = c/4;

    d = zeros(1,num_nodes);
    l = zeros(1,num_nodes);
    chosen_nodes = [];

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
        if(l(index) == 0)
            chosen_nodes = [chosen_nodes,index];
        end
        l(index) = l(index)+1;
        if(mod(numLabel,Nlabels) == 0 && length(chosen_nodes) > Ncheck)
            check_nodes = sort(chosen_nodes(1:(end-Ncheck)));
            S_optL = zeros(N,1);
            S_optL(I(check_nodes)) = 1;
            [~,cutoff] = eigs(Ln_k(~S_optL,~S_optL),1,'sm');
            newWError = 1/2*(1-sign(d(check_nodes)));
            [oracle_pe, f_recon, f] =...
                makePrediction(Ln, I(check_nodes), cutoff,...
                mem_fn, newWError);
            pe = 0;
            for i1 = chosen_nodes((end-Ncheck+1):end)
                if(f_recon(I(i1)) == f(I(i1)))
                    pe = pe + e(i1);
                else
                    pe = pe + 1 - e(i1);
                end
            end
            pe = pe/Ncheck;
            e(l==0) = pe;
            
            lerror(index_set,numLabel) = mean(e(l~=0));
            perror(index_set,numLabel) = pe;
            ssize(index_set,numLabel) = length(chosen_nodes);
            oracle_perror(index_set,numLabel) = oracle_pe;
        end
    end

end

save(['Datasets/',param.dataset,'/results/' param.application...
        '/Random walk adapt real/' num2str(Ncheck) '.mat'],...
        'lerror','perror','ssize','oracle_perror','-v7.3');
    
if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

temp = Nlabels:Nlabels:param.num_labels;


m{1} = mean(perror(:,temp),1);
s{1} = std(perror(:,temp),1);
m{2} = mean(oracle_perror(:,temp),1);
s{2} = std(oracle_perror(:,temp),1);

X = Nlabels:Nlabels:param.num_labels;

str = num2str(param.num_rand_tests*num_datasets);
str = [num2str(param.num_labels),'lab',str,'sim',param.errorName,...
    'AdapRealN',num2str(Ncheck),'L',num2str(Nlabels),'bw',num2str(param.bandwidth)];

names = cell(1,2);

names{1} = 'Estimating the prediction error';
names{2} = 'Having the prediction error';

color = get(0,'DefaultAxesColorOrder');
leg = [];
figure;
for i = 1:2
    H = shadedErrorBar(X,m{i},s{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end

ylabel('Prediction error');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels. Adaptatively computing the prediction error (N =',...
    num2str(Ncheck),').']);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Pred.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Pred.jpg'])

m = mean(lerror(:,temp),1);
s = std(lerror(:,temp),1);

figure;
H = shadedErrorBar(X,m,s,{'.-','Color',color(1,:)},1);
ylabel('Labeling error');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels. Adaptatively computing the prediction error (N =',...
    num2str(Ncheck),').']);

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Lab.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Lab.jpg'])

m = mean(ssize(:,temp),1);
s = std(ssize(:,temp),1);

figure;
H = shadedErrorBar(X,m,s,{'.-','Color',color(1,:)},1);
ylabel('Labeled set size');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels. Adaptatively computing the prediction error (N =',...
    num2str(Ncheck),').']);

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Lab.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Lab.jpg'])

end