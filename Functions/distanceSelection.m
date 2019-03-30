function [S_opts, nodes_added] = distanceSelection(A)

P = tril(A);
P = graphallshortestpaths(P,'directed',false);
N = size(A,1);
i = false(N,1);
nodes_added = zeros(N,1);
S_opts = cell(N,1);
for j = 1:N
    s = sum(P,1);
    [~,imin] = min(s);
    i(imin) = true;
    nodes_added(j) = imin;
    S_opts{j} = i;
    for k = 1:N
        P(k,:) = P(k,:) + (P(k,:) > P(k,imin)).*(P(k,imin) - P(k,:));
    end
end

end