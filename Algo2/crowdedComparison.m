%% 拥挤比较算子
%%-------------------------------------------------------------------------
function index = crowdedComparison(rank_value,crowd_dist)
% 优先选择非支配等级最高的个体
index = find(rank_value == min(rank_value));
% 如果等级相同，则选择拥挤距离最大的个体
if length(index) > 1
    crowd_dist_index = crowd_dist(index);
    [~,i] = max(crowd_dist_index);
    index = index(i);
end
