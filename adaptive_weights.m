%% 辅助函数：自适应权重调整
function [weight_obj, weight_dec] = adaptive_weights(gen, maxGen)
    % 根据进化阶段调整双空间权重
    if gen < 0.3 * maxGen
        % 早期：更注重决策空间多样性
        weight_obj = 0.3;
        weight_dec = 0.7;
    elseif gen < 0.7 * maxGen
        % 中期：平衡两个空间
        weight_obj = 0.5;
        weight_dec = 0.5;
    else
        % 后期：更注重目标空间收敛性
        weight_obj = 0.8;
        weight_dec = 0.2;
    end
end