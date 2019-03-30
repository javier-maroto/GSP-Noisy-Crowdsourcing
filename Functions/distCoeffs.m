close all;
str = '';
% str = 'K10';
% save(['D:\TFG\code\Datasets\USPS\results\Multiple labeling\coeffs',str,'.mat','coeffs'])
load(['D:\TFG\code\Datasets\USPS\results\Multiple labeling\coeffs',str,'.mat'])
load('Datasets/USPS/processedGraph/set1.mat','S_opts');
me = []; ma = []; st = [];
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 10:10:500
    s = sort(coeffs{i});
    subplot(1,2,2);
    plot(1/i:1/i:1,s/max(s));
    
    y = double(S_opts{i})';
    y(y==1) = coeffs{i};
    y = y/max(y);
    subplot(1,2,1);
    plot(1:1000,y);
    ylim([0,1]);
    me = [me,mean(s)];
    ma = [ma,max(s)];
    st = [st,std(s)];
    pause(0.5);
end
figure; plot(me);
figure; plot(ma);
figure; plot(st);