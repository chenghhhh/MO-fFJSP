%% �����ƽ�����ѡ��
%%-------------------------------------------------------------------------
function pop_new = tournamentSelection(pop,rank_value,crowd_dist,pool_size)
pop_size = size(pop,1);
pop_new = pop;
for i = 1:pop_size
    % �������Ⱥ��ѡ��pool_size�����壬����pool_sizeΪѡ��ظ������
    pool = randperm(pop_size,pool_size);
    % ��ȡ��ѡ����ķ�֧������ֵ
    pool_rank =  rank_value(pool,:);
    % �ȸ��ݷ�֧������ֵѡ����ߵȼ��ĸ���
    ind = find(pool_rank == min(pool_rank));
    % ���������ͬ�ȼ��ĸ��壬��ѡ��ӵ�������ĸ���
    if length(ind) > 1
        pool_new = pool(ind);
        crowd_dist_ind = crowd_dist(pool_new);
        [~,ind] = max(crowd_dist_ind);
    end
    % ���¸���
    pop_new(i,:) = pop(pool(ind),:);
end