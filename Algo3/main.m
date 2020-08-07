%% ������
% Version: 1.0
% Description: 1.����: ��������: ��㽻��
%                      �������: ��ǰ���򽻲�
%              2.����: ��������: �������
%                      �������: ������������k=3��
%%-------------------------------------------------------------------------
function [pareto_front,iter] = main(run_num,data_name,pop_name)
tic
%% ****************************��ʼ������****************************
% ������������
load(data_name,'num_job','num_machine','num_operation','processing_time',...
    'machine_set','se_index','alpha_value','criticality_level','quality_level')
pop_size = 300;                             % ��Ⱥ��ģ
iteration = 90;                             % ����ʱ��
prob_cr = 0.8;                              % �������
prob_mu = 0.2;                              % �������
pool_size = 2;                              % ��������ѡ�ش�С
%% ****************************��ʼ����Ⱥ****************************
load(pop_name,'rank_value','crowd_dist','pop','fit')
%% ******************************��ѭ��******************************
iter = 1;
while toc <= iteration
%     fprintf("��ǰ���д���|��ǰ���������� "),disp([num2str(run_num) '|' num2str(iter)])
    %% ---------------------------ѡ�����---------------------------
    pop_new = tournamentSelection(pop,pool_size,rank_value,crowd_dist);
    %% ---------------------------�������---------------------------
    pop_new = crossover(pop_new,prob_cr,num_job,num_operation);
    %% ---------------------------�������---------------------------
    pop_new = mutation(pop_new,prob_mu,num_job,num_operation,machine_set,se_index);
    %% --------------------------��Ӧ�ȼ���--------------------------
    fit_new = fitness(pop_new,num_job,num_machine,processing_time,...
        se_index(:,1),quality_level,criticality_level,alpha_value);
    %% ---------------------------��Ӣ����---------------------------
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