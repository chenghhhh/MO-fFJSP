%% 调参实验
%%-------------------------------------------------------------------------
clear,clc
close all

ind = [1,1,3;1,2,4;1,3,2;1,4,1;
       2,1,4;2,2,3;2,3,1;2,4,2;
       3,1,2;3,2,4;3,3,3;3,4,1;
       4,1,1;4,2,4;4,3,2;4,4,3];            % 正交实验表

gll = 10:10:40;                             % 全局领导者限制
mg = 3:6;                                   % 最大组数
pr = 0.1:0.1:0.4;                           % 扰动率
rt = 60;                                    % 迭代时间
problem_num = 12;                           % 算例个数
run_num = 10;                               % 运行次数
file1 = '../Data/A300/dataA';               % 问题数据文件名
file2 = '../Data/A300/popA';                % 初始种群文件名
file3 = '../ParaRes/algo2A';              % 输出结果文件名
% 初始化Pareto前沿和迭代次数
pareto_front(run_num,1) = struct('pop',[],'fit',[]);
iteration = zeros(run_num,1);

% 对每个算例
for pn = 3:4:problem_num
    % 字符串连接成完整文件名
    data_name = strcat(file1,num2str(pn));
    pop_name = strcat(file2,num2str(pn));
    % 正交试验
    for ei = 1:16
        i = ind(ei,1);          % 参数1水平
        j = ind(ei,2);          % 参数2水平
        k = ind(ei,3);          % 参数3水平
        % 运行run_num次
        for rn = 1:run_num
            [pareto_front(rn,1),iteration(rn)] = ...
                main(data_name,pop_name,gll(i),mg(j),pr(k),rt);
        end
        solution_name = strcat(file3,num2str(pn),'L',num2str(ei));
        save(solution_name,'pareto_front','iteration')
    end
    % 更新迭代时间
    rt = rt + 30;
end
disp("program end")

