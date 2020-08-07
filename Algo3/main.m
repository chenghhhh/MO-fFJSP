%% 主函数
% Version: 1.0
% Description: 1.交叉: 机器编码: 多点交叉
%                      工序编码: 紧前工序交叉
%              2.变异: 机器编码: 单点变异
%                      工序编码: 变邻域搜索（k=3）
%%-------------------------------------------------------------------------
function [pareto_front,iter] = main(run_num,data_name,pop_name)
tic
%% ****************************初始化参数****************************
% 导入算例数据
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level')
pop_size = 300;                             % 种群规模
iteration = 90;                             % 迭代时间
prob_cr = 0.8;                              % 交叉概率
prob_mu = 0.2;                              % 变异概率
pool_size = 2;                              % 锦标赛候选池大小
%% ****************************初始化种群****************************
load(pop_name,'rank_value','crowd_dist','pop','fit')
%% ******************************主循环******************************
iter = 1;
while toc <= iteration
%     fprintf("当前运行次数|当前迭代次数： "),disp([num2str(run_num) '|' num2str(iter)])
    %% ---------------------------选择操作---------------------------
    pop_new = tournamentSelection(pop,pool_size,rank_value,crowd_dist);
    %% ---------------------------交叉操作---------------------------
    pop_new = crossover(pop_new,prob_cr,num_job,num_operation);
    %% ---------------------------变异操作---------------------------
    pop_new = mutation(pop_new,prob_mu,num_job,num_operation,machine_set,se_index);
    %% --------------------------适应度计算--------------------------
    fit_new = fitness(pop_new,num_job,num_machine,processing_time,...
        se_index(:,1),quality_level,criticality_level,alpha_value);
    %% ---------------------------精英策略---------------------------
    pop_merged = [pop;pop_new];
    fit_merged = [fit;fit_new];
    [rank_value,crowd_dist] = nondominatedSort(fit_merged);
    [pop,fit,rank_value,crowd_dist] = elitesRetention(pop_merged,fit_merged,...
        pop_size,rank_value,crowd_dist);
    iter = iter + 1;
end
pareto_front.pop = pop(rank_value==1,:);
pareto_front.fit = fit(rank_value==1,:);
[pareto_front.fit,unique_ind] = unique(pareto_front.fit,'rows');
pareto_front.pop = pareto_front.pop(unique_ind,:);