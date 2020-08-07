%% 主函数
% Version: final
% Description: 1.领导者为前沿面
%              2.交叉变异：与NSGA-II相同
%                交叉：局部领导者阶段
%                变异：全局领导者阶段
%              3.精英策略：原始种群与领导者阶段优化后的新种群合并
%              4.剔除领导者前沿面中重复个体
%              5.可变邻域搜索 
%              6.6个阶段长代码形式
%%-------------------------------------------------------------------------
function [global_leader,iter] = main(data_name,pop_name,gll,mg,pr,rt)
tic
%% ****************************初始化参数****************************
% 导入算例数据 
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level')
pop_size = 300;                             % 种群规模
iteration = rt;                            % 迭代次数
perturbation_rate = pr;                     % 扰动率
pool_size = 2;                              % 锦标赛候选池大小
global_leader_limit = gll;                  % 全局领导者限制
local_leader_limit = 2*gll;                 % 局部领导者限制
local_limit_counter = zeros(1,1);           % 局部限制计数器
global_limit_counter = 0;                   % 全局限制计数器
maximum_group = mg;                         % 最大组数
group_num = 1;                              % 组数计数器
group_size = pop_size;                      % 小组规模
group_index = [1,pop_size];                 % 每组的开始和结束索引
%% ****************************初始化种群****************************
load(pop_name,'rank_value','pop','fit')
% 更新初始种群的全局领导者和局部领导者
global_leader.pop = pop(rank_value == 1,:);
global_leader.fit = fit(rank_value == 1,:);
% 删除前沿面中相同的点
[global_leader.fit,unique_ind] = unique(global_leader.fit,'rows');
global_leader.pop = global_leader.pop(unique_ind,:);
% 初始时，局部领导者与全局领导者相同
local_leader = global_leader;
%% ******************************主循环******************************
iter = 1;
while toc <= iteration
%     fprintf("当前运行次数|当前迭代次数： "),disp([num2str(run_num) '|' num2str(iter)])
    %% ------------------------局部领导者阶段------------------------
    pop_new = pop;
    % 对每个group
    for gi = 1:group_num
        % 对当前group中的每个个体
        si = group_index(gi,1);
        ei = group_index(gi,2);
        pop_new(si:ei,:) = crossover(pop(si:ei,:),perturbation_rate,...
            num_job,num_operation);
    end
    %% ------------------------全局领导者阶段------------------------
    % 计算适应度值
    fit_new = fitness(pop_new,num_job,num_machine,processing_time,...
        se_index(:,1),quality_level,criticality_level,alpha_value);
    % 计算非支配等级和拥挤距离
    [rank_value,crowd_dist] = nondominatedSort(fit_new);
    % 对每个group
    for gi = 1:group_num
        % 获取当前小组的开始、结束索引及规模
        si = group_index(gi,1);
        ei = group_index(gi,2);
        gs = group_size(gi);
        % 锦标赛选择法产生与小组规模相同的子种群
        group_new = tournamentSelection(pop_new(si:ei,:),rank_value(si:ei),...
            crowd_dist(si:ei),pool_size);
        group_new = mutation(group_new,perturbation_rate,num_job,...
            num_operation,machine_set,se_index);
        group_fit = fitness(group_new,num_job,num_machine,processing_time,...
            se_index(:,1),quality_level,criticality_level,alpha_value);
        % 合并位置更新前后小组种群
        pop_merged = [pop(si:ei,:);group_new];
        fit_merged = [fit(si:ei,:);group_fit];
        % 计算非支配等级和拥挤距离
        [group_rank_value,group_crowd_dist] = nondominatedSort(fit_merged);
        % 精英保留策略
        [pop(si:ei,:),fit(si:ei,:),rank_value(si:ei,:)] = ...
            elitesRetention(pop_merged,fit_merged,gs,group_rank_value,group_crowd_dist);
    end
    %% ----------------------局部领导者学习阶段----------------------
    % 对每个group
    for gi = 1:group_num
        % 获取当前小组的开始、结束索引
        si = group_index(gi,1);
        ei = group_index(gi,2);
        % 获取新组中最优个体
        candidate_ind = si + find(rank_value(si:ei)==1) - 1;
        candidate.pop = pop(candidate_ind,:);
        candidate.fit = fit(candidate_ind,:);
        % 更新局部领导者和局部限制计数器
        [candidate.fit,unique_ind] = unique(candidate.fit,'rows');
        if isequal(candidate.fit,local_leader(gi).fit)
            local_limit_counter(gi) = local_limit_counter(gi) + 1;
        else
            candidate.pop = candidate.pop(unique_ind,:);
            local_leader(gi) = candidate;
            local_limit_counter(gi) = 0;
        end
    end
    %% ----------------------全局领导者学习阶段----------------------
    % 初始化候选集
    candidate = global_leader;
    % 将所有局部领导者前沿与全局领导者前沿合并成候选集
    for gi = 1:group_num
        candidate.pop = [candidate.pop;local_leader(gi).pop];
        candidate.fit = [candidate.fit;local_leader(gi).fit];
    end
    % 删除重复个体
    [candidate.fit,ind] = unique(candidate.fit,'rows');
    candidate.pop = candidate.pop(ind,:);
    % 计算非支配等级和拥挤距离
    [rank_value,~] = nondominatedSort(candidate.fit);
    % 候选全局领导者
    candidate.pop = candidate.pop(rank_value == 1,:);
    candidate.fit = candidate.fit(rank_value == 1,:);
    % 更新全局领导者和全局限制计数器
    if isequal(candidate.fit,global_leader.fit)
        global_limit_counter = global_limit_counter + 1;
    else
        global_leader = candidate;
        global_limit_counter = 0;
    end
    %% ----------------------局部领导者决策阶段----------------------
    % 对每个group
    for gi = 1:group_num
        if local_limit_counter(gi) > local_leader_limit
            local_limit_counter(gi) = 0;
            % 获取当前小组的开始和规模
            si = group_index(gi,1);
            ei = group_index(gi,2);
            gs = group_size(gi);
            rand_seq = rand(1,gs);
            % index1为随机初始化的个体索引, index2为可变邻域搜索的个体索引
            index1 = si + find(rand_seq >= perturbation_rate) - 1;
            index2 = si + find(rand_seq <  perturbation_rate) - 1;
            pop(index1,:) = initialization(length(index1),se_index,num_operation,machine_set,num_job);
            fit(index1,:) = fitness(pop(index1,:),num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
            [pop(index2,:),fit(index2,:)] = vns(pop(index2,:),fit(index2,:),data_name);
            % 计算适应度值
            fit(si:ei,:) = fitness(pop(si:ei,:),num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
            % 计算非支配等级
            [rank_value,~] = nondominatedSort(fit(si:ei,:));
            ind = si + find(rank_value == 1) - 1;
            % 更新局部领导者
            local_leader(gi).pop = pop(ind,:);
            local_leader(gi).fit = fit(ind,:);
            % 删除局部领导者中前沿面中相同的点
            [local_leader(gi).fit,ind] = unique(local_leader(gi).fit,'rows');
            local_leader(gi).pop = local_leader(gi).pop(ind,:);
        end
    end
    %% ----------------------全局领导者决策阶段----------------------
    if global_limit_counter > global_leader_limit
        % 更新全局领导者计数器
        global_limit_counter = 0;
        % 如果未达到最大组数，则进行分割；否则，进行聚合
        if group_num < maximum_group
            % 分割种群为多组
            group_num = group_num + 1;
            % 初始化每组的种群规模和始末索引
            group_size = zeros(group_num,1);
            group_index = zeros(group_num,2);
            % 获取小组平均种群规模
            aver_size = fix(pop_size / group_num);
            % 更新不同小组的种群规模
            group_size(1:group_num-1) = aver_size;
            group_size(group_num) = aver_size + mod(pop_size,group_num);
            % 更新不同小组种群的开始和结束索引
            group_index(:,2) = cumsum(group_size);
            group_index(:,1) = group_index(:,2) - group_size + 1;
            % 更新局部限制计数器以及初始化局部领导者
            local_leader(group_num,1) = struct('pop',[],'fit',[]);
            % 对每个group,更新局部领导者
            for gi = 1:group_num
                % 获取当前小组的开始、结束索引
                si = group_index(gi,1);
                ei = group_index(gi,2);
                % 计算非支配等级
                [rank_value,~] = nondominatedSort(fit(si:ei,:));
                ind = si + find(rank_value == 1) - 1;
                % 更新局部领导者
                local_leader(gi).pop = pop(ind,:);
                local_leader(gi).fit = fit(ind,:);
                % 删除局部领导者中前沿面中相同的点
                [local_leader(gi).fit,ind] = unique(local_leader(gi).fit,'rows');
                local_leader(gi).pop = local_leader(gi).pop(ind,:);
            end
        else
            group_num = 1;
            group_size = pop_size;
            group_index = [1,pop_size];
            local_leader = global_leader;
        end
        % 更新局部领导者计数器
        local_limit_counter = zeros(group_num,1);
    end
    % 更新迭代计数器
    iter = iter + 1;
end
