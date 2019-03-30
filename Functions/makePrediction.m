function [mean_error, f_recon, f] = makePrediction(Ln,chosen_nodes,cutoff,mem_fn,worker_error)

%% options

num_iter = 100;
N = size(Ln,1);

%% compute optimal sampling set

S_opt = false(N,1);
S_opt(chosen_nodes) = true;
queries = find(S_opt);

%% reconstruction using POCS

norm_val = zeros(num_iter,1); % used for checking convergence

% reconstruction using POCS

% approximate low pass filter using SGWT toolbox
filterlen = 10;
alpha = 8;
freq_range = [0 2];
g = @(x)(1./(1+exp(alpha*(x-cutoff))));
c = sgwt_cheby_coeff(g,filterlen,filterlen+1,freq_range);

% initialization
mem_fn_du = mem_fn;
mem_fn_du(~S_opt,:) = 0;
cont = 1;
for i = queries.'
    if(rand(1) < worker_error(cont))
        mem_fn_du(i,:) = circshift(mem_fn_du(i,:),randi(length(mem_fn_du(i,:))-1),2);
    end
    cont = cont + 1;
end
mem_fn_recon = sgwt_cheby_op(mem_fn_du,Ln,c,freq_range);

for iter = 1:num_iter % takes fewer iterations
    % projection on C1
    err_s = (mem_fn_du-mem_fn_recon); 
    err_s(~S_opt,:) = 0; % error on the known set
    
    % projection on C2
    mem_fn_temp = sgwt_cheby_op(mem_fn_recon + err_s,Ln,c,freq_range); % err on S approx LP
    
    norm_val(iter) = norm(mem_fn_temp-mem_fn_recon); % to check convergence
    if (iter > 1 && norm_val(iter) > norm_val(iter-1) ), break; end % avoid divergence
    mem_fn_recon = mem_fn_temp;
end
% predicted class labels
[~,f_recon] = max(mem_fn_recon,[],2);

% true class lables
[~,f] = max(mem_fn,[],2);

% reconstruction error
mean_error = sum(f(~S_opt)~=f_recon(~S_opt))/sum(~S_opt); % error for unknown labels only

% pred = softmax(mem_fn_recon');
% pred = pred';
% pred(chosen_nodes,:) = mem_fn_du(chosen_nodes,:);

end