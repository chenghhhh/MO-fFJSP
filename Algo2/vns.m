%% 可变邻域搜索
%%-------------------------------------------------------------------------
function [pop,fit] = vns(pop,fit,data_name)
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level');
pop_len = sum(num_operation);               % 工序总数
pop_size = size(pop,1);                     % 种群规模
num_neigh = 50;                             % 邻域规模
for i = 1:pop_size
    neigh_pop = pop(i,:).*ones(num_neigh,pop_len*2);
    for j = 1:num_neigh
        %% 机器编码:随机选择I个位置更换机器
        % 随机产生一个整数num_gene (1 <= num_gene <= pop_len/2)
        num_gene = randperm(ceil(pop_len/2),1);
        % 随机产生num_gene个不同位置
        genes = randperm(pop_len,num_gene);
        for k = 1:num_gene
            % 获取当前机器对应的工件号
            job = find(se_index(:,2) >= genes(k),1);
            % 获取当前机器对应的工序号
            operation = genes(k) - se_index(job,1) + 1;
            % 获取对应的加工机器集
            machines = machine_set{job}{operation};
            % 随机选取不同于当前机器的机器，如果可选机器集大小为1则不操作
            if length(machines) > 1
                % 随机产生一台机器的索引
                machine = randperm(length(machines)-1,1);
                % 将当前机器从候选集中删除
                machines(machines == pop(i,genes(k))) = [];
                % 更新机器
                neigh_pop(j,genes(k)) = machines(machine);
            end
        end
        %% 工序编码：随机选择两个工件，将这两个工件的所有工序随机重排列
        % 随机选择两个工件
        jobs = randperm(num_job,2);
        % 获取两个工件的所有工序索引
        index1 = find(pop(i,pop_len+1:end) == jobs(1));
        index2 = find(pop(i,pop_len+1:end) == jobs(2));
        index = [index1,index2];
        % 合并两个工件工序，并随机打乱顺序
        num_opt1 = num_operation(jobs(1));
        num_opt2 = num_operation(jobs(2));
        operations = [jobs(1)*ones(1,num_opt1),jobs(2)*ones(1,num_opt2)];
        index = index(randperm(num_opt1+num_opt2));
        neigh_pop(j,pop_len+index) = operations;
    end
    % 计算邻域适应度
    neigh_fit = fitness(neigh_pop,num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
    [rank_value,~] = nondominatedSort(neigh_fit);
    % 候选个体更新为前沿
    neigh_pop = neigh_pop(rank_value==1,:);
    neigh_fit = neigh_fit(rank_value==1,:);
    ind = randperm(size(neigh_pop,1),1);
    pop(i,:) = neigh_pop(ind,:);
    fit(i,:) = neigh_fit(ind,:);
end
