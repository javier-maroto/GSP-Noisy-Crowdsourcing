function [] = randomWalkMultiAdaptReal2(param)

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
        cS = sgwt_cheby_coeff(g,filterlen,filterlen+1,freq_range);
        mem_fn = sgwt_cheby_op(mem_fn,Ln,cS,freq_range);
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

    num_nodes = param.maxS(Ln);
    [~,f] = max(mem_fn,[],2);
    
    S_opt = S_opts{num_nodes};

    % Q columns are the random walk vectors
    Q = K(~S_opt,S_opt)*(K(S_opt,S_opt)^-1);
    Q2 = Q.^2;

    I = sort(nodes_added(1:num_nodes));
    
    cS = sum(diag(1./sum(Q2,2))*Q2,1)';
    c = zeros(N,1);
    c(I) = cS;
    d_w = zeros(N,param.nClass);
    p_w = zeros(N,param.nClass);
    p_w(I,:) = softmax(d_w(I,:)')';
    
    o = c*(1-1/param.nClass);
    l = zeros(N,1);
    chosen_nodes = [];

    for numLabel = 1:param.num_labels
        eLabel = wError{index_set}(numLabel);
        dLabel = log((param.nClass-1)*(1-eLabel)/eLabel);
        [~,index] = max(o);
        tv = f(index);
        if(rand(1) < eLabel)
            r = randi(param.nClass-1);
            if(r >= tv)
                r = r+1;
            end
            d_w(index,r) = d_w(index,r) + dLabel;
        else
            d_w(index,tv) = d_w(index,tv) + dLabel;
        end
        p_w(index,:) = softmax(d_w(index,:)')';
        o(index) = c(index)*sum(p_w(index,:).*(1-p_w(index,:)));
        if(l(index) == 0)
            chosen_nodes = [chosen_nodes,index];
        end
        l(index) = l(index)+1;
        if(mod(numLabel,param.Nlabels) == 0)
            
            S_optL = zeros(N,1);
            S_optL(chosen_nodes) = 1;
            S_optL = logical(S_optL);
            [~,cutoff] = eigs(Ln_k(~S_optL,~S_optL),1,'sm');
            
            d_i = makePrediction2(Ln, chosen_nodes, cutoff, p_w);
            p_i = softmax(param.softk*d_i')';
            p_w(~S_optL,:) = p_i(~S_optL,:);
            
            p_ie = max(p_i,[],2);
            
            lerrorW(index_set,numLabel) = 1 - ...
                sum(sum(p_w(S_optL,:).*mem_fn(S_optL,:))/length(chosen_nodes));
            lerrorI(index_set,numLabel) = 1 - ...
                sum(sum(p_i(S_optL,:).*mem_fn(S_optL,:))/length(chosen_nodes));
            lerrorIW(index_set,numLabel) = 1 - ...
                sum(sum(p_i(S_optL,:).*p_w(S_optL,:))/length(chosen_nodes));
            
            perrorW(index_set,numLabel) = 1 - sum(sum(p_w.*mem_fn)/N);
            perrorI(index_set,numLabel) = 1 - sum(sum(p_i.*mem_fn)/N);
            perrorIe(index_set,numLabel) = 1 - mean(p_ie);
            ssize(index_set,numLabel) = length(chosen_nodes);
        end
    end

end
    
if ~loadErrorFlag
    save('temp/previousError.mat','wError','-v7.3');
end

temp = param.Nlabels:param.Nlabels:param.num_labels;


m{1} = mean(perrorW(:,temp),1);
s{1} = std(perrorW(:,temp),1);
m{2} = mean(perrorI(:,temp),1);
s{2} = std(perrorI(:,temp),1);
m{3} = mean(perrorIe(:,temp),1);
s{3} = std(perrorIe(:,temp),1);

X = param.Nlabels:param.Nlabels:param.num_labels;

str = num2str(param.num_rand_tests*num_datasets);
str = [num2str(param.num_labels),'lab',str,'sim',param.errorName,...
    'bw',num2str(param.bandwidth),'softk',num2str(param.softk)];


names = cell(1,2);

names{1} = 'Using the original worker errors for S';
names{2} = 'Using the interpolated worker errors for S';
names{3} = 'Interpolated expected error';

color = get(0,'DefaultAxesColorOrder');
leg = [];
figure;
for i = 1:3
    H = shadedErrorBar(X,m{i},s{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end

ylabel('Prediction error');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels for S = 500. Softmax parameter = ', num2str(param.softk)]);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Pred.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Pred.jpg'])

m{1} = mean(lerrorW(:,temp),1);
s{1} = std(lerrorW(:,temp),1);
m{2} = mean(lerrorI(:,temp),1);
s{2} = std(lerrorI(:,temp),1);
m{3} = mean(lerrorIW(:,temp),1);
s{3} = std(lerrorIW(:,temp),1);

names = cell(1,3);

names{1} = 'Using the original worker errors for S';
names{2} = 'Using the interpolated worker errors for S';
names{3} = 'Cross error between original and interpolated';

leg = [];
figure;
for i = 1:3
    H = shadedErrorBar(X,m{i},s{i},{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end
ylabel('Labeling error');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels for S = 500. Softmax parameter = ', num2str(param.softk)]);
hleg1 = legend(leg,names);
set(hleg1,'Location','NorthEast');

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Lab.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Lab.jpg'])

m = mean(ssize(:,temp),1);
s = std(ssize(:,temp),1);

figure;
H = shadedErrorBar(X,m,s,{'.-','Color',color(1,:)},1);
ylabel('Labeled set size');
xlabel(['Labels used']);
title(['Multiple labeling with ',num2str(param.num_labels),...
    ' labels for S = 500. Softmax parameter = ', num2str(param.softk)]);

savefig(['D:\TFG\code\Datasets\',param.dataset,'\results\',param.application,'\',str,'Size.fig'])
saveas(gcf,['D:\TFG\figures\',str,'Size.jpg'])

end