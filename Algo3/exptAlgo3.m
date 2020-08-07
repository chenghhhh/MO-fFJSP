clear,clc
close all

problem_num = 12;                           % ��������
run_num = 10;                               % ���д���
file1 = '../Data/A300/dataA';               % ���������ļ���
file2 = '../Data/A300/popA';                % ��ʼ��Ⱥ�ļ���
file3 = '../Solution/A/algo3p300t90A';      % �������ļ���
% ��ʼ��Paretoǰ�غ͵�������
pareto_front(run_num,1) = struct('pop',[],'fit',[]);
iteration = zeros(run_num,1);

% ��ÿ������
for pn = 1:problem_num
    % �ַ������ӳ������ļ���
    data_name = strcat(file1,num2str(pn));
    pop_name = strcat(file2,num2str(pn));
    % ����run_num��
    for rn = 1:run_num
        [pareto_front(rn,1),iteration(rn)] = main(rn,data_name,pop_name);
    end
    solution_name = strcat(file3,num2str(pn));
    save(solution_name,'pareto_front','iteration')
end
disp("program end")
