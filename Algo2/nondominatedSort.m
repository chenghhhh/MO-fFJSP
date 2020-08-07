%% ��֧������
%%-------------------------------------------------------------------------
function [rank_value,crowd_dist] = nondominatedSort(fit_value)
pop_size = size(fit_value,1);               % ��Ⱥ��С
% ����ģ���깤ʱ���Ȩƽ��Ϊ������
Z = zeros(pop_size,2);
weight = [-0.2;0.8;0.2];                    % ����ģ����Ȩ��
Z(:,1) = fit_value(:,1:3) * weight;         % ��һ��Ŀ��ֵ
Z(:,2) = fit_value(:,4);                    % �ڶ���Ŀ��ֵ
%% --------------------------���ٷ�֧������--------------------------
objective_num = size(Z,2);                  % Ŀ������
dominate_set = cell(pop_size,1);            % ��ǰ����֧��ĸ��弯��
dominated_num = zeros(pop_size,1);          % ֧�䵱ǰ���������
rank_value = zeros(pop_size,1);             % ����ȼ�
front_set = {[]};                           % ǰ���漯��
%% ȷ����һǰ����
for i = 1:pop_size-1
    % ��ǰ���������������һһ���бȽ�
    for j = i+1:pop_size
        % IF  ����i��ƽ��makespan < ����j��ƽ��makespan
        %     IF  ����i�ļӹ����� >= ����j������
        %         ����i֧�����j;
        %     END IF
        % ELSE IF  ����i��ƽ��makespan > ����j��ƽ��makespan
        %     IF  ����i�ļӹ����� <= ����j������
        %         ����j֧�����i;
        %     END IF
        % ELSE  // �������
        %     IF  ����i���п��ܵ�makespan < ����j���п��ܵ�makespan
        %         IF  ����i�ļӹ����� >= ����j������
        %             ����i֧�����j;
        %         END IF
        %     ELSE IF  ����i���п��ܵ�makespan == ����j���п��ܵ�makespan
        %         IF  ����i�ļӹ����� > ����j������
        %             ����i֧�����j;
        %         ELSE IF  ����i�ļӹ����� < ����j������
        %             ����j֧�����i;
        %         END
        %     ELSE  // ����i���п��ܵ�makespan > ����j���п��ܵ�makespan
        %         IF  ����i�ļӹ����� < ����j������
        %             ����j֧�����i;
        %         END IF
        %     END IF
        % END IF
        % // ֧�����
        % ������jѹ�뵽����i��֧��ĸ��弯����;
        % ����֧�����j������;
        if Z(i,1) < Z(j,1)
            if Z(i,2) >= Z(j,2)
                dominate_set{i} = [dominate_set{i},j];
                dominated_num(j) = dominated_num(j) + 1;
            end
        elseif Z(i,1) > Z(j,1)
            if Z(i,2) <= Z(j,2)
                dominate_set{j} = [dominate_set{j},i];
                dominated_num(i) = dominated_num(i) + 1;
            end
        else
            if fit_value(i,2) < fit_value(j,2)
                if Z(i,2) >= Z(j,2)
                    dominate_set{i} = [dominate_set{i},j];
                    dominated_num(j) = dominated_num(j) + 1;
                end
            elseif fit_value(i,2) == fit_value(j,2)
                if Z(i,2) > Z(j,2)
                    dominate_set{i} = [dominate_set{i},j];
                    dominated_num(j) = dominated_num(j) + 1;
                elseif Z(i,2) < Z(j,2)
                    dominate_set{j} = [dominate_set{j},i];
                    dominated_num(i) = dominated_num(i) + 1;
                end
            else
                if Z(i,2) < Z(j,2)
                    dominate_set{j} = [dominate_set{j},i];
                    dominated_num(i) = dominated_num(i) + 1;
                end
            end
        end
    end
    % n==0�ĸ���Ϊ��һǰ�������
    if dominated_num(i) == 0
        % ����һǰ�������ĵȼ�ֵ����Ϊ1
        rank_value(i) = 1;
        % ���µ�һǰ���漯��
        front_set{1} = [front_set{1},i];
    end
end
% �����������һ������
if dominated_num(pop_size) == 0
    rank_value(pop_size) = 1;
    front_set{1} = [front_set{1},pop_size];
end
%% ȷ������ǰ����
k = 1;                              % ǰ���������
while ~isempty(front_set{k})
    next_front = [];                % ������һǰ����ĳ�Ա
    current_front = front_set{k};   % ��ǰ����
    % �Ե�ǰǰ�����ϵĸ���
    for p = 1:length(current_front)
        % ��ȡ��ǰ������֧��ĸ���
        dominate_set_p = dominate_set{current_front(p)};
        % ��ÿ������ǰ����p֧��ĸ���q����֧�����q�ĸ���������1
        % �ȼ��ڽ���ǰǰ�����ϵĵ�ȫ���Ƴ�
        for q = 1:length(dominate_set_p)
            j = dominate_set_p(q);
            dominated_num(j) = dominated_num(j) - 1;
            % n==0 ����j����ʣ����Ⱥ�еĸ�����֧��
            if dominated_num(j) == 0
                % ���µȼ�
                rank_value(j) = k + 1;
                % ������һǰ����
                next_front = [next_front,j];
            end
        end
    end
    % ǰ�������������
    k = k + 1;
    % ����ǰ����k�ĳ�Ա
    front_set{k} = sort(next_front);
end
%% ----------------------------ӵ���ȷ���----------------------------
num_front = size(front_set,2);         % ǰ��������
crowd_dist = zeros(pop_size,1);        % ���и����ӵ������
% for each front
for i = 1:num_front-1
    current_front = front_set{i};
    len = length(current_front);
    % �����ǰ��ǰ�����Ա��������3�������и����ӵ����������Ϊ1
    if (len < 3)
        crowd_dist(current_front) = ones(1,len);
        continue;
    end
    z = Z(current_front,:);             % ��ǰǰ�����Ա��Ŀ�꺯��ֵ
    crowd_dist_i = zeros(1,len);        % ӵ������
    % ��ÿ��Ŀ��
    for j = 1:objective_num
        % �Ե�j��Ŀ�꺯��ֵ��������
        [z_j,ind] = sort(z(:,j));
        % ��ǰ�������߽��Ա��ӵ����������Ϊ�������
        crowd_dist_i(ind(1)) = inf;
        crowd_dist_i(ind(end)) = inf;
        % �����j��Ŀ���������С����ֵ֮��
        delta = z_j(end) - z_j(1);
        % �Գ��߽���ĳ�Ա����ӵ������ļ���
        for k = 2:len-1
            crowd_dist_i(ind(k)) = crowd_dist_i(ind(k)) + (z_j(k+1) - z_j(k-1))/delta;
        end
    end
    % ���µ�ǰǰ�����ӵ������
    crowd_dist(current_front) = crowd_dist_i;
end
