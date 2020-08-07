%% ������
% Version: final
% Description: 1.�쵼��Ϊǰ����
%              2.������죺��NSGA-II��ͬ
%                ���棺�ֲ��쵼�߽׶�
%                ���죺ȫ���쵼�߽׶�
%              3.��Ӣ���ԣ�ԭʼ��Ⱥ���쵼�߽׶��Ż��������Ⱥ�ϲ�
%              4.�޳��쵼��ǰ�������ظ�����
%              5.�ɱ��������� 
%              6.6���׶γ�������ʽ
%%-------------------------------------------------------------------------
function [global_leader,iter] = main(data_name,pop_name,gll,mg,pr,rt)
tic
%% ****************************��ʼ������****************************
% ������������ 
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level')
pop_size = 300;                             % ��Ⱥ��ģ
iteration = rt;                            % ��������
perturbation_rate = pr;                     % �Ŷ���
pool_size = 2;                              % ��������ѡ�ش�С
global_leader_limit = gll;                  % ȫ���쵼������
local_leader_limit = 2*gll;                 % �ֲ��쵼������
local_limit_counter = zeros(1,1);           % �ֲ����Ƽ�����
global_limit_counter = 0;                   % ȫ�����Ƽ�����
maximum_group = mg;                         % �������
group_num = 1;                              % ����������
group_size = pop_size;                      % С���ģ
group_index = [1,pop_size];                 % ÿ��Ŀ�ʼ�ͽ�������
%% ****************************��ʼ����Ⱥ****************************
load(pop_name,'rank_value','pop','fit')
% ���³�ʼ��Ⱥ��ȫ���쵼�ߺ;ֲ��쵼��
global_leader.pop = pop(rank_value == 1,:);
global_leader.fit = fit(rank_value == 1,:);
% ɾ��ǰ��������ͬ�ĵ�
[global_leader.fit,unique_ind] = unique(global_leader.fit,'rows');
global_leader.pop = global_leader.pop(unique_ind,:);
% ��ʼʱ���ֲ��쵼����ȫ���쵼����ͬ
local_leader = global_leader;
%% ******************************��ѭ��******************************
iter = 1;
while toc <= iteration
%     fprintf("��ǰ���д���|��ǰ���������� "),disp([num2str(run_num) '|' num2str(iter)])
    %% ------------------------�ֲ��쵼�߽׶�------------------------
    pop_new = pop;
    % ��ÿ��group
    for gi = 1:group_num
        % �Ե�ǰgroup�е�ÿ������
        si = group_index(gi,1);
        ei = group_index(gi,2);
        pop_new(si:ei,:) = crossover(pop(si:ei,:),perturbation_rate,...
            num_job,num_operation);
    end
    %% ------------------------ȫ���쵼�߽׶�------------------------
    % ������Ӧ��ֵ
    fit_new = fitness(pop_new,num_job,num_machine,processing_time,...
        se_index(:,1),quality_level,criticality_level,alpha_value);
    % �����֧��ȼ���ӵ������
    [rank_value,crowd_dist] = nondominatedSort(fit_new);
    % ��ÿ��group
    for gi = 1:group_num
        % ��ȡ��ǰС��Ŀ�ʼ��������������ģ
        si = group_index(gi,1);
        ei = group_index(gi,2);
        gs = group_size(gi);
        % ������ѡ�񷨲�����С���ģ��ͬ������Ⱥ
        group_new = tournamentSelection(pop_new(si:ei,:),rank_value(si:ei),...
            crowd_dist(si:ei),pool_size);
        group_new = mutation(group_new,perturbation_rate,num_job,...
            num_operation,machine_set,se_index);
        group_fit = fitness(group_new,num_job,num_machine,processing_time,...
            se_index(:,1),quality_level,criticality_level,alpha_value);
        % �ϲ�λ�ø���ǰ��С����Ⱥ
        pop_merged = [pop(si:ei,:);group_new];
        fit_merged = [fit(si:ei,:);group_fit];
        % �����֧��ȼ���ӵ������
        [group_rank_value,group_crowd_dist] = nondominatedSort(fit_merged);
        % ��Ӣ��������
        [pop(si:ei,:),fit(si:ei,:),rank_value(si:ei,:)] = ...
            elitesRetention(pop_merged,fit_merged,gs,group_rank_value,group_crowd_dist);
    end
    %% ----------------------�ֲ��쵼��ѧϰ�׶�----------------------
    % ��ÿ��group
    for gi = 1:group_num
        % ��ȡ��ǰС��Ŀ�ʼ����������
        si = group_index(gi,1);
        ei = group_index(gi,2);
        % ��ȡ���������Ÿ���
        candidate_ind = si + find(rank_value(si:ei)==1) - 1;
        candidate.pop = pop(candidate_ind,:);
        candidate.fit = fit(candidate_ind,:);
        % ���¾ֲ��쵼�ߺ;ֲ����Ƽ�����
        [candidate.fit,unique_ind] = unique(candidate.fit,'rows');
        if isequal(candidate.fit,local_leader(gi).fit)
            local_limit_counter(gi) = local_limit_counter(gi) + 1;
        else
            candidate.pop = candidate.pop(unique_ind,:);
            local_leader(gi) = candidate;
            local_limit_counter(gi) = 0;
        end
    end
    %% ----------------------ȫ���쵼��ѧϰ�׶�----------------------
    % ��ʼ����ѡ��
    candidate = global_leader;
    % �����оֲ��쵼��ǰ����ȫ���쵼��ǰ�غϲ��ɺ�ѡ��
    for gi = 1:group_num
        candidate.pop = [candidate.pop;local_leader(gi).pop];
        candidate.fit = [candidate.fit;local_leader(gi).fit];
    end
    % ɾ���ظ�����
    [candidate.fit,ind] = unique(candidate.fit,'rows');
    candidate.pop = candidate.pop(ind,:);
    % �����֧��ȼ���ӵ������
    [rank_value,~] = nondominatedSort(candidate.fit);
    % ��ѡȫ���쵼��
    candidate.pop = candidate.pop(rank_value == 1,:);
    candidate.fit = candidate.fit(rank_value == 1,:);
    % ����ȫ���쵼�ߺ�ȫ�����Ƽ�����
    if isequal(candidate.fit,global_leader.fit)
        global_limit_counter = global_limit_counter + 1;
    else
        global_leader = candidate;
        global_limit_counter = 0;
    end
    %% ----------------------�ֲ��쵼�߾��߽׶�----------------------
    % ��ÿ��group
    for gi = 1:group_num
        if local_limit_counter(gi) > local_leader_limit
            local_limit_counter(gi) = 0;
            % ��ȡ��ǰС��Ŀ�ʼ�͹�ģ
            si = group_index(gi,1);
            ei = group_index(gi,2);
            gs = group_size(gi);
            rand_seq = rand(1,gs);
            % index1Ϊ�����ʼ���ĸ�������, index2Ϊ�ɱ����������ĸ�������
            index1 = si + find(rand_seq >= perturbation_rate) - 1;
            index2 = si + find(rand_seq <  perturbation_rate) - 1;
            pop(index1,:) = initialization(length(index1),se_index,num_operation,machine_set,num_job);
            fit(index1,:) = fitness(pop(index1,:),num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
            [pop(index2,:),fit(index2,:)] = vns(pop(index2,:),fit(index2,:),data_name);
            % ������Ӧ��ֵ
            fit(si:ei,:) = fitness(pop(si:ei,:),num_job,num_machine,processing_time,...
                se_index(:,1),quality_level,criticality_level,alpha_value);
            % �����֧��ȼ�
            [rank_value,~] = nondominatedSort(fit(si:ei,:));
            ind = si + find(rank_value == 1) - 1;
            % ���¾ֲ��쵼��
            local_leader(gi).pop = pop(ind,:);
            local_leader(gi).fit = fit(ind,:);
            % ɾ���ֲ��쵼����ǰ��������ͬ�ĵ�
            [local_leader(gi).fit,ind] = unique(local_leader(gi).fit,'rows');
            local_leader(gi).pop = local_leader(gi).pop(ind,:);
        end
    end
    %% ----------------------ȫ���쵼�߾��߽׶�----------------------
    if global_limit_counter > global_leader_limit
        % ����ȫ���쵼�߼�����
        global_limit_counter = 0;
        % ���δ�ﵽ�������������зָ���򣬽��оۺ�
        if group_num < maximum_group
            % �ָ���ȺΪ����
            group_num = group_num + 1;
            % ��ʼ��ÿ�����Ⱥ��ģ��ʼĩ����
            group_size = zeros(group_num,1);
            group_index = zeros(group_num,2);
            % ��ȡС��ƽ����Ⱥ��ģ
            aver_size = fix(pop_size / group_num);
            % ���²�ͬС�����Ⱥ��ģ
            group_size(1:group_num-1) = aver_size;
            group_size(group_num) = aver_size + mod(pop_size,group_num);
            % ���²�ͬС����Ⱥ�Ŀ�ʼ�ͽ�������
            group_index(:,2) = cumsum(group_size);
            group_index(:,1) = group_index(:,2) - group_size + 1;
            % ���¾ֲ����Ƽ������Լ���ʼ���ֲ��쵼��
            local_leader(group_num,1) = struct('pop',[],'fit',[]);
            % ��ÿ��group,���¾ֲ��쵼��
            for gi = 1:group_num
                % ��ȡ��ǰС��Ŀ�ʼ����������
                si = group_index(gi,1);
                ei = group_index(gi,2);
                % �����֧��ȼ�
                [rank_value,~] = nondominatedSort(fit(si:ei,:));
                ind = si + find(rank_value == 1) - 1;
                % ���¾ֲ��쵼��
                local_leader(gi).pop = pop(ind,:);
                local_leader(gi).fit = fit(ind,:);
                % ɾ���ֲ��쵼����ǰ��������ͬ�ĵ�
                [local_leader(gi).fit,ind] = unique(local_leader(gi).fit,'rows');
                local_leader(gi).pop = local_leader(gi).pop(ind,:);
            end
        else
            group_num = 1;
            group_size = pop_size;
            group_index = [1,pop_size];
            local_leader = global_leader;
        end
        % ���¾ֲ��쵼�߼�����
        local_limit_counter = zeros(group_num,1);
    end
    % ���µ���������
    iter = iter + 1;
end
