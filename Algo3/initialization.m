%% 随机产生种群
%%-------------------------------------------------------------------------
function pop = initialization(pop_size,se_index,num_operation,machine_set,num_job)
total_num_operation = sum(num_operation);       % 所有工件的总工序数
pop = zeros(pop_size,2*total_num_operation);    % 个体：机器序列+工序序列
%% 获取工序调度初始序列
% 示例：11112222222333344444....8899999
% 表示工件1有4道工序,工件2有7道工序,...,工件9有5道工序
init_sequence = zeros(1,total_num_operation);
for j = 1:num_job
    % 工件所处基因片段值全赋值为工件索引
    init_sequence(se_index(j,1):se_index(j,2)) = j;
end
%% 随机初始化种群
for i = 1:pop_size
    %% 初始化机器分配
    counter = 1;
    for j = 1:num_job
        for k = 1:num_operation(j)
            machine_index = randperm(length(machine_set{j}{k}),1);
            pop(i,counter) = machine_set{j}{k}(machine_index);
            counter = counter + 1;
        end
    end
    %% 初始化工序调度
    pop(i,total_num_operation+1:end) = init_sequence(randperm(total_num_operation));
end
