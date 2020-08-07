%% ��Ӧ�Ⱥ���
%%-------------------------------------------------------------------------
function Z = fitness(pop,num_job,num_machine,processing_time,start_index,...
    quality_level,criticality_level,alpha_value)
pop_size = size(pop,1);                         % ��Ⱥ��ģ
Z = zeros(pop_size,4);                          % Ŀ�꺯��
total_num_operation = size(pop,2) / 2;          % �ܹ�������
% ��ÿ������
for i = 1:pop_size
    job_time = zeros(num_job,3);                % ��¼�����ۼ��깤ʱ��
    machine_time = zeros(num_machine,3);        % ��¼�����ۼ��깤ʱ��
    job_operation = ones(num_job,1);            % ����-���������
    for j = 1:total_num_operation
        %% Ŀ�꺯��1����С���깤ʱ��
        % ��ȡ��ǰ����������ͻ���
        job = pop(i,total_num_operation+j);
        operation = job_operation(job);
        machine = pop(i,start_index(job)+operation-1);
        % ȡ�����
        tmp = max(job_time(job,:),machine_time(machine,:));
        % ���µ�ǰ�������ۼ�ʱ��
        job_time(job,:) = tmp + processing_time{job}{operation};
        % ���µ�ǰ�������ۼ�ʱ��
        machine_time(machine,:) = job_time(job,:);
        %% Ŀ�꺯��2����󻯼ӹ�����
        Z(i,4) = Z(i,4) + quality_level(machine) * (criticality_level(job) + ...
            alpha_value * operation);
        % ���¹��������
        job_operation(job) = job_operation(job) + 1;
    end
    %% �����깤ʱ��(����ģ���ӹ�ʱ��[t1,t2,t3])
    % ����Ѱ�����t3
    ind_t3 = find(machine_time(:,3) == max(machine_time(:,3)));
    if length(ind_t3) == 1
        % ���ֻ��һ�����t3,�����ٽ����ж�
        machine_index = ind_t3;
    else
        % ����ж�����t3, ����Ѱ�����������t2
        ind_t2 = find(machine_time(ind_t3,2) == max(machine_time(ind_t3,2)));
        if length(ind_t2) == 1
            % ���ֻ��һ�����t2, ����Ҫ�ٽ����ж�
            machine_index = ind_t3(ind_t2);
        else
            % ����ж�����t1, ����Ѱ�������е�һ�����t1����
            ind_t2 = ind_t3(ind_t2);
            [~,ind_t1] =  max(machine_time(ind_t2,1));
            machine_index = ind_t2(ind_t1);
        end
    end
    Z(i,1:3) = machine_time(machine_index,:);
end
