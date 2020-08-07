%% 变异操作
%%-------------------------------------------------------------------------
function pop = mutation(pop,perturbation_rate,num_job,num_operation,machine_set,se_index)
pop_len = sum(num_operation);               % 工序总数
pop_size = size(pop,1);                     % 种群规模
for i = 1:pop_size
    if perturbation_rate > rand
        %% 机器编码：单点变异
        % 随机选择一个工件
        job = randperm(num_job,1);
        % 从所选工件中随机选择一个工序
        operation = randperm(num_operation(job),1);
        % 对应的加工机器集
        machines = machine_set{job}{operation};
        % 随机选取不同于当前机器的机器，如果可选机器集大小为1则不操作
        if length(machines) > 1
            % 随机产生一台机器的索引
            machine = randperm(length(machines)-1,1);
            % 将当前机器从候选集中删除
            machine_index = se_index(job,1) + operation - 1;
            machines(machines == pop(i,machine_index)) = [];
            % 更新机器
            pop(i,machine_index) = machines(machine);
        end
        %% 工序编码：插入变异
        % 随机选择两个工序位置
        jobs = randperm(pop_len,2);
        a = jobs(1);
        b = jobs(2);
        % 当前个体的工序编码
        seq = pop(i,pop_len+1:end);
        % 示例：jobs = [a,b];将a插入到b的位置
        % a > b的情况
        % seq: 3 2 4 1 3 2 3
        %        b     a
        % seq(1:b-1),seq(a),seq(b:a-1),seq(a+1:end)
        % 3 3 2 4 1 2 3
        % a < b的情况
        % seq: 3 2 4 1 3 2 3
        %        a     b
        % seq(1:a-1),seq(a+1:b-1),seq(a),seq(b:end)
        % 3 4 1 2 3 2 3
        if jobs(1) > jobs(2)
            seq = [seq(1:b-1),seq(a),seq(b:a-1),seq(a+1:end)];
        else
            seq = [seq(1:a-1),seq(a+1:b-1),seq(a),seq(b:end)];
        end
        pop(i,pop_len+1:end) = seq;
    end
end
