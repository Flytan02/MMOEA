%% 自动检测拐点
function elbow_value = find_elbow_point(distances)
    n = length(distances);
    % 计算二阶差分
    diff1 = diff(distances);
    diff2 = diff(diff1);
    % 找到最大二阶差分的索引
    [~, elbow_idx] = max(diff2(1:floor(n*0.8))); % 只考虑前80%
    elbow_idx = elbow_idx + 1; % 补偿索引
    elbow_value = distances(elbow_idx);
end
