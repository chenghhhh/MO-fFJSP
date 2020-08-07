%% �ɱ���������
%%-------------------------------------------------------------------------
function [pop,fit] = vns(pop,fit,data_name)
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level');
pop_len = sum(num_operation);               % ��������
pop_size = size(pop,1);                     % ��Ⱥ��ģ
num_neigh = 50;                             % �����ģ
for i = 1:pop_size
    neigh_pop = pop(i,:).*ones(num_neigh,pop_len*2);
    for j = 1:num_neigh
        %% ��������:���ѡ��I��λ�ø�������
        % �������һ������num_gene (1 <= num_gene <= pop_len/2)
        num_gene = randperm(ceil(pop_len/2),1);
        % �������num_gene����ͬλ��
        genes = randperm(pop_len,num_gene);
        for k = 1:num_gene
            % ��ȡ��ǰ������Ӧ�Ĺ�����
            job = find(se_index(:,2) >= genes(k),1);
            % ��ȡ��ǰ������Ӧ�Ĺ����
            operation = genes(k) - se_index(job,1) + 1;
            % ��ȡ��Ӧ�ļӹ�������
            machines = machine_set{job}{operation};
            % ���ѡȡ��ͬ�ڵ�ǰ�����Ļ����������ѡ��������СΪ1�򲻲���
            if length(machines) > 1
                % �������һ̨����������
                machine = randperm(length(machines)-1,1);
                % ����ǰ�����Ӻ�ѡ����ɾ��
                machines(machines == pop(i,genes(k))) = [];
                % ���»���
                neigh_pop(j,genes(k)) = machines(machine);
            end
        end
        %% ������룺���ѡ�����������������������������й������������
        % ���ѡ����������
        jobs = randperm(num_job,2);
        % ��ȡ�������������й�������
        index1 = find(pop(i,pop_len+1:end) == jobs(1));
        index2 = find(pop(i,pop_len+1:end) == jobs(2));
        index = [index1,index2];
        % �ϲ������������򣬲��������˳��
        num_opt1 = num_operation(jobs(1));
        num_opt2 = num_operation(jobs(2));
        operations = [jobs(1)*ones(1,num_opt1),jobs(2)*ones(1,num_opt2)];
        index = index(randperm(num_opt1+num_opt2));
        neigh_pop(j,pop_len+index) = operations;
    end
    % ����������Ӧ��
    neigh_fit = fitness(neigh_pop,num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
    [rank_value,~] = nondominatedSort(neigh_fit);
    % ��ѡ�������Ϊǰ��
    neigh_pop = neigh_pop(rank_value==1,:);
    neigh_fit = neigh_fit(rank_value==1,:);
    ind = randperm(size(neigh_pop,1),1);
    pop(i,:) = neigh_pop(ind,:);
    fit(i,:) = neigh_fit(ind,:);
end
