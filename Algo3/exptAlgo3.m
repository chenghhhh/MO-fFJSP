clear,clc
close all

problem_num = 12;                           % 算例个数
run_num = 10;                               % 运行次数
file1 = '../Data/A300/dataA';               % 问题数据文件名
file2 = '../Data/A300/popA';                % 初始种群文件名
file3 = '../Solution/A/algo3p300t90A';      % 输出结果文件名
% 初始化Pareto前沿和迭代次数
pareto_front(run_num,1) = struct('pop',[],'fit',[]);
iteration = zeros(run_num,1);

% 对每个算例
for pn = 1:problem_num
    % 字符串连接成完整文件名
    data_name = strcat(file1,num2str(pn));
    pop_name = strcat(file2,num2str(pn));
    % 运行run_num次
    for rn = 1:run_num
        [pareto_front(rn,1),iteration(rn)] = main(rn,data_name,pop_name);
    end
    solution_name = strcat(file3,num2str(pn));
    save(solution_name,'pareto_front','iteration')
end
disp("program end")
