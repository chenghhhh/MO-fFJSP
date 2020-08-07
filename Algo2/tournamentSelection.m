%% 二进制锦标赛选择
%%-------------------------------------------------------------------------
function pop_new = tournamentSelection(pop,rank_value,crowd_dist,pool_size)
pop_size = size(pop,1);
pop_new = pop;
for i = 1:pop_size
    % 随机从种群中选择pool_size个个体，其中pool_size为选择池个体个数
    pool = randperm(pop_size,pool_size);
    % 获取候选个体的非支配排序值
    pool_rank =  rank_value(pool,:);
    % 先根据非支配排序值选择最高等级的个体
    ind = find(pool_rank == min(pool_rank));
    % 如果存在相同等级的个体，则选择拥挤度最大的个体
    if length(ind) > 1
        pool_new = pool(ind);
        crowd_dist_ind = crowd_dist(pool_new);
        [~,ind] = max(crowd_dist_ind);
    end
    % 更新个体
    pop_new(i,:) = pop(pool(ind),:);
end