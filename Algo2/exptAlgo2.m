%% ����ʵ��
%%-------------------------------------------------------------------------
clear,clc
close all

gll = 30;                             % ȫ���쵼������
mg = 4;                               % �������
pr = 0.2;                             % �Ŷ���
rt = 120;                             % ����ʱ��
pn = 11;                              % �������
run_num = 10;                         % ���д���
file1 = '../Data/A300/dataA';         % ���������ļ���
file2 = '../Data/A300/popA';          % ��ʼ��Ⱥ�ļ���
file3 = '../Solution/algo2t90A';      % �������ļ���
% ��ʼ��Paretoǰ�غ͵�������
pareto_front(run_num,1) = struct('pop',[],'fit',[]); 
iteration = zeros(run_num,1);

% �ַ������ӳ������ļ���
data_name = strcat(file1,num2str(pn));
pop_name = strcat(file2,num2str(pn));
% ����run_num��
for rn = 1:run_num
    [pareto_front(rn,1),iteration(rn)] = main(data_name,pop_name,gll,mg,pr,rt);
end
solution_name = strcat(file3,num2str(pn));
save(solution_name,'pareto_front','iteration')
disp("program end")