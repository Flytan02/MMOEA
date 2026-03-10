function [associations, selected_solutions] = associate_with_reference_points(positions, refPoints)
    % 输入:
    %   particles: 粒子结构体数组，包含position字段
    %   refPoints: 参考点矩阵 (N×D)
    % 输出:
    %   associations: 每个粒子关联的参考点索引 (1×popSize)
    %   refElites: 每个参考点的精英解 (N×D)
    
    N = size(positions, 1);
    K = size(refPoints, 1);
    
    % 计算粒子到参考点的距离
    distances = pdist2(positions, refPoints, 'euclidean');
    
    % 分配每个粒子到最近的参考点
    [~, associations] = min(distances, [], 2);
    
    
    % 选择每个参考点的最近解
    selected_solutions = false(N, 1);
    for j = 1:K
        members = find(associations == j);
        if ~isempty(members)
            [~, best_idx] = min(distances(members, j));
            selected_solutions(members(best_idx)) = true;
        end
    end
end