%% 性能实验
%%-------------------------------------------------------------------------
clear,clc
close all

gll = 30;                             % 全局领导者限制
mg = 4;                               % 最大组数
pr = 0.2;                             % 扰动率
rt = 120;                             % 迭代时间
pn = 11;                              % 算例编号
run_num = 10;                         % 运行次数
file1 = '../Data/A300/dataA';         % 问题数据文件名
file2 = '../Data/A300/popA';          % 初始种群文件名
file3 = '../Solution/algo2t90A';      % 输出结果文件名
% 初始化Pareto前沿和迭代次数
pareto_front(run_num,1) = struct('pop',[],'fit',[]); 
iteration = zeros(run_num,1);

% 字符串连接成完整文件名
data_name = strcat(file1,num2str(pn));
pop_name = strcat(file2,num2str(pn));
% 运行run_num次
for rn = 1:run_num
    [pareto_front(rn,1),iteration(rn)] = main(data_name,pop_name,gll,mg,pr,rt);
end
solution_name = strcat(file3,num2str(pn));
save(solution_name,'pareto_front','iteration')
disp("program end")