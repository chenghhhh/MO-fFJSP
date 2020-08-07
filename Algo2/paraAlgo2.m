%% ����ʵ��
%%-------------------------------------------------------------------------
clear,clc
close all

ind = [1,1,3;1,2,4;1,3,2;1,4,1;
       2,1,4;2,2,3;2,3,1;2,4,2;
       3,1,2;3,2,4;3,3,3;3,4,1;
       4,1,1;4,2,4;4,3,2;4,4,3];            % ����ʵ���

gll = 10:10:40;                             % ȫ���쵼������
mg = 3:6;                                   % �������
pr = 0.1:0.1:0.4;                           % �Ŷ���
rt = 60;                                    % ����ʱ��
problem_num = 12;                           % ��������
run_num = 10;                               % ���д���
file1 = '../Data/A300/dataA';               % ���������ļ���
file2 = '../Data/A300/popA';                % ��ʼ��Ⱥ�ļ���
file3 = '../ParaRes/algo2A';              % �������ļ���
% ��ʼ��Paretoǰ�غ͵�������
pareto_front(run_num,1) = struct('pop',[],'fit',[]);
iteration = zeros(run_num,1);

% ��ÿ������
for pn = 3:4:problem_num
    % �ַ������ӳ������ļ���
    data_name = strcat(file1,num2str(pn));
    pop_name = strcat(file2,num2str(pn));
    % ��������
    for ei = 1:16
        i = ind(ei,1);          % ����1ˮƽ
        j = ind(ei,2);          % ����2ˮƽ
        k = ind(ei,3);          % ����3ˮƽ
        % ����run_num��
        for rn = 1:run_num
            [pareto_front(rn,1),iteration(rn)] = ...
                main(data_name,pop_name,gll(i),mg(j),pr(k),rt);
        end
        solution_name = strcat(file3,num2str(pn),'L',num2str(ei));
        save(solution_name,'pareto_front','iteration')
    end
    % ���µ���ʱ��
    rt = rt + 30;
end
disp("program end")

