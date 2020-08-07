%% 位置更新
%%-------------------------------------------------------------------------
function pop = crossover(pop,perturbation_rate,num_job,num_operation)
total_num_operation = sum(num_operation);       % 总工序数
pop_size = size(pop,1);                         % 种群规模
%% 机器编码：多点交叉
for i = 1:2:pop_size-1
    if rand >= perturbation_rate
        % 父代机器基因段
        machine_genes1 = pop(i  ,1:total_num_operation);
        machine_genes2 = pop(i+1,1:total_num_operation);
        % 随机产生与染色体长度相等的1,2序列
        rand_seq = randi([1,2],[1 total_num_operation]);
        index1 = (rand_seq == 1);
        index2 = (rand_seq == 2);
        pop(i  ,index2) = machine_genes2(index2);
        pop(i+1,index1) = machine_genes1(index1);
    end
end
%% 工序编码：紧前工序交叉
for i = 1:2:pop_size-1
    if rand >= perturbation_rate
        % 父代工序基因段
        operation_genes1 = pop(i  ,total_num_operation+1:end);
        operation_genes2 = pop(i+1,total_num_operation+1:end);
        % 将工件随机分成两个集合
        len = floor(num_job/2);
        job_set = randperm(num_job,len);
        % 父代工序集job_set2中各工序的索引
        index1 = zeros(sum(num_operation(job_set)),1);
        index2 = index1;
        end_index = 0;
        for j = 1:len
            job = job_set(j);
            start_index = end_index + 1;
            end_index = end_index + num_operation(job);
            index1(start_index:end_index) = find(operation_genes1 == job);
            index2(start_index:end_index) = find(operation_genes2 == job);
        end
        index1 = sort(index1);
        index2 = sort(index2);
        pop(i  ,index1+total_num_operation) = operation_genes2(index2);
        pop(i+1,index2+total_num_operation) = operation_genes1(index1);
    end
end
