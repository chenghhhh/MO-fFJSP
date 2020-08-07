%% 非支配排序
%%-------------------------------------------------------------------------
function [rank_value,crowd_dist] = nondominatedSort(fit_value)
pop_size = size(fit_value,1);               % 种群大小
% 三角模糊完工时间加权平均为单个数
Z = zeros(pop_size,2);
weight = [-0.2;0.8;0.2];                    % 三角模糊数权重
Z(:,1) = fit_value(:,1:3) * weight;         % 第一个目标值
Z(:,2) = fit_value(:,4);                    % 第二个目标值
%% --------------------------快速非支配排序--------------------------
objective_num = size(Z,2);                  % 目标数量
dominate_set = cell(pop_size,1);            % 当前个体支配的个体集合
dominated_num = zeros(pop_size,1);          % 支配当前个体的数量
rank_value = zeros(pop_size,1);             % 个体等级
front_set = {[]};                           % 前沿面集合
%% 确定第一前沿面
for i = 1:pop_size-1
    % 当前个体与其后续个体一一进行比较
    for j = i+1:pop_size
        % IF  个体i的平均makespan < 个体j的平均makespan
        %     IF  个体i的加工质量 >= 个体j的质量
        %         个体i支配个体j;
        %     END IF
        % ELSE IF  个体i的平均makespan > 个体j的平均makespan
        %     IF  个体i的加工质量 <= 个体j的质量
        %         个体j支配个体i;
        %     END IF
        % ELSE  // 两者相等
        %     IF  个体i最有可能的makespan < 个体j最有可能的makespan
        %         IF  个体i的加工质量 >= 个体j的质量
        %             个体i支配个体j;
        %         END IF
        %     ELSE IF  个体i最有可能的makespan == 个体j最有可能的makespan
        %         IF  个体i的加工质量 > 个体j的质量
        %             个体i支配个体j;
        %         ELSE IF  个体i的加工质量 < 个体j的质量
        %             个体j支配个体i;
        %         END
        %     ELSE  // 个体i最有可能的makespan > 个体j最有可能的makespan
        %         IF  个体i的加工质量 < 个体j的质量
        %             个体j支配个体i;
        %         END IF
        %     END IF
        % END IF
        % // 支配操作
        % 将个体j压入到个体i所支配的个体集合中;
        % 更新支配个体j的数量;
        if Z(i,1) < Z(j,1)
            if Z(i,2) >= Z(j,2)
                dominate_set{i} = [dominate_set{i},j];
                dominated_num(j) = dominated_num(j) + 1;
            end
        elseif Z(i,1) > Z(j,1)
            if Z(i,2) <= Z(j,2)
                dominate_set{j} = [dominate_set{j},i];
                dominated_num(i) = dominated_num(i) + 1;
            end
        else
            if fit_value(i,2) < fit_value(j,2)
                if Z(i,2) >= Z(j,2)
                    dominate_set{i} = [dominate_set{i},j];
                    dominated_num(j) = dominated_num(j) + 1;
                end
            elseif fit_value(i,2) == fit_value(j,2)
                if Z(i,2) > Z(j,2)
                    dominate_set{i} = [dominate_set{i},j];
                    dominated_num(j) = dominated_num(j) + 1;
                elseif Z(i,2) < Z(j,2)
                    dominate_set{j} = [dominate_set{j},i];
                    dominated_num(i) = dominated_num(i) + 1;
                end
            else
                if Z(i,2) < Z(j,2)
                    dominate_set{j} = [dominate_set{j},i];
                    dominated_num(i) = dominated_num(i) + 1;
                end
            end
        end
    end
    % n==0的个体为第一前沿面个体
    if dominated_num(i) == 0
        % 将第一前沿面个体的等级值设置为1
        rank_value(i) = 1;
        % 更新第一前沿面集合
        front_set{1} = [front_set{1},i];
    end
end
% 单独处理最后一个个体
if dominated_num(pop_size) == 0
    rank_value(pop_size) = 1;
    front_set{1} = [front_set{1},pop_size];
end
%% 确定其他前沿面
k = 1;                              % 前沿面计数器
while ~isempty(front_set{k})
    next_front = [];                % 保存下一前沿面的成员
    current_front = front_set{k};   % 当前个体
    % 对当前前沿面上的个体
    for p = 1:length(current_front)
        % 获取当前个体所支配的个体
        dominate_set_p = dominate_set{current_front(p)};
        % 对每个被当前个体p支配的个体q，将支配个体q的个体数量减1
        % 等价于将当前前沿面上的点全部移除
        for q = 1:length(dominate_set_p)
            j = dominate_set_p(q);
            dominated_num(j) = dominated_num(j) - 1;
            % n==0 个体j不被剩余种群中的个体所支配
            if dominated_num(j) == 0
                % 更新等级
                rank_value(j) = k + 1;
                % 更新下一前沿面
                next_front = [next_front,j];
            end
        end
    end
    % 前沿面计数器自增
    k = k + 1;
    % 更新前沿面k的成员
    front_set{k} = sort(next_front);
end
%% ----------------------------拥挤度分配----------------------------
num_front = size(front_set,2);         % 前沿面数量
crowd_dist = zeros(pop_size,1);        % 所有个体的拥挤距离
% for each front
for i = 1:num_front-1
    current_front = front_set{i};
    len = length(current_front);
    % 如果当前的前沿面成员数量少于3，则将所有个体的拥挤距离设置为1
    if (len < 3)
        crowd_dist(current_front) = ones(1,len);
        continue;
    end
    z = Z(current_front,:);             % 当前前沿面成员的目标函数值
    crowd_dist_i = zeros(1,len);        % 拥挤距离
    % 对每个目标
    for j = 1:objective_num
        % 对第j个目标函数值进行排序
        [z_j,ind] = sort(z(:,j));
        % 将前沿面两边界成员的拥挤距离设置为正无穷大
        crowd_dist_i(ind(1)) = inf;
        crowd_dist_i(ind(end)) = inf;
        % 计算第j个目标的最大和最小函数值之差
        delta = z_j(end) - z_j(1);
        % 对除边界外的成员进行拥挤距离的计算
        for k = 2:len-1
            crowd_dist_i(ind(k)) = crowd_dist_i(ind(k)) + (z_j(k+1) - z_j(k-1))/delta;
        end
    end
    % 更新当前前沿面的拥挤距离
    crowd_dist(current_front) = crowd_dist_i;
end
