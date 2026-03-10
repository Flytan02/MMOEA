function refPoints = generate_reference_points(D, numPoints, lower, upper)
    % 输入:
    %   D: 决策空间维度
    %   numPoints: 总参考点数
    %   lower: 决策变量下界（标量或向量）
    %   upper: 决策变量上界（标量或向量）
    % 输出:
    %   refPoints: 生成的参考点矩阵 (numPoints×D)
    
    % 确保边界是正确的大小
    if isscalar(lower)
        lb = repmat(lower, 1, D);
    else
        lb = lower;
    end
    
    if isscalar(upper)
        ub = repmat(upper, 1, D);
    else
        ub = upper;
    end
    
    % 使用拉丁超立方采样生成参考点
    refPoints = lhsdesign(numPoints, D);
    
    % 将采样点从[0,1]范围缩放到实际决策空间范围
    for d = 1:D
        refPoints(:, d) = lb(d) + (ub(d) - lb(d)) * refPoints(:, d);
    end
end

