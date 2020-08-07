%% ���������Ⱥ
%%-------------------------------------------------------------------------
function pop = initialization(pop_size,se_index,num_operation,machine_set,num_job)
total_num_operation = sum(num_operation);       % ���й������ܹ�����
pop = zeros(pop_size,2*total_num_operation);    % ���壺��������+��������
%% ��ȡ������ȳ�ʼ����
% ʾ����11112222222333344444....8899999
% ��ʾ����1��4������,����2��7������,...,����9��5������
init_sequence = zeros(1,total_num_operation);
for j = 1:num_job
    % ������������Ƭ��ֵȫ��ֵΪ��������
    init_sequence(se_index(j,1):se_index(j,2)) = j;
end
%% �����ʼ����Ⱥ
for i = 1:pop_size
    %% ��ʼ����������
    counter = 1;
    for j = 1:num_job
        for k = 1:num_operation(j)
            machine_index = randperm(length(machine_set{j}{k}),1);
            pop(i,counter) = machine_set{j}{k}(machine_index);
            counter = counter + 1;
        end
    end
    %% ��ʼ���������
    pop(i,total_num_operation+1:end) = init_sequence(randperm(total_num_operation));
end
