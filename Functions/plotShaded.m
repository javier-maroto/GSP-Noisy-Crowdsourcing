str = '100Beta2a8b';
number_nodes = 2600;
dataset = 'Isolet';
open(['\',dataset,' data\results\M',str,'.fig']);
h = findobj(gca,'Type','line');
XM=get(h,'Xdata');
YM=get(h,'Ydata');
names = get(h,'DisplayName');
if(strcmp(names{1},'random walk')) 
    names{1} = 'Node contribution method';
end
if(strcmp(names{2},'optimal covariance distorision')) 
    names{2} = 'Covariance dispersion method. Optimal error distribution';
end
if(strcmp(names{3},'covariance distorsion')) 
    names{3} = 'Covariance dispersion method';
end
if(strcmp(names{4},'random')) 
    names{4} = 'Random assignation';
end
if(strcmp(names{3},'constant error'))
    names{3} = 'Covariance dispersion method';
%     names{3} = 'Constant error curve';
%     names{1} = 'Node contribution method. Optimal error distribution';
%     names{4} = 'Random assignation. Optimal error distribution';
end

open(['\',dataset,' data\results\V',str,'.fig']);
h = findobj(gca,'Type','line');
YV=get(h,'Ydata');
color = get(0,'DefaultAxesColorOrder');
close all;
leg = [];
for i = 1:4
    x = XM{i}/number_nodes;
    y = YM{i};
    dy = YV{i};
    H = shadedErrorBar(x,y,dy,{'.-','Color',color(i,:)},1);
    leg = [leg,H.mainLine];
    hold on;
end
ylabel('Prediction error');
xlabel(['Proportion of labeled samples (total samples = ',...
    num2str(number_nodes),')']);
hleg1 = legend(leg,names);
% set(hleg1,'Location','NorthEast');
hold off;
savefig(['D:\Otros\TFG\code\',dataset,' data\results\',str])
saveas(gcf,['C:\Users\Javier\Desktop\TFG\figures\',str,'.jpg'])