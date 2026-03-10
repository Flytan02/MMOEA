function leader = SelectLeader(pop,GridIndex)

    % 所有存储库成员的网格索引
    GI = GridIndex;
   
    % 被占用的网格
    OC = unique(GI);
    
    %  基于超立方体中的粒子数计算每个超立方体的质量
    N = zeros(size(OC));
    P = zeros(size(OC));
    for k = 1:numel(OC)
        N(k) = numel(find(GI == OC(k)));
        P(k) = 10/N(k);
    end

    % 根据每个超立方体的质量执行轮盘赌选择超立方体
    P = P./sum(P);
    sci = RouletteWheelSelection(P);
    
    % 选择网格
    sc = OC(sci);
    
    % 当前网格中包含的所有粒子
    SCM = find(GI == sc);
    
    % 随机选择位置索引
    smi = randi([1 numel(SCM)]);
    
    % 选择粒子索引
    sm = SCM(smi);
    
    % 选择粒子
    leader = pop(sm);

end