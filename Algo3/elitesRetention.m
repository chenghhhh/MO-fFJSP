function [pop_new,fit_new,rank_value_new,crowd_dist_new] = elitesRetention(pop_merged,fit_merged,pop_size,rank_value,crowd_dist)
pop_new = zeros(pop_size,size(pop_merged,2));
fit_new = zeros(pop_size,size(fit_merged,2));
rank_value_new = zeros(pop_size,1);
crowd_dist_new = zeros(pop_size,1);
% �ҳ�ʹ�ø��������պó�������ڸ�����ģ�ķ�֧��ȼ�ֵ
rank = 1;
while length(find(rank_value <= rank)) < pop_size
    rank = rank + 1;
end
% ����ѡ���֧��ȼ��ߵģ���������ʱ������ѡ��ӵ��������
if length(find(rank_value <= rank)) == pop_size
    elites_index = rank_value <= rank;
    pop_new = pop_merged(elites_index,:);
    fit_new = fit_merged(elites_index,:);
    rank_value_new = rank_value(elites_index);
    crowd_dist_new = crowd_dist(elites_index);
else
    % ��֧��ȼ�����rank�ĸ�������������
    elites_index = rank_value < rank;
    len = length(find(elites_index));
    pop_new(1:len,:) = pop_merged(elites_index,:);
    fit_new(1:len,:) = fit_merged(elites_index,:);
    rank_value_new(1:len) = rank_value(elites_index);
    crowd_dist_new(1:len) = crowd_dist(elites_index);
    % ��֧��ȼ�����rank�ĸ�������
    rank_index = find(rank_value == rank);
    % ӵ������Ӵ�С����
    [~,index] = sort(crowd_dist(rank_index),'descend');
    elites_index = rank_index(index(1:pop_size-len));
    pop_new(len+1:end,:) = pop_merged(elites_index,:);
    fit_new(len+1:end,:) = fit_merged(elites_index,:);
    rank_value_new(len+1:end) = rank_value(elites_index);
    crowd_dist_new(len+1:end) = crowd_dist(elites_index);
end
