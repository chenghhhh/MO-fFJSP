%% �������
%%-------------------------------------------------------------------------
function pop = mutation(pop,perturbation_rate,num_job,num_operation,machine_set,se_index)
pop_len = sum(num_operation);               % ��������
pop_size = size(pop,1);                     % ��Ⱥ��ģ
for i = 1:pop_size
    if perturbation_rate > rand
        %% �������룺�������
        % ���ѡ��һ������
        job = randperm(num_job,1);
        % ����ѡ���������ѡ��һ������
        operation = randperm(num_operation(job),1);
        % ��Ӧ�ļӹ�������
        machines = machine_set{job}{operation};
        % ���ѡȡ��ͬ�ڵ�ǰ�����Ļ����������ѡ��������СΪ1�򲻲���
        if length(machines) > 1
            % �������һ̨����������
            machine = randperm(length(machines)-1,1);
            % ����ǰ�����Ӻ�ѡ����ɾ��
            machine_index = se_index(job,1) + operation - 1;
            machines(machines == pop(i,machine_index)) = [];
            % ���»���
            pop(i,machine_index) = machines(machine);
        end
        %% ������룺�������
        % ���ѡ����������λ��
        jobs = randperm(pop_len,2);
        a = jobs(1);
        b = jobs(2);
        % ��ǰ����Ĺ������
        seq = pop(i,pop_len+1:end);
        % ʾ����jobs = [a,b];��a���뵽b��λ��
        % a > b�����
        % seq: 3 2 4 1 3 2 3
        %        b     a
        % seq(1:b-1),seq(a),seq(b:a-1),seq(a+1:end)
        % 3 3 2 4 1 2 3
        % a < b�����
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
