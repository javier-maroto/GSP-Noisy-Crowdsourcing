function p_i = makePrediction2(Ln,chosen_nodes,cutoff,p_w)

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
p_i = sgwt_cheby_op(p_w,Ln,c,freq_range);

for iter = 1:num_iter % takes fewer iterations
    % projection on C1
    err_s = (p_w-p_i); 
    err_s(~S_opt,:) = 0; % error on the known set

    % projection on C2
    p_temp = sgwt_cheby_op(p_i + err_s,Ln,c,freq_range); % err on S approx LP

    norm_val(iter) = norm(p_temp-p_i); % to check convergence
    if (iter > 1 && norm_val(iter) > norm_val(iter-1) ), break; end % avoid divergence
    p_i = p_temp;
end

p_w = p_i;
p_w(S_opt,:) = 0;

% initialization
p_i = sgwt_cheby_op(p_w,Ln,c,freq_range);

for iter = 1:num_iter % takes fewer iterations
    % projection on C1
    err_sc = (p_w-p_i); 
    err_sc(S_opt,:) = 0; % error on the unknown set

    % projection on C2
    p_temp = sgwt_cheby_op(p_i + err_sc,Ln,c,freq_range); % err on S approx LP

    norm_val(iter) = norm(p_temp-p_i); % to check convergence
    if (iter > 1 && norm_val(iter) > norm_val(iter-1) ), break; end % avoid divergence
    p_i = p_temp;
end

end