classdef MMOPSO_SCDMA < ALGORITHM
% <2025> <multi> <real/multimodal>
    methods
        function main(Algorithm,Problem)        % 不使用变异
            ext_startTime = tic;

            % Generate random population
            % 双空间拥挤距离参数
            weight_obj = 0.7; % 目标空间权重
            weight_dec = 0.3; % 决策空间权重
            Population = Problem.Initialization();
            Archive = Population;
            Pbest = Population;
            Gbest = Pbest;
            cluster_interval = 0;
            gen = 0;
            maxGen = Problem.maxFE/Problem.N;
            nPop = length(Population);
            nVar = size(Population(1).decs,2);
            ub = Problem.upper;
            lb = Problem.lower;
            nGrid      = 10;        
            alpha      = 0.1;
    
            % DBSCAN参数设置
            minPts = max(3, round(log(nVar) * sqrt(nPop))); % 最小邻域点数
            % 生成参考点
            reference_points = generate_reference_points(nVar,nPop,lb,ub); 

            % Optimization
            while Algorithm.NotTerminated(Archive)
                gen = gen+1;

                % 自适应聚类间隔：后期减少聚类频率
                if cluster_interval == 0
                    cluster_interval = 10;
                    Population = UpdataPop([Archive,Population],Problem.N,weight_obj, weight_dec);
                    Pbest = Population;
                    % 种群聚类
                    data = Population.decs;
                    % 计算距离矩阵
                    distances = pdist2(data, data);
                    % 初始化聚类标记
                    cluster_idx = zeros(nPop, 1);
                    visited = false(nPop, 1);
                    current_cluster = 0;
                    
                    % 自适应DBSCAN聚类
                    k = minPts;
                    % 计算每个点的k距离
                    knn_dists = zeros(nPop, 1);
                    for i = 1:nPop
                        dists = sqrt(sum((data - data(i, :)).^2, 2));
                        dists(i) = inf; % 移除自身距离
                        sorted_dists = sort(dists);
                        knn_dists(i) = sorted_dists(min(k, length(sorted_dists)));
                    end
                    
                    % 对k距离降序排序
                    sorted_knn_dists = sort(knn_dists, 'descend');                    
                    % 自动检测拐点
                    epsilon = find_elbow_point(sorted_knn_dists);                  
                    % DBSCAN算法实现
                    for i = 1:nPop
                        if visited(i)
                            continue;
                        end                    
                        visited(i) = true;
                        neighbors = find(distances(i, :) < epsilon);                    
                        if numel(neighbors) < minPts
                            cluster_idx(i) = -1; % 噪音点标记
                        else
                            current_cluster = current_cluster + 1;
                            cluster_idx(i) = current_cluster;                    
                            % 扩展聚类
                            for j = 1:numel(neighbors)
                                neighbor_idx = neighbors(j);
                                if ~visited(neighbor_idx)
                                    visited(neighbor_idx) = true;                                    
                                    neighbor_neighbors = find(distances(neighbor_idx, :) < epsilon);
                                    if numel(neighbor_neighbors) >= minPts
                                        neighbors = [neighbors neighbor_neighbors];
                                    end
                                end                                
                                if cluster_idx(neighbor_idx) == 0
                                    cluster_idx(neighbor_idx) = current_cluster;
                                end
                            end
                        end
                    end

                    % 提取聚类结果
                    uniqueLabels = unique(cluster_idx);
                    groupQty = length(uniqueLabels) - any(uniqueLabels == -1);
                    popidx = {};
                    if groupQty > 0
                        for i = 1:groupQty
                            idx = find(i == cluster_idx);
                            if numel(idx) > 0
                                popidx{i} = idx;
                            end
                        end
                    end
                    % 提取噪声点
                    idx = find(-1 == cluster_idx);
                    if numel(idx) > 0
                        popidx{groupQty+1} = idx;
                    end

                    % 改进领导者选择
                    for i = 1:groupQty
                        if isempty(popidx{i})
                            continue;
                        end
                        
                        cluster_pop = Population(popidx{i});                                 
                        % 选择簇内非支配解
                        front = NDSort(cluster_pop.objs, 1);
                        nondominated = cluster_pop(front == 1);
                                            
                        % 如果存档中有更好的解，使用存档中的解
                        if Dominates(Archive(1).objs, nondominated(1).objs)
                            nondominated = Archive;
                        end         
                        leader = nondominated;
    
                        % 更新簇内粒子的Gbest
                        [leader,GridIndex] = UpdateGrid(leader, nGrid, alpha);
                        for j = 1:length(popidx{i})
                            Gbest(popidx{i}(j)) = SelectLeader(leader,GridIndex);
                        end
    
                        % 更新种群
                        Population(popidx{i}) = Operator(Problem,cluster_pop,Pbest(popidx{i}),Gbest(popidx{i}));
                    end
                else                    
                    % 改进领导者选择
                     for i = 1:groupQty
                        if isempty(popidx{i})
                            continue;
                        end
                        
                        cluster_pop = Population(popidx{i}); 
                        % 选择簇内非支配解
                        front = NDSort(cluster_pop.objs, 1);
                        nondominated = cluster_pop(front == 1);
                        % 如果存档中有更好的解，使用存档中的解
                        % if Dominates(Archive(1).objs, nondominated(1).objs)
                        %     nondominated = Archive;
                        % end         
                        % 关联参考点并选择解
                        [~, selectedidx] = associate_with_reference_points(nondominated.decs, reference_points);
                        leader = nondominated(selectedidx);
    
                        % 更新簇内粒子的Gbest
                        [leader,GridIndex] = UpdateGrid(leader, nGrid, alpha);
                        for j = 1:length(popidx{i})
                            Gbest(popidx{i}(j)) = SelectLeader(leader,GridIndex);
                        end
    
                        % 更新种群
                        Population(popidx{i}) = Operator(Problem,cluster_pop,Pbest(popidx{i}),Gbest(popidx{i}));
                     end
                end % 结束聚类
                
                % 噪声点处理：引导探索
                if numel(popidx) > groupQty
                    noise_pop = Population(popidx{groupQty+1});
                    for i = 1:numel(noise_pop)
                        if rand < 0.5 && length(Archive) > 1
                            % 选择存档中拥挤度较大的解
                            crowdingDistance = CrowdingDistance(Archive.objs);
                            leader = Archive(crowdingDistance<100000);
                            [leader,GridIndex] = UpdateGrid(leader, nGrid, alpha);
                            Gbest(popidx{groupQty+1}(i)) = SelectLeader(leader,GridIndex);
                        else
                            % 生成新解在决策空间探索
                            new_dec = lb + rand(1, nVar) .* (ub - lb);
                            new_sol = Problem.Evaluation(new_dec);
                            Gbest(popidx{groupQty+1}(i)) = new_sol;
                        end
                    end
                    % 更新种群
                    Population(popidx{groupQty+1}) = Operator(Problem,noise_pop,Pbest(popidx{groupQty+1}),Gbest(popidx{groupQty+1}));
                end

                Archive = UpdateArchive_1([Archive,Population],Problem.N,weight_obj, weight_dec);  
                Pbest = UpdatePbest(Pbest,Population);
                cluster_interval = cluster_interval-1;

                % 动态调整双空间权重
                [weight_obj, weight_dec] = adaptive_weights(gen, maxGen);
                % 只有当评估次数超过 30% 时才检查
                if Problem.FE > 0.05 * Problem.maxFE
                        % 确定要评估的种群
                        % MOPSO 的 Population 参数通常是 Pbest 或 Swarm
                            currentData = Archive; % 优先使用存档                        
                            currentHV = Problem.CalMetric('HV', currentData);
                            
                            % 判断是否达标
                            if currentHV >= 0.34741                   
                                ext_runTime = toc(ext_startTime);
                                MMF3=ext_runTime
                            end    
                end
            end
        end
    end
end