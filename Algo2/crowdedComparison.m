%% ӵ���Ƚ�����
%%-------------------------------------------------------------------------
function index = crowdedComparison(rank_value,crowd_dist)
% ����ѡ���֧��ȼ���ߵĸ���
index = find(rank_value == min(rank_value));
% ����ȼ���ͬ����ѡ��ӵ���������ĸ���
if length(index) > 1
    crowd_dist_index = crowd_dist(index);
    [~,i] = max(crowd_dist_index);
    index = index(i);
end
