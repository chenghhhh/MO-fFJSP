%% 适应度函数
%%-------------------------------------------------------------------------
function Z = fitness(pop,num_job,num_machine,processing_time,start_index,...
    quality_level,criticality_level,alpha_value)
pop_size = size(pop,1);                         % 种群规模
Z = zeros(pop_size,4);                          % 目标函数
total_num_operation = size(pop,2) / 2;          % 总工序数量
% 对每个个体
for i = 1:pop_size
    job_time = zeros(num_job,3);                % 记录工件累计完工时间
    machine_time = zeros(num_machine,3);        % 记录机器累计完工时间
    job_operation = ones(num_job,1);            % 工件-工序计数器
    for j = 1:total_num_operation
        %% 目标函数1：最小化完工时间
        % 获取当前工件、工序和机器
        job = pop(i,total_num_operation+j);
        operation = job_operation(job);
        machine = pop(i,start_index(job)+operation-1);
        % 取大操作
        tmp = max(job_time(job,:),machine_time(machine,:));
        % 更新当前工件的累计时间
        job_time(job,:) = tmp + processing_time{job}{operation};
        % 更新当前机器的累计时间
        machine_time(machine,:) = job_time(job,:);
        %% 目标函数2：最大化加工质量
        Z(i,4) = Z(i,4) + quality_level(machine) * (criticality_level(job) + ...
            alpha_value * operation);
        % 更新工序计数器
        job_operation(job) = job_operation(job) + 1;
    end
    %% 更新完工时间(三角模糊加工时间[t1,t2,t3])
    % 首先寻找最长的t3
    ind_t3 = find(machine_time(:,3) == max(machine_time(:,3)));
    if length(ind_t3) == 1
        % 如果只有一个最长的t3,则不需再进行判断
        machine_index = ind_t3;
    else
        % 如果有多个最长的t3, 则再寻找它们中最长的t2
        ind_t2 = find(machine_time(ind_t3,2) == max(machine_time(ind_t3,2)));
        if length(ind_t2) == 1
            % 如果只有一个最长的t2, 则不需要再进行判断
            machine_index = ind_t3(ind_t2);
        else
            % 如果有多个最长的t1, 则再寻找它们中第一个最长的t1即可
            ind_t2 = ind_t3(ind_t2);
            [~,ind_t1] =  max(machine_time(ind_t2,1));
            machine_index = ind_t2(ind_t1);
        end
    end
    Z(i,1:3) = machine_time(machine_index,:);
end
